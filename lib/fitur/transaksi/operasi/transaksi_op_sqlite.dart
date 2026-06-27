// path: lib/fitur/transaksi/operasi/transaksi_op_sqlite.dart

import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/statistik/model/paket_terlaris_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data transaksi di database lokal.
class TransaksiOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  final PaketOpSqlite paketOpsqlite;

  final String _tabel = NamaTabel.transaksi;
  DateTime get _nowUtc => DateTime.now().toUtc();

  TransaksiOpSqlite({
    required this.sqliteDb,
    required this.baseOpSqlite,
    required this.paketOpsqlite,
  });

  Future<Database> get _sqliteDb async => await sqliteDb.database;

  /// Menghitung ulang saldo dompet berdasarkan semua transaksi terkait dan memperbaruinya.
  /// Operasi ini harus dijalankan di dalam sebuah transaksi database [txn].
  Future<void> _hitungUlangDanPerbaruiSaldoDompet(
    final String idDompet,
    final DatabaseExecutor txn,
  ) async {
    try {
      Log.info('Memulai hitung ulang saldo untuk Wallet ID: $idDompet');

      final hasilTotal = await txn.rawQuery(
        '''
        SELECT
          COALESCE(SUM(
            CASE
              WHEN ${NamaKolom.tipe} = 'income'
                AND ${NamaKolom.idDompet} = ?
              THEN ${NamaKolom.jumlah}

              WHEN ${NamaKolom.tipe} = 'expense'
                AND ${NamaKolom.idDompet} = ?
              THEN -${NamaKolom.jumlah}

              WHEN ${NamaKolom.tipe} = 'transfer'
                AND ${NamaKolom.idDompet} = ?
              THEN -${NamaKolom.jumlah}

              WHEN ${NamaKolom.tipe} = 'transfer'
                AND ${NamaKolom.idDompetTujuan} = ?
              THEN ${NamaKolom.jumlah}

              ELSE 0
            END
          ), 0) as total
        FROM $_tabel
        WHERE ${NamaKolom.dihapus} = 0 AND (${NamaKolom.idDompet} = ? OR ${NamaKolom.idDompetTujuan} = ?)
        ''',
        [idDompet, idDompet, idDompet, idDompet, idDompet, idDompet],
      );

      final saldoTotal = (hasilTotal.first['total'] as num?)?.toDouble() ?? 0.0;
      final dompetMaps = await txn.query(
        NamaTabel.dompet,
        where: '${NamaKolom.id} = ?',
        whereArgs: [idDompet],
      );

      if (dompetMaps.isEmpty) {
        Log.warning('Dompet ID: $idDompet tidak ditemukan');
        return;
      }
      final dompetLama = DompetModel.fromSqlite(dompetMaps.first);
      final dompetBaru = dompetLama.copyWith(
        saldo: saldoTotal,
        diperbaruiPada: _nowUtc, // ← Gunakan DateTime
      );
      await txn.update(
        NamaTabel.dompet,
        dompetBaru.toSqlite(),
        where: '${NamaKolom.id} = ?',
        whereArgs: [idDompet],
      );

      Log.info(
        'Berhasil update saldo Wallet ID: $idDompet menjadi $saldoTotal',
      );
    } on Exception catch (e, st) {
      Log.error('Gagal hitung ulang saldo Wallet ID: $idDompet', e: e, s: st);
      rethrow;
    }
  }

  /// Menambahkan transaksi baru ke database dan memperbarui saldo dompet terkait.
  Future<int> tambahTransaksi(
    final TransaksiModel transaction, {
    final bool fromServer = false,
  }) async {
    try {
      final id = await baseOpSqlite.operasiKompleks<int>((
        final Transaction txn,
      ) async {
        Log.info('Memulai transaksi database untuk addTransaction');
        final data = transaction.copyWith(diperbaruiPada: _nowUtc);

        final newId = await txn.insert(
          _tabel,
          data.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        Log.info(
          'Data transaksi berhasil masuk ke tabel dengan row ID: $newId',
        );

        await _hitungUlangDanPerbaruiSaldoDompet(data.idDompet, txn);
        if (data.tipe == TipeTransaksi.transfer &&
            data.idDompetTujuan != null) {
          Log.info(
            'Deteksi transaksi transfer, menghitung saldo wallet tujuan',
          );
          await _hitungUlangDanPerbaruiSaldoDompet(data.idDompetTujuan!, txn);
        }
        return newId;
      }, dariServer: fromServer);
      Log.info('Proses addTransaction ID: ${transaction.id} berhasil');
      return id;
    } on Exception catch (e, st) {
      Log.error('Gagal menambah transaksi ID: ${transaction.id}', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua transaksi yang tidak dihapus dari database.
  Future<List<TransaksiModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    try {
      Log.info('Mengambil data semua transaksi dari SQLite');
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: query,
        orderBy: '${NamaKolom.tanggal} DESC',
      );

      Log.info('Berhasil mengambil ${maps.length} data transaksi dari SQLite');
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, st) {
      Log.error('Gagal mengambil semua transaksi', e: e, s: st);
      return [];
    }
  }

  /// Memperbarui data transaksi yang ada dan menghitung ulang saldo dompet yang terpengaruh.
  Future<void> perbaruiTransaksi(
    String id,
    TransaksiModel transaksi, {
    bool dariServer = false,
  }) async {
    try {
      await baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
        Log.info('Memulai update transaksi database ID: $id');
        final maps = await txn.query(
          _tabel,
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );

        if (maps.isNotEmpty) {
          final transaksiLama = TransaksiModel.fromSqlite(maps.first);
          final updateData = transaksi.copyWith(diperbaruiPada: _nowUtc);
          await txn.update(
            _tabel,
            updateData.toSqlite(),
            where: '${NamaKolom.id} = ?',
            whereArgs: [id],
          );
          Log.info('Data transaksi $transaksiLama ke  $updateData diperbarui');
          final dompetTerpengaruh = <String>{};
          dompetTerpengaruh.add(transaksiLama.idDompet);
          dompetTerpengaruh.add(updateData.idDompet);
          if (transaksiLama.idDompetTujuan != null) {
            dompetTerpengaruh.add(transaksiLama.idDompetTujuan!);
          }
          if (updateData.idDompetTujuan != null) {
            dompetTerpengaruh.add(updateData.idDompetTujuan!);
          }

          Log.info(
            'Mengupdate saldo untuk wallet yang terpengaruh: $dompetTerpengaruh',
          );
          for (final idDompet in dompetTerpengaruh) {
            await _hitungUlangDanPerbaruiSaldoDompet(idDompet, txn);
          }
        } else {
          Log.warning('Update gagal: Transaksi ID $id tidak ditemukan');
        }
      }, dariServer: dariServer);
      Log.info('Proses updateTransaction ID: $id selesai');
    } on Exception catch (e, st) {
      Log.error('Gagal update transaksi ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil satu transaksi berdasarkan ID-nya.
  Future<TransaksiModel?> ambilBerdasarkanId(String id) async {
    try {
      final db = await _sqliteDb;
      Log.info('Mencari transaksi berdasarkan ID: $id');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.warning('Transaksi dengan ID: $id tidak ditemukan');
        return null;
      }
      Log.info('Transaksi ID: $id ditemukan');
      return TransaksiModel.fromSqlite(maps.first);
    } catch (e, st) {
      Log.error('Gagal mengambil transaksi ID: $id', e: e, s: st);
      return null;
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi untuk Customer ID: $idPelanggan');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.idPelanggan} = ? AND ${NamaKolom.dihapus} = ?',
        whereArgs: [idPelanggan, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info(
        'Ditemukan ${maps.length} transaksi untuk Customer ID: $idPelanggan',
      );
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } catch (e, st) {
      Log.error('Error ambil transaksi customer', e: e, s: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan sebuah dompet (baik sebagai sumber maupun tujuan).
  Future<List<TransaksiModel>> ambilBerdasarkanIdDompet(
    final String idDompet,
  ) async {
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi terkait Wallet ID: $idDompet');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where:
            '(${NamaKolom.idDompet} = ? OR ${NamaKolom.idDompetTujuan} = ?) AND ${NamaKolom.dihapus} = ?',
        whereArgs: [idDompet, idDompet, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Ditemukan ${maps.length} transaksi untuk Wallet ID: $idDompet');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error ambil transaksi wallet', e: e, s: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket.
  Future<List<TransaksiModel>> ambilBerdasarkanStatusAktivasi() async {
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi dengan status isActivated = 1');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.statusAktivasi} = ? AND ${NamaKolom.dihapus} = ?',
        whereArgs: [1, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} transaksi aktivasi paket');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error saat mengambil transaksi aktivasi paket', e: e, s: st);
      return [];
    }
  }

  /// Menandai transaksi sebagai dihapus (soft delete) dan menghitung ulang saldo dompet.
  Future<void> softDelete(String id, {bool dariServer = false}) async {
    try {
      await baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
        Log.info('Memulai soft delete atomik untuk ID: $id');
        final maps = await txn.query(
          _tabel,
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );

        if (maps.isEmpty) {
          Log.warning('Soft delete gagal: Transaksi ID $id tidak ditemukan');
          return;
        }

        final transaksiLama = TransaksiModel.fromSqlite(maps.first);
        final transaksiDiarsip = transaksiLama.copyWith(
          diHapus: true,
          diperbaruiPada: _nowUtc,
          diarsipkanPada: _nowUtc,
        );
        await txn.update(
          _tabel,
          transaksiDiarsip.toSqlite(),
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );
        Log.info('Flag isDeleted diatur ke 1 untuk ID: $id');

        await _hitungUlangDanPerbaruiSaldoDompet(transaksiLama.idDompet, txn);
        if (transaksiLama.tipe == TipeTransaksi.transfer &&
            transaksiLama.idDompetTujuan != null) {
          await _hitungUlangDanPerbaruiSaldoDompet(
            transaksiLama.idDompetTujuan!,
            txn,
          );
        }
      }, dariServer: dariServer);
      Log.info('Transaksi ID: $id berhasil diarsipkan secara atomik');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan transaksi ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Menandai semua transaksi sebagai dihapus dan mereset saldo semua dompet menjadi 0.
  Future<int> softDeleteAll({bool dariServer = false}) async {
    try {
      final count = await baseOpSqlite.operasiKompleks<int>((
        final Transaction txn,
      ) async {
        Log.warning('Memulai soft delete semua transaksi secara atomik');

        final rowsAffected = await txn.update(
          _tabel,
          {
            NamaKolom.dihapus: 1,
            NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
            NamaKolom.diarsipkanPada: _nowUtc.millisecondsSinceEpoch,
          },
          where: '${NamaKolom.dihapus} = ?',
          whereArgs: [0],
        );
        Log.info('$rowsAffected transaksi telah ditandai sebagai dihapus');

        await txn.update(NamaTabel.dompet, {
          NamaKolom.saldo: 0,
          NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
        });
        Log.info('Semua saldo dompet direset ke 0 setelah penghapusan massal');

        return rowsAffected;
      }, dariServer: dariServer);
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal menghapus semua transaksi', e: e, s: st);
      rethrow;
    }
  }

  /// Menghitung total pemasukan (income) dari semua transaksi.
  Future<double> ambilTotalPemasukan() async {
    try {
      final db = await _sqliteDb;
      Log.info('Menghitung total seluruh pemasukan');
      final result = await db.rawQuery(
        "SELECT SUM(${NamaKolom.jumlah}) as total FROM $_tabel WHERE ${NamaKolom.tipe} = 'income' AND ${NamaKolom.dihapus} = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      Log.info('Total pemasukan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total pemasukan', e: e, s: st);
      return 0.0;
    }
  }

  /// Menghitung total pengeluaran (expense) dari semua transaksi.
  Future<double> ambilTotalPengeluaran() async {
    try {
      final db = await _sqliteDb;
      Log.info('Menghitung total seluruh pengeluaran');
      final result = await db.rawQuery(
        "SELECT SUM(${NamaKolom.jumlah}) as total FROM $_tabel WHERE ${NamaKolom.tipe} = 'expense' AND ${NamaKolom.dihapus} = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      Log.info('Total pengeluaran: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total pengeluaran', e: e, s: st);
      return 0.0;
    }
  }

  /// Menghitung total bersih (pemasukan - pengeluaran).
  Future<double> getNetTotal() async {
    Log.info('Menghitung Net Total (Pemasukan - Pengeluaran)');
    final income = await ambilTotalPemasukan();
    final expense = await ambilTotalPengeluaran();
    final net = income - expense;
    Log.info('Hasil Net Total: $net');
    return net;
  }

  Future<List<PaketTerlarisModel>> ambilPaketTerlaris({int limit = 5}) async {
    Log.info('Mulai menghitung paket terlaris.');
    try {
      final daftarPaket = await paketOpsqlite.ambilSemua();
      final daftartransaksi = await ambilSemua();
      if (daftartransaksi.isEmpty) {
        Log.warning('Tidak ada transaksi, mengembalikan list paket kosong.');
        return [];
      }
      final jumlahPenjualan = groupBy(
        daftartransaksi.where((t) => t.idPaket != null).toList(),
        (t) => t.idPaket!,
      ).map((key, value) => MapEntry(key, value.length));
      final paketTerlaris = daftarPaket.map((paket) {
        return PaketTerlarisModel(
          paket: paket,
          totalTerjual: jumlahPenjualan[paket.id] ?? 0,
        );
      }).toList();
      paketTerlaris.sort((a, b) => b.totalTerjual.compareTo(a.totalTerjual));

      final hasil = paketTerlaris.take(limit).toList();
      Log.info(
        'Berhasil menghitung ${hasil.length} paket terlaris: ${hasil.map((p) => '${p.paket.nama} (${p.totalTerjual})').toList()}',
      );

      return hasil;
    } catch (e, st) {
      Log.error('Gagal menghitung paket terlaris.', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil data pendapatan harian dalam 7 hari terakhir
  Future<List<double>> ambilPendapatanHarian() async {
    try {
      final db = await SqliteDatabase.instance.database;
      final now = DateTime.now();
      final results = <double>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final result = await db.rawQuery(
          '''
        SELECT COALESCE(SUM(
          CASE
            WHEN ${NamaKolom.tipe} = 'income' THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.tipe} = 'expense' THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ), 0) as total
        FROM ${NamaTabel.transaksi}
        WHERE ${NamaKolom.tanggal} >= ? 
          AND ${NamaKolom.tanggal} < ?
          AND ${NamaKolom.dihapus} = 0
          AND ${NamaKolom.statusPembayaran} = 'paid'
        ''',
          [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        );

        final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        results.add(total / 1000000); // Konversi ke Jutaan
      }

      return results;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan harian', e: e, s: st);
      return List.filled(7, 0.0);
    }
  }

  /// Mengambil data pendapatan mingguan dalam 4 minggu terakhir
  Future<List<double>> ambilPendapatanMingguan() async {
    try {
      final db = await SqliteDatabase.instance.database;
      final now = DateTime.now();
      final results = <double>[];

      for (int i = 3; i >= 0; i--) {
        final startOfWeek = now.subtract(
          Duration(days: i * 7 + now.weekday - 1),
        );
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final end = start.add(const Duration(days: 7));

        final result = await db.rawQuery(
          '''
        SELECT COALESCE(SUM(
          CASE
            WHEN ${NamaKolom.tipe} = 'income' THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.tipe} = 'expense' THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ), 0) as total
        FROM ${NamaTabel.transaksi}
        WHERE ${NamaKolom.tanggal} >= ? 
          AND ${NamaKolom.tanggal} < ?
          AND ${NamaKolom.dihapus} = 0
          AND ${NamaKolom.statusPembayaran} = 'paid'
        ''',
          [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
        );

        final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        results.add(total / 1000000); // Konversi ke Jutaan
      }

      return results;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan mingguan', e: e, s: st);
      return List.filled(4, 0.0);
    }
  }

  /// Mengambil data pendapatan bulanan dalam 5 bulan terakhir
  Future<List<double>> ambilPendapatanBulanan() async {
    try {
      final db = await SqliteDatabase.instance.database;
      final now = DateTime.now();
      final results = <double>[];

      for (int i = 4; i >= 0; i--) {
        final month = now.month - i;
        final year = now.year - (month <= 0 ? 1 : 0);
        final actualMonth = month <= 0 ? month + 12 : month;

        final startOfMonth = DateTime(year, actualMonth);
        final endOfMonth = DateTime(
          actualMonth == 12 ? year + 1 : year,
          actualMonth == 12 ? 1 : actualMonth + 1,
        );

        final result = await db.rawQuery(
          '''
        SELECT COALESCE(SUM(
          CASE
            WHEN ${NamaKolom.tipe} = 'income' THEN ${NamaKolom.jumlah}
            WHEN ${NamaKolom.tipe} = 'expense' THEN -${NamaKolom.jumlah}
            ELSE 0
          END
        ), 0) as total
        FROM ${NamaTabel.transaksi}
        WHERE ${NamaKolom.tanggal} >= ? 
          AND ${NamaKolom.tanggal} < ?
          AND ${NamaKolom.dihapus} = 0
          AND ${NamaKolom.statusPembayaran} = 'paid'
        ''',
          [
            startOfMonth.millisecondsSinceEpoch,
            endOfMonth.millisecondsSinceEpoch,
          ],
        );

        final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
        results.add(total / 1000000); // Konversi ke Jutaan
      }

      return results;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan bulanan', e: e, s: st);
      return List.filled(5, 0.0);
    }
  }

  /// Menghitung total poin yang diperoleh seorang pelanggan.
  Future<int> ambilPoinDidapat(String idPelanggan) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung poin yang dihasilkan Customer: $idPelanggan');
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.poinDidapat}) as total FROM $_tabel WHERE ${NamaKolom.idPelanggan} = ? AND ${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusPembayaran} = ?',
        [idPelanggan, StatusPembayaran.paid.name],
      );
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin dihasilkan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin dihasilkan', e: e, s: st);
      return 0;
    }
  }

  Future<int> ambilPoinDigunakan(String idPelanggan) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung poin yang digunakan Customer: $idPelanggan');
      final result = await db.rawQuery(
        'SELECT SUM(${NamaKolom.poinDigunakan}) as total FROM $_tabel WHERE ${NamaKolom.idPelanggan} = ? AND ${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusPembayaran} = ?',
        [idPelanggan, StatusPembayaran.paid.name],
      );
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin digunakan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin digunakan', e: e, s: st);
      return 0;
    }
  }

  Future<int> ambilTotalPoin(String idPelanggan) async {
    Log.info('Menghitung saldo poin akhir Customer: $idPelanggan');
    final hasil = await Future.wait([
      ambilPoinDidapat(idPelanggan),
      ambilPoinDigunakan(idPelanggan),
    ]);
    final poinDidapat = hasil[0];
    final poinDigunakan = hasil[1];
    final total = poinDidapat - poinDigunakan;
    Log.info(
      'Saldo poin akhir Customer $idPelanggan: $total (earned=$poinDidapat, used=$poinDigunakan)',
    );
    return total;
  }

  Future<int> ambilTotalPoinSemuaPelanggan() async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung total poin semua pelanggan');

      final result = await db.rawQuery(
        '''
      SELECT 
        SUM(${NamaKolom.poinDidapat}) as total_poin_didapat,
        SUM(${NamaKolom.poinDigunakan}) as total_poin_digunakan
      FROM $_tabel 
      WHERE ${NamaKolom.dihapus} = 0 
        AND ${NamaKolom.statusPembayaran} = ?
      ''',
        [StatusPembayaran.paid.name],
      );

      final poinDidapat = result.first['total_poin_didapat'] as int? ?? 0;
      final poinDigunakan = result.first['total_poin_digunakan'] as int? ?? 0;
      final total = poinDidapat - poinDigunakan;

      Log.info('Total poin semua pelanggan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total poin semua pelanggan', e: e, s: st);
      return 0;
    }
  }

  /// Memasukkan atau memperbarui beberapa transaksi sekaligus (batch) dan menghitung ulang saldo dompet yang terpengaruh.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<TransaksiModel> transaksi, {
    final bool dariServer = false,
  }) async {
    if (transaksi.isEmpty) {
      Log.warning('Batch dibatalkan karena daftar transaksi kosong');
      return;
    }
    final Set<String> dompetTerpengaruh = {};

    try {
      await baseOpSqlite.operasiKompleks<void>((final Transaction txn) async {
        Log.info(
          'Memulai proses Batch insert/update untuk ${transaksi.length} item',
        );
        final batch = txn.batch();
        for (final item in transaksi) {
          batch.insert(
            _tabel,
            item.copyWith(diperbaruiPada: _nowUtc).toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          dompetTerpengaruh.add(item.idDompet);
          if (item.idDompetTujuan != null) {
            dompetTerpengaruh.add(item.idDompetTujuan!);
          }
        }
        await batch.commit(noResult: true);
        Log.info(
          'Batch commit selesai. Menghitung ulang saldo untuk wallet: $dompetTerpengaruh',
        );

        for (final walletId in dompetTerpengaruh) {
          await _hitungUlangDanPerbaruiSaldoDompet(walletId, txn);
        }
      }, dariServer: dariServer);
      Log.info('Proses Batch transaksi berhasil sepenuhnya');
    } on Exception catch (e, st) {
      Log.error('Gagal menjalankan Batch transaksi', e: e, s: st);
      rethrow;
    }
  }

  Future<double> ambilTotalPendapatanPerbulan() async {
    try {
      final db = await SqliteDatabase.instance.database;
      final List<Map<String, dynamic>> hasil = await db.rawQuery(
        '''
      SELECT SUM(
        CASE
          WHEN ${NamaKolom.tipe} = ? THEN ${NamaKolom.jumlah}
          WHEN ${NamaKolom.tipe} = ? THEN -${NamaKolom.jumlah}
          ELSE 0
        END
      ) as total
      FROM ${NamaTabel.transaksi}
      WHERE ${NamaKolom.dihapus} = 0
        AND ${NamaKolom.statusPembayaran} = ?
      ''',
        [
          TipeTransaksi.income.name,
          TipeTransaksi.expense.name,
          StatusPembayaran.paid.name,
        ],
      );

      final total = (hasil.first['total'] as num?)?.toDouble() ?? 0.0;
      Log.info('Total pendapatan bersih: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal mengambil pendapatan bersih.', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil beberapa transaksi berdasarkan daftar ID.
  Future<List<TransaksiModel>> ambilBerdasarkanIds(
    final List<String> ids,
  ) async {
    if (ids.isEmpty) {
      Log.warning('Pencarian Batch ID dibatalkan karena list ID kosong');
      return [];
    }
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi berdasarkan list ID: $ids');
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} transaksi dari list ID');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error saat ambil transaksi by IDs', e: e, s: st);
      return [];
    }
  }
}

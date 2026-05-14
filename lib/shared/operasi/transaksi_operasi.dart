// path: lib/shared/operasi/transaksi_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.

import 'package:sqflite/sqflite.dart';

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data transaksi di database lokal.
class TransaksiOperasi {
  static DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  /// Konstruktor untuk `TransaksiOperasi`.
  TransaksiOperasi();

  /// Mengatur instance `DatabaseHelper` secara manual untuk keperluan pengujian.
  static void testSetInstance(final DatabaseHelper dbHelper) {
    _dbHelper = dbHelper;
    Log.info(
      'DatabaseHelper instance manual ditetapkan untuk testing - method: testSetInstance',
    );
  }

  Future<Database> get _db async => await _dbHelper.database;

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================

  Future<void> _recalculateAndUpdateDompetSaldo(
    final String idDompet,
    final DatabaseExecutor txn,
  ) async {
    try {
      Log.info(
        'Memulai hitung ulang saldo untuk Dompet ID: $idDompet - method: _recalculateAndUpdateDompetSaldo',
      );

      final totalResult = await txn.rawQuery(
        '''
        SELECT
          COALESCE(SUM(
            CASE
              WHEN tipe = 'pemasukan'
                AND id_dompet = ?
              THEN jumlah

              WHEN tipe = 'pengeluaran'
                AND id_dompet = ?
              THEN -jumlah

              WHEN tipe = 'transfer'
                AND id_dompet = ?
              THEN -jumlah

              WHEN tipe = 'transfer'
                AND id_dompet_tujuan = ?
              THEN jumlah

              ELSE 0
            END
          ), 0) as total
        FROM transaksi
        WHERE isDeleted = 0 AND (id_dompet = ? OR id_dompet_tujuan = ?)
        ''',
        [idDompet, idDompet, idDompet, idDompet, idDompet, idDompet],
      );

      final totalSaldo =
          (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

      await txn.update(
        'dompet',
        {
          'saldo': totalSaldo,
          'diperbarui': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [idDompet],
      );

      Log.info(
        'Berhasil update saldo Dompet ID: $idDompet menjadi $totalSaldo - method: _recalculateAndUpdateDompetSaldo',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal hitung ulang saldo Dompet ID: $idDompet. Error: $e - method: _recalculateAndUpdateDompetSaldo',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menambah [TransaksiModel] baru ke database.
  Future<int> tambahTransaksi(
    final TransaksiModel transaksi, {
    final bool dariServer = false,
  }) async {
    try {
      final id = await _operasiDasar.jalankanOperasiKompleks<int>(
        (final txn) async {
          Log.info(
            'Memulai transaksi database untuk tambahTransaksi - method: tambahTransaksi',
          );
          final data = transaksi.copyWith(diperbarui: DateTime.now().toUtc());

          final newId = await txn.insert(
            'transaksi',
            data.toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          Log.info(
            'Data transaksi berhasil masuk ke tabel dengan row ID: $newId - method: tambahTransaksi',
          );

          await _recalculateAndUpdateDompetSaldo(data.idDompet, txn);
          if (data.tipe == TipeTransaksi.transfer &&
              data.idDompetTujuan != null) {
            Log.info(
              'Deteksi transaksi transfer, menghitung saldo dompet tujuan: ${data.idDompetTujuan} - method: tambahTransaksi',
            );
            await _recalculateAndUpdateDompetSaldo(data.idDompetTujuan!, txn);
          }
          return newId;
        },
        dariServer: dariServer,
      );
      Log.info(
        'Seluruh proses tambah transaksi ID: ${transaksi.id} berhasil diselesaikan - method: tambahTransaksi',
      );
      return id;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menambah transaksi ID: ${transaksi.id}. Error: $e - method: tambahTransaksi',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua transaksi dari database.
  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await _dbHelper.database;
    try {
      Log.info(
        'Mengambil data semua transaksi (isDeleted = 0) - method: ambilSemuaTransaksi',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'isDeleted = ?',
        whereArgs: [0],
        orderBy: 'tanggal DESC',
      );

      Log.info(
        'Berhasil mengambil ${maps.length} data transaksi dari SQLite - method: ambilSemuaTransaksi',
      );
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil semua transaksi. Error: $e - method: ambilSemuaTransaksi',
        e: e,
        st: st,
      );
      return [];
    }
  }

  /// Mengambil [TransaksiModel] berdasarkan [id].
  Future<TransaksiModel?> getTransaksiById(final String id) async {
    final db = await _db;
    try {
      Log.info(
        'Mencari transaksi berdasarkan ID: $id - method: getTransaksiById',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.warning(
          'Transaksi dengan ID: $id tidak ditemukan - method: getTransaksiById',
        );
        return null;
      }

      Log.info('Transaksi ID: $id ditemukan - method: getTransaksiById');
      return TransaksiModel.fromSqlite(maps.first);
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil transaksi ID: $id. Error: $e - method: getTransaksiById',
        e: e,
        st: st,
      );
      return null;
    }
  }

  /// Mengambil semua transaksi yang terkait dengan [pelangganId].
  Future<List<TransaksiModel>> ambilTransaksiByPelangganId(
    final String pelangganId,
  ) async {
    final db = await _db;
    try {
      Log.info(
        'Mengambil transaksi untuk Pelanggan ID: $pelangganId - method: ambilTransaksiByPelangganId',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id_pelanggan = ? AND isDeleted = ?',
        whereArgs: [pelangganId, 0],
        orderBy: 'tanggal DESC',
      );
      Log.info(
        'Ditemukan ${maps.length} transaksi untuk Pelanggan ID: $pelangganId - method: ambilTransaksiByPelangganId',
      );
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error(
        'Error ambil transaksi pelanggan: $e - method: ambilTransaksiByPelangganId',
        e: e,
        st: st,
      );
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan [dompetId].
  Future<List<TransaksiModel>> ambilTransaksiByDompetId(final String dompetId) async {
    final db = await _db;
    try {
      Log.info(
        'Mengambil transaksi terkait Dompet ID: $dompetId (asal/tujuan) - method: ambilTransaksiByDompetId',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '(id_dompet = ? OR id_dompet_tujuan = ?) AND isDeleted = ?',
        whereArgs: [dompetId, dompetId, 0],
        orderBy: 'tanggal DESC',
      );
      Log.info(
        'Ditemukan ${maps.length} transaksi untuk Dompet ID: $dompetId - method: ambilTransaksiByDompetId',
      );

      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error(
        'Error ambil transaksi dompet: $e - method: ambilTransaksiByDompetId',
        e: e,
        st: st,
      );
      return [];
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket.
  Future<List<TransaksiModel>> getTransaksiByAktivasiPaket() async {
    final db = await _db;
    try {
      Log.info(
        'Mengambil transaksi dengan status aktivasi_paket = 1 - method: getTransaksiByAktivasiPaket',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'aktivasi_paket = ? AND isDeleted = ?',
        whereArgs: [1, 0],
        orderBy: 'tanggal DESC',
      );
      Log.info(
        'Berhasil mengambil ${maps.length} transaksi aktivasi paket - method: getTransaksiByAktivasiPaket',
      );
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error(
        'Error saat mengambil transaksi aktivasi_paket: $e - method: getTransaksiByAktivasiPaket',
        e: e,
        st: st,
      );
      return [];
    }
  }

  /// Memperbarui [TransaksiModel] di database berdasarkan [id].
  Future<void> updateTransaksi(
    final String id,
    final TransaksiModel transaksiBaru, {
    final bool dariServer = false,
  }) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          Log.info(
            'Memulai update transaksi database ID: $id - method: updateTransaksi',
          );
          final maps = await txn.query(
            'transaksi',
            where: 'id = ?',
            whereArgs: [id],
          );

          if (maps.isNotEmpty) {
            final transaksiLama = TransaksiModel.fromSqlite(maps.first);
            final dataUpdate =
                transaksiBaru.copyWith(diperbarui: DateTime.now().toUtc());

            await txn.update(
              'transaksi',
              dataUpdate.toSqlite(),
              where: 'id = ?',
              whereArgs: [id],
            );
            Log.info(
              'Data transaksi ID: $id diperbarui di tabel transaksi - method: updateTransaksi',
            );

            final affectedWallets = <String>{};
            affectedWallets.add(transaksiLama.idDompet);
            affectedWallets.add(dataUpdate.idDompet);
            if (transaksiLama.idDompetTujuan != null) {
              affectedWallets.add(transaksiLama.idDompetTujuan!);
            }

            if (dataUpdate.idDompetTujuan != null) {
              affectedWallets.add(dataUpdate.idDompetTujuan!);
            }

            Log.info(
              'Mengupdate saldo untuk dompet yang terpengaruh: $affectedWallets - method: updateTransaksi',
            );
            for (final dompetId in affectedWallets) {
              await _recalculateAndUpdateDompetSaldo(dompetId, txn);
            }
          } else {
            Log.warning(
              'Update gagal: Transaksi ID $id tidak ditemukan di DB - method: updateTransaksi',
            );
          }
        },
        dariServer: dariServer,
      );
      Log.info(
        'Proses updateTransaksi ID: $id selesai - method: updateTransaksi',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal update transaksi ID: $id. Error: $e - method: updateTransaksi',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan [TransaksiModel] berdasarkan [id].
  Future<void> arsipkanTransaksi(final String id, {final bool dariServer = false}) async {
    try {
      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          Log.info(
            'Memulai proses pengarsipan (Soft Delete) ID: $id - method: arsipkanTransaksi',
          );
          final maps = await txn.query(
            'transaksi',
            where: 'id = ?',
            whereArgs: [id],
          );

          if (maps.isNotEmpty) {
            final transaksiLama = TransaksiModel.fromSqlite(maps.first);
            final now = DateTime.now().toUtc();
            await txn.update(
              'transaksi',
              {
                'isDeleted': 1,
                'diperbarui': now.millisecondsSinceEpoch,
                'diarsipkan': now.millisecondsSinceEpoch,
              },
              where: 'id = ?',
              whereArgs: [id],
            );
            Log.info(
              'Flag isDeleted diatur ke 1 untuk ID: $id - method: arsipkanTransaksi',
            );

            await _recalculateAndUpdateDompetSaldo(transaksiLama.idDompet, txn);
            if (transaksiLama.tipe == TipeTransaksi.transfer &&
                transaksiLama.idDompetTujuan != null) {
              await _recalculateAndUpdateDompetSaldo(
                transaksiLama.idDompetTujuan!,
                txn,
              );
            }
          } else {
            Log.warning(
              'Arsip gagal: Transaksi ID $id tidak ditemukan - method: arsipkanTransaksi',
            );
          }
        },
        dariServer: dariServer,
      );
      Log.info(
        'Transaksi ID: $id berhasil diarsipkan - method: arsipkanTransaksi',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengarsipkan transaksi ID: $id. Error: $e - method: arsipkanTransaksi',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mendapatkan total pemasukan dari semua transaksi.
  Future<double> getTotalPemasukan() async {
    final db = await _db;
    try {
      Log.info(
        'Menghitung total seluruh pemasukan - method: getTotalPemasukan',
      );
      final result = await db.rawQuery(
        "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pemasukan' AND isDeleted = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['jumlah'] != null) {
        total = (result.first['jumlah'] as num).toDouble();
      }
      Log.info('Total pemasukan: $total - method: getTotalPemasukan');
      return total;
    } on Exception catch (e, st) {
      Log.error(
        'Error hitung total pemasukan: $e - method: getTotalPemasukan',
        e: e,
        st: st,
      );
      return 0.0;
    }
  }

  /// Mendapatkan total pengeluaran dari semua transaksi.
  Future<double> getTotalPengeluaran() async {
    final db = await _db;
    try {
      Log.info(
        'Menghitung total seluruh pengeluaran - method: getTotalPengeluaran',
      );
      final result = await db.rawQuery(
        "SELECT SUM(jumlah) as jumlah FROM transaksi WHERE tipe = 'pengeluaran' AND isDeleted = 0",
      );
      double total = 0.0;
      if (result.isNotEmpty && result.first['jumlah'] != null) {
        total = (result.first['jumlah'] as num).toDouble();
      }
      Log.info('Total pengeluaran: $total - method: getTotalPengeluaran');
      return total;
    } on Exception catch (e, st) {
      Log.error(
        'Error hitung total pengeluaran: $e - method: getTotalPengeluaran',
        e: e,
        st: st,
      );
      return 0.0;
    }
  }

  /// Mendapatkan total bersih (pemasukan - pengeluaran).
  Future<double> getNetTotal() async {
    Log.info(
      'Menghitung Net Total (Pemasukan - Pengeluaran) - method: getNetTotal',
    );
    final pemasukan = await getTotalPemasukan();
    final pengeluaran = await getTotalPengeluaran();
    final net = pemasukan - pengeluaran;
    Log.info('Hasil Net Total: $net - method: getNetTotal');
    return net;
  }

  /// Mendapatkan total poin yang dihasilkan oleh [idPelanggan].
  Future<int> getPoinYangDihasilkan(final String idPelanggan) async {
    final db = await _dbHelper.database;
    try {
      Log.info(
        'Menghitung poin yang dihasilkan Pelanggan: $idPelanggan - method: getPoinYangDihasilkan',
      );
      final result = await db.rawQuery(
        'SELECT SUM(poin_yang_dihasilkan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
        [idPelanggan],
      );
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin dihasilkan: $total - method: getPoinYangDihasilkan');
      return total;
    } on Exception catch (e, st) {
      Log.error(
        'Error hitung poin dihasilkan: $e - method: getPoinYangDihasilkan',
        e: e,
        st: st,
      );
      return 0;
    }
  }

  /// Mendapatkan total poin yang digunakan oleh [idPelanggan].
  Future<int> getPoinYangDigunakan(final String idPelanggan) async {
    final db = await _dbHelper.database;
    try {
      Log.info(
        'Menghitung poin yang digunakan Pelanggan: $idPelanggan - method: getPoinYangDigunakan',
      );
      final result = await db.rawQuery(
        'SELECT SUM(poin_yang_digunakan) as total FROM transaksi WHERE id_pelanggan = ? AND isDeleted = 0',
        [idPelanggan],
      );
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin digunakan: $total - method: getPoinYangDigunakan');
      return total;
    } on Exception catch (e, st) {
      Log.error(
        'Error hitung poin digunakan: $e - method: getPoinYangDigunakan',
        e: e,
        st: st,
      );
      return 0;
    }
  }

  /// Mendapatkan total poin yang dimiliki oleh [idPelanggan].
  Future<int> getTotalPoin(final String idPelanggan) async {
    Log.info(
      'Menghitung saldo poin akhir Pelanggan: $idPelanggan - method: getTotalPoin',
    );
    final poinDihasilkan = await getPoinYangDihasilkan(idPelanggan);
    final poinDigunakan = await getPoinYangDigunakan(idPelanggan);
    final total = poinDihasilkan - poinDigunakan;
    Log.info('Saldo poin akhir: $total - method: getTotalPoin');
    return total;
  }

  /// Menyisipkan atau memperbarui sekumpulan [TransaksiModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<TransaksiModel> items, {
    final bool dariServer = false,
  }) async {
    final Set<String> affectedWallets = {};

    try {
      await _operasiDasar.jalankanOperasiKompleks(
        (final txn) async {
          Log.info(
            'Memulai proses Batch insert/update untuk ${items.length} item - method: sisipkanAtauPerbaruiBatch',
          );
          final batch = txn.batch();
          for (var item in items) {
            batch.insert(
              'transaksi',
              item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            affectedWallets.add(item.idDompet);
            if (item.idDompetTujuan != null) {
              affectedWallets.add(item.idDompetTujuan!);
            }
          }
          await batch.commit(noResult: true);
          Log.info(
            'Batch commit selesai. Menghitung ulang saldo untuk dompet: $affectedWallets - method: sisipkanAtauPerbaruiBatch',
          );

          for (String dompetId in affectedWallets) {
            await _recalculateAndUpdateDompetSaldo(dompetId, txn);
          }
        },
        dariServer: dariServer,
      );
      Log.info(
        'Proses Batch transaksi berhasil sepenuhnya - method: sisipkanAtauPerbaruiBatch',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal menjalankan Batch transaksi. Error: $e - method: sisipkanAtauPerbaruiBatch',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil beberapa [TransaksiModel] berdasarkan daftar [ids].
  Future<List<TransaksiModel>> getTransaksiByIds(final List<String> ids) async {
    if (ids.isEmpty) {
      Log.warning(
        'Pencarian Batch ID dibatalkan karena list ID kosong - method: getTransaksiByIds',
      );
      return [];
    }
    final db = await _db;
    try {
      Log.info(
        'Mengambil transaksi berdasarkan list ID: $ids - method: getTransaksiByIds',
      );
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} transaksi dari list ID - method: getTransaksiByIds',
      );
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error(
        'Error saat ambil transaksi by IDs: $e - method: getTransaksiByIds',
        e: e,
        st: st,
      );
      return [];
    }
  }
}

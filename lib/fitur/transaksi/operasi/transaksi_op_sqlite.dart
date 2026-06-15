// path: lib/fitur/transaksi/operasi/transaksi_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data transaksi di database lokal.
class TransaksiOpsqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  final String _tabel = NamaTabel.transaksi;
  final _nowEpoch = DateTime.now().millisecondsSinceEpoch;
  final _nowUtc = DateTime.now().toUtc();

  TransaksiOpsqlite({
    required this.sqliteDb,
    required this.baseOpSqlite,
  });

  Future<Database> get _sqliteDb async => await sqliteDb.database;

  /// Menghitung ulang saldo dompet berdasarkan semua transaksi terkait dan memperbaruinya.
  /// Operasi ini harus dijalankan di dalam sebuah transaksi database [txn].
  Future<void> _recalculateAndUpdateWalletBalance(
    final String idDompet,
    final DatabaseExecutor txn,
  ) async {
    try {
      Log.info('Memulai hitung ulang saldo untuk Wallet ID: $idDompet');

      final totalResult = await txn.rawQuery(
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
        WHERE ${NamaKolom.diHapus} = 0 AND (${NamaKolom.idDompet} = ? OR ${NamaKolom.idDompetTujuan} = ?)
        ''',
        [idDompet, idDompet, idDompet, idDompet, idDompet, idDompet],
      );

      final totalBalance =
          (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

      await txn.update(
        NamaTabel.dompet,
        {
          NamaKolom.saldo: totalBalance,
          NamaKolom.diperbaruiPada: _nowEpoch,
        },
        where: '${NamaKolom.id} = ?',
        whereArgs: [idDompet],
      );

      Log.info(
          'Berhasil update saldo Wallet ID: $idDompet menjadi $totalBalance');
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
      final id = await baseOpSqlite.runComplexOperation<int>(
        (final Transaction txn) async {
          Log.info('Memulai transaksi database untuk addTransaction');
          final data = transaction.copyWith(diperbaruiPada: _nowUtc);

          final newId = await txn.insert(
            _tabel,
            data.toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          Log.info(
              'Data transaksi berhasil masuk ke tabel dengan row ID: $newId');

          await _recalculateAndUpdateWalletBalance(data.idDompet, txn);
          if (data.tipe == TipeTransaksi.transfer &&
              data.idDompetTujuan != null) {
            Log.info(
                'Deteksi transaksi transfer, menghitung saldo wallet tujuan');
            await _recalculateAndUpdateWalletBalance(data.idDompetTujuan!, txn);
          }
          return newId;
        },
        fromServer: fromServer,
      );
      Log.info('Proses addTransaction ID: ${transaction.id} berhasil');
      return id;
    } on Exception catch (e, st) {
      Log.error('Gagal menambah transaksi ID: ${transaction.id}', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua transaksi yang tidak dihapus dari database.
  Future<List<TransaksiModel>> getAllTransactions() async {
    try {
      Log.info('Mengambil data semua transaksi dari SQLite');
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.diHapus} = ?',
        whereArgs: [0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );

      Log.info('Berhasil mengambil ${maps.length} data transaksi dari SQLite');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua transaksi', e: e, s: st);
      return [];
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
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil transaksi ID: $id', e: e, s: st);
      return null;
    }
  }

  /// Mengambil transaksi lunas terbaru dari seorang pengguna.
  Future<TransaksiModel?> getLatestPaidTransactionByUserId(
      final String customerId) async {
    try {
      final db = await _sqliteDb;
      Log.info(
          'Mencari transaksi lunas terbaru untuk pengguna ID: $customerId');

      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where:
            '${NamaKolom.idPelanggan} = ? AND ${NamaKolom.statusPembayaran} = ? AND ${NamaKolom.diHapus} = ?',
        whereArgs: [customerId, StatusPembayaran.paid.name, 0],
        orderBy: '${NamaKolom.tangglberakhir} DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.warning(
            'Tidak ada transaksi lunas yang aktif untuk pengguna ID: $customerId');
        return null;
      }

      Log.info(
          'Transaksi lunas terbaru ditemukan untuk pengguna ID: $customerId');
      return TransaksiModel.fromSqlite(maps.first);
    } on Exception catch (e, st) {
      Log.error(
          'Gagal mengambil transaksi lunas terbaru untuk pengguna ID: $customerId',
          e: e,
          s: st);
      return null;
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransaksiModel>> getByIdPelanggan(
    final String customerId,
  ) async {
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi untuk Customer ID: $customerId');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.idPelanggan} = ? AND ${NamaKolom.diHapus} = ?',
        whereArgs: [customerId, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info(
          'Ditemukan ${maps.length} transaksi untuk Customer ID: $customerId');
      return List.generate(maps.length, (i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error ambil transaksi customer', e: e, s: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan sebuah dompet (baik sebagai sumber maupun tujuan).
  Future<List<TransaksiModel>> getTransactionsByWalletId(
      final String walletId) async {
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi terkait Wallet ID: $walletId');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where:
            '(${NamaKolom.idDompet} = ? OR ${NamaKolom.idDompetTujuan} = ?) AND ${NamaKolom.diHapus} = ?',
        whereArgs: [walletId, walletId, 0],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Ditemukan ${maps.length} transaksi untuk Wallet ID: $walletId');
      return List.generate(maps.length, (final i) {
        return TransaksiModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error ambil transaksi wallet', e: e, s: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket.
  Future<List<TransaksiModel>> getTransactionsByPackageActivation() async {
    try {
      final db = await _sqliteDb;
      Log.info('Mengambil transaksi dengan status isActivated = 1');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.statusAktivasi} = ? AND ${NamaKolom.diHapus} = ?',
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

  /// Memperbarui data transaksi yang ada dan menghitung ulang saldo dompet yang terpengaruh.
  Future<void> updateTransaction(
    final String id,
    final TransaksiModel newTransaction, {
    final bool fromServer = false,
  }) async {
    try {
      await baseOpSqlite.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info('Memulai update transaksi database ID: $id');
          final maps = await txn
              .query(_tabel, where: '${NamaKolom.id} = ?', whereArgs: [id]);

          if (maps.isNotEmpty) {
            final oldTransaction = TransaksiModel.fromSqlite(maps.first);
            final updateData = newTransaction.copyWith(diperbaruiPada: _nowUtc);
            await txn.update(_tabel, updateData.toSqlite(),
                where: '${NamaKolom.id} = ?', whereArgs: [id]);
            Log.info('Data transaksi ID: $id diperbarui');

            final affectedWallets = <String>{};
            affectedWallets.add(oldTransaction.idDompet);
            affectedWallets.add(updateData.idDompet);
            if (oldTransaction.idDompetTujuan != null) {
              affectedWallets.add(oldTransaction.idDompetTujuan!);
            }
            if (updateData.idDompetTujuan != null) {
              affectedWallets.add(updateData.idDompetTujuan!);
            }

            Log.info(
                'Mengupdate saldo untuk wallet yang terpengaruh: $affectedWallets');
            for (final walletId in affectedWallets) {
              await _recalculateAndUpdateWalletBalance(walletId, txn);
            }
          } else {
            Log.warning('Update gagal: Transaksi ID $id tidak ditemukan');
          }
        },
        fromServer: fromServer,
      );
      Log.info('Proses updateTransaction ID: $id selesai');
    } on Exception catch (e, st) {
      Log.error('Gagal update transaksi ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Menandai transaksi sebagai dihapus (soft delete) dan menghitung ulang saldo dompet.
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    try {
      await baseOpSqlite.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info('Memulai soft delete atomik untuk ID: $id');
          final maps = await txn
              .query(_tabel, where: '${NamaKolom.id} = ?', whereArgs: [id]);

          if (maps.isEmpty) {
            Log.warning('Soft delete gagal: Transaksi ID $id tidak ditemukan');
            return;
          }

          final oldTransaction = TransaksiModel.fromSqlite(maps.first);
          await txn.update(
            _tabel,
            {
              NamaKolom.diHapus: 1,
              NamaKolom.diperbaruiPada: _nowEpoch,
              NamaKolom.diarsipkanPada: _nowEpoch,
            },
            where: '${NamaKolom.id} = ?',
            whereArgs: [id],
          );

          Log.info('Flag isDeleted diatur ke 1 untuk ID: $id');

          await _recalculateAndUpdateWalletBalance(
              oldTransaction.idDompet, txn);
          if (oldTransaction.tipe == TipeTransaksi.transfer &&
              oldTransaction.idDompetTujuan != null) {
            await _recalculateAndUpdateWalletBalance(
                oldTransaction.idDompetTujuan!, txn);
          }
        },
        fromServer: fromServer,
      );
      Log.info('Transaksi ID: $id berhasil diarsipkan secara atomik');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan transaksi ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Menandai semua transaksi sebagai dihapus dan mereset saldo semua dompet menjadi 0.
  Future<int> softDeleteAll({final bool fromServer = false}) async {
    try {
      final count = await baseOpSqlite.runComplexOperation<int>(
        (final Transaction txn) async {
          Log.warning('Memulai soft delete semua transaksi secara atomik');
          final rowsAffected = await txn.update(
            _tabel,
            {
              NamaKolom.diHapus: 1,
              NamaKolom.diperbaruiPada: _nowEpoch,
              NamaKolom.diarsipkanPada: _nowEpoch,
            },
            where: '${NamaKolom.diHapus} = ?',
            whereArgs: [0],
          );
          Log.info('$rowsAffected transaksi telah ditandai sebagai dihapus');

          await txn.update(
            NamaTabel.dompet,
            {
              NamaKolom.saldo: 0,
              NamaKolom.diperbaruiPada: _nowEpoch,
            },
          );
          Log.info(
              'Semua saldo dompet direset ke 0 setelah penghapusan massal');

          return rowsAffected;
        },
        fromServer: fromServer,
      );
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal menghapus semua transaksi', e: e, s: st);
      rethrow;
    }
  }

  /// Menghitung total pemasukan (income) dari semua transaksi.
  Future<double> getTotalIncome() async {
    try {
      final db = await _sqliteDb;
      Log.info('Menghitung total seluruh pemasukan');
      final result = await db.rawQuery(
          "SELECT SUM(${NamaKolom.jumlah}) as total FROM $_tabel WHERE ${NamaKolom.tipe} = 'income' AND ${NamaKolom.diHapus} = 0");
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
  Future<double> getTotalExpense() async {
    try {
      final db = await _sqliteDb;
      Log.info('Menghitung total seluruh pengeluaran');
      final result = await db.rawQuery(
          "SELECT SUM(${NamaKolom.jumlah}) as total FROM $_tabel WHERE ${NamaKolom.tipe} = 'expense' AND ${NamaKolom.diHapus} = 0");
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
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    final net = income - expense;
    Log.info('Hasil Net Total: $net');
    return net;
  }

  /// Menghitung total poin yang diperoleh seorang pelanggan.
  Future<int> getEarnedPoints(final String customerId) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung poin yang dihasilkan Customer: $customerId');
      final result = await db.rawQuery(
          'SELECT SUM(${NamaKolom.poinDidapat}) as total FROM $_tabel WHERE ${NamaKolom.idPelanggan} = ? AND ${NamaKolom.diHapus} = 0 AND ${NamaKolom.statusPembayaran} = ?',
          [customerId, StatusPembayaran.paid.name]);
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin dihasilkan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin dihasilkan', e: e, s: st);
      return 0;
    }
  }

  /// Menghitung total poin yang digunakan seorang pelanggan.
  Future<int> getUsedPoints(final String customerId) async {
    try {
      final db = await sqliteDb.database;
      Log.info('Menghitung poin yang digunakan Customer: $customerId');
      final result = await db.rawQuery(
          'SELECT SUM(${NamaKolom.poinDigunakan}) as total FROM $_tabel WHERE ${NamaKolom.idPelanggan} = ? AND ${NamaKolom.diHapus} = 0 AND ${NamaKolom.statusPembayaran} = ?',
          [customerId, StatusPembayaran.paid.name]);
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin digunakan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin digunakan', e: e, s: st);
      return 0;
    }
  }

  /// Menghitung total saldo poin seorang pelanggan.
  Future<int> ambilTotalPoin(String customerId) async {
    Log.info('Menghitung saldo poin akhir Customer: $customerId');
    final earnedPoints = await getEarnedPoints(customerId);
    final usedPoints = await getUsedPoints(customerId);
    final total = earnedPoints - usedPoints;
    Log.info(
        'Saldo poin akhir Customer $customerId: $total (earned=$earnedPoints, used=$usedPoints)');
    return total;
  }

  /// Memasukkan atau memperbarui beberapa transaksi sekaligus (batch) dan menghitung ulang saldo dompet yang terpengaruh.
  Future<void> insertOrUpdateBatch(
    final List<TransaksiModel> items, {
    final bool fromServer = false,
  }) async {
    if (items.isEmpty) {
      Log.warning('Batch dibatalkan karena daftar transaksi kosong');
      return;
    }
    final Set<String> affectedWallets = {};

    try {
      await baseOpSqlite.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info(
              'Memulai proses Batch insert/update untuk ${items.length} item');
          final batch = txn.batch();
          for (final item in items) {
            batch.insert(
              _tabel,
              item.copyWith(diperbaruiPada: _nowUtc).toSqlite(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            affectedWallets.add(item.idDompet);
            if (item.idDompetTujuan != null) {
              affectedWallets.add(item.idDompetTujuan!);
            }
          }
          await batch.commit(noResult: true);
          Log.info(
              'Batch commit selesai. Menghitung ulang saldo untuk wallet: $affectedWallets');

          for (final walletId in affectedWallets) {
            await _recalculateAndUpdateWalletBalance(walletId, txn);
          }
        },
        fromServer: fromServer,
      );
      Log.info('Proses Batch transaksi berhasil sepenuhnya');
    } on Exception catch (e, st) {
      Log.error('Gagal menjalankan Batch transaksi', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil beberapa transaksi berdasarkan daftar ID.
  Future<List<TransaksiModel>> getTransactionsByIds(
      final List<String> ids) async {
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

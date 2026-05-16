// path: lib/shared/operasi/transaction_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari TransaksiOperasi menjadi TransactionOperation.
// diubah: Menggunakan BaseOperation dan TransactionModel.

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data transaksi di database lokal.
class TransactionOperation {
  /// Instance dari `DatabaseHelper` untuk mengakses database SQLite.
  final DatabaseHelper dbHelper;

  /// Instance dari `BaseOperation` untuk operasi CRUD umum.
  final BaseOperation _baseOperation;

  /// Konstruktor untuk `TransactionOperation`.
  ///
  /// Menerima instance `DatabaseHelper` dan `BaseOperation`
  /// secara opsional untuk kemudahan pengujian (dependency injection).
  TransactionOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('TransactionOperation diinisialisasi');
  }

  Future<Database> get _db async => await dbHelper.database;

  // ===================================================================
  // -- METODE PRIVATE --
  // ===================================================================

  Future<void> _recalculateAndUpdateWalletBalance(
    final String walletId,
    final DatabaseExecutor txn,
  ) async {
    try {
      Log.info('Memulai hitung ulang saldo untuk Wallet ID: $walletId');

      final totalResult = await txn.rawQuery(
        '''
        SELECT
          COALESCE(SUM(
            CASE
              WHEN ${ColumnNames.type} = 'income'
                AND ${ColumnNames.walletId} = ?
              THEN ${ColumnNames.amount}

              WHEN ${ColumnNames.type} = 'expense'
                AND ${ColumnNames.walletId} = ?
              THEN -${ColumnNames.amount}

              WHEN ${ColumnNames.type} = 'transfer'
                AND ${ColumnNames.walletId} = ?
              THEN -${ColumnNames.amount}

              WHEN ${ColumnNames.type} = 'transfer'
                AND ${ColumnNames.destinationWalletId} = ?
              THEN ${ColumnNames.amount}

              ELSE 0
            END
          ), 0) as total
        FROM transaksi
        WHERE ${ColumnNames.isDeleted} = 0 AND (${ColumnNames.walletId} = ? OR ${ColumnNames.destinationWalletId} = ?)
        ''',
        [walletId, walletId, walletId, walletId, walletId, walletId],
      );

      final totalBalance =
          (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

      await txn.update(
        'dompet',
        {
          ColumnNames.balance: totalBalance,
          ColumnNames.updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        },
        where: '${ColumnNames.id} = ?',
        whereArgs: [walletId],
      );

      Log.info(
          'Berhasil update saldo Wallet ID: $walletId menjadi $totalBalance');
    } on Exception catch (e, st) {
      Log.error('Gagal hitung ulang saldo Wallet ID: $walletId', e: e, st: st);
      rethrow;
    }
  }

  // ===================================================================
  // -- OPERASI DASAR CRUD (Create, Read, Update, Delete) --
  // ===================================================================

  /// Menambah [TransactionModel] baru ke database.
  Future<int> addTransaction(
    final TransactionModel transaction, {
    final bool fromServer = false,
  }) async {
    try {
      final id = await _baseOperation.runComplexOperation<int>(
        (final Transaction txn) async {
          Log.info('Memulai transaksi database untuk addTransaction');
          final data = transaction.copyWith(updatedAt: DateTime.now().toUtc());

          final newId = await txn.insert(
            'transaksi',
            data.toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          Log.info(
              'Data transaksi berhasil masuk ke tabel dengan row ID: $newId');

          await _recalculateAndUpdateWalletBalance(data.walletId, txn);
          if (data.type == TransactionType.transfer &&
              data.destinationWalletId != null) {
            Log.info(
                'Deteksi transaksi transfer, menghitung saldo wallet tujuan');
            await _recalculateAndUpdateWalletBalance(
                data.destinationWalletId!, txn);
          }
          return newId;
        },
        fromServer: fromServer,
      );
      Log.info('Proses addTransaction ID: ${transaction.id} berhasil');
      return id;
    } on Exception catch (e, st) {
      Log.error('Gagal menambah transaksi ID: ${transaction.id}', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua transaksi dari database.
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      Log.info('Mengambil data semua transaksi dari SQLite');
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '${ColumnNames.isDeleted} = ?',
        whereArgs: [0],
        orderBy: '${ColumnNames.date} DESC',
      );

      Log.info('Berhasil mengambil ${maps.length} data transaksi dari SQLite');
      return List.generate(maps.length, (final i) {
        return TransactionModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil semua transaksi', e: e, st: st);
      return [];
    }
  }

  /// Mengambil [TransactionModel] berdasarkan [id].
  Future<TransactionModel?> getTransactionById(final String id) async {
    final db = await _db;
    try {
      Log.info('Mencari transaksi berdasarkan ID: $id');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.warning('Transaksi dengan ID: $id tidak ditemukan');
        return null;
      }

      Log.info('Transaksi ID: $id ditemukan');
      return TransactionModel.fromSqlite(maps.first);
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil transaksi ID: $id', e: e, st: st);
      return null;
    }
  }

  /// Mengambil semua transaksi yang terkait dengan [customerId].
  Future<List<TransactionModel>> getTransactionsByCustomerId(
    final String customerId,
  ) async {
    final db = await _db;
    try {
      Log.info('Mengambil transaksi untuk Customer ID: $customerId');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '${ColumnNames.customerId} = ? AND ${ColumnNames.isDeleted} = ?',
        whereArgs: [customerId, 0],
        orderBy: '${ColumnNames.date} DESC',
      );
      Log.info(
          'Ditemukan ${maps.length} transaksi untuk Customer ID: $customerId');
      return List.generate(maps.length, (final i) {
        return TransactionModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error ambil transaksi customer', e: e, st: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang terkait dengan [walletId].
  Future<List<TransactionModel>> getTransactionsByWalletId(
      final String walletId) async {
    final db = await _db;
    try {
      Log.info('Mengambil transaksi terkait Wallet ID: $walletId');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where:
            '(${ColumnNames.walletId} = ? OR ${ColumnNames.destinationWalletId} = ?) AND ${ColumnNames.isDeleted} = ?',
        whereArgs: [walletId, walletId, 0],
        orderBy: '${ColumnNames.date} DESC',
      );
      Log.info('Ditemukan ${maps.length} transaksi untuk Wallet ID: $walletId');
      return List.generate(maps.length, (final i) {
        return TransactionModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error ambil transaksi wallet', e: e, st: st);
      return [];
    }
  }

  /// Mengambil semua transaksi yang merupakan aktivasi paket.
  Future<List<TransactionModel>> getTransactionsByPackageActivation() async {
    final db = await _db;
    try {
      Log.info('Mengambil transaksi dengan status isActivated = 1');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where:
            '${ColumnNames.isActivated} = ? AND ${ColumnNames.isDeleted} = ?',
        whereArgs: [1, 0],
        orderBy: '${ColumnNames.date} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} transaksi aktivasi paket');
      return List.generate(maps.length, (final i) {
        return TransactionModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error saat mengambil transaksi aktivasi paket', e: e, st: st);
      return [];
    }
  }

  /// Memperbarui [TransactionModel] di database berdasarkan [id].
  Future<void> updateTransaction(
    final String id,
    final TransactionModel newTransaction, {
    final bool fromServer = false,
  }) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info('Memulai update transaksi database ID: $id');
          final maps = await txn.query('transaksi',
              where: '${ColumnNames.id} = ?', whereArgs: [id]);

          if (maps.isNotEmpty) {
            final oldTransaction = TransactionModel.fromSqlite(maps.first);
            final updateData =
                newTransaction.copyWith(updatedAt: DateTime.now().toUtc());

            await txn.update('transaksi', updateData.toSqlite(),
                where: '${ColumnNames.id} = ?', whereArgs: [id]);
            Log.info('Data transaksi ID: $id diperbarui');

            final affectedWallets = <String>{};
            affectedWallets.add(oldTransaction.walletId);
            affectedWallets.add(updateData.walletId);
            if (oldTransaction.destinationWalletId != null) {
              affectedWallets.add(oldTransaction.destinationWalletId!);
            }
            if (updateData.destinationWalletId != null) {
              affectedWallets.add(updateData.destinationWalletId!);
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
      Log.error('Gagal update transaksi ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan [TransactionModel] berdasarkan [id] (soft delete).
  Future<void> archiveTransaction(final String id,
      {final bool fromServer = false}) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info('Memulai proses pengarsipan (Soft Delete) ID: $id');
          final maps = await txn.query('transaksi',
              where: '${ColumnNames.id} = ?', whereArgs: [id]);

          if (maps.isNotEmpty) {
            final oldTransaction = TransactionModel.fromSqlite(maps.first);
            final now = DateTime.now().toUtc();
            await txn.update(
              'transaksi',
              {
                ColumnNames.isDeleted: 1,
                ColumnNames.updatedAt: now.millisecondsSinceEpoch,
                ColumnNames.archivedAt: now.millisecondsSinceEpoch,
              },
              where: '${ColumnNames.id} = ?',
              whereArgs: [id],
            );
            Log.info('Flag isDeleted diatur ke 1 untuk ID: $id');

            await _recalculateAndUpdateWalletBalance(
                oldTransaction.walletId, txn);
            if (oldTransaction.type == TransactionType.transfer &&
                oldTransaction.destinationWalletId != null) {
              await _recalculateAndUpdateWalletBalance(
                  oldTransaction.destinationWalletId!, txn);
            }
          } else {
            Log.warning('Arsip gagal: Transaksi ID $id tidak ditemukan');
          }
        },
        fromServer: fromServer,
      );
      Log.info('Transaksi ID: $id berhasil diarsipkan');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan transaksi ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Menghapus semua transaksi dengan melakukan soft delete.
  Future<void> archiveAllTransactions({final bool fromServer = false}) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.warning('Memulai penghapusan semua transaksi (soft delete)');
          final now = DateTime.now().toUtc();
          final rowsAffected = await txn.update(
            'transaksi',
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.updatedAt: now.millisecondsSinceEpoch,
              ColumnNames.archivedAt: now.millisecondsSinceEpoch,
            },
            where: '${ColumnNames.isDeleted} = ?',
            whereArgs: [0],
          );

          Log.info('$rowsAffected transaksi telah ditandai sebagai dihapus');
          await txn.update('dompet', {ColumnNames.balance: 0});
        },
        fromServer: fromServer,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menghapus semua transaksi', e: e, st: st);
      rethrow;
    }
  }

  /// Mendapatkan total pemasukan dari semua transaksi.
  Future<double> getTotalIncome() async {
    final db = await _db;
    try {
      Log.info('Menghitung total seluruh pemasukan');
      final result = await db.rawQuery(
          "SELECT SUM(${ColumnNames.amount}) as total FROM transaksi WHERE ${ColumnNames.type} = 'income' AND ${ColumnNames.isDeleted} = 0");
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      Log.info('Total pemasukan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total pemasukan', e: e, st: st);
      return 0.0;
    }
  }

  /// Mendapatkan total pengeluaran dari semua transaksi.
  Future<double> getTotalExpense() async {
    final db = await _db;
    try {
      Log.info('Menghitung total seluruh pengeluaran');
      final result = await db.rawQuery(
          "SELECT SUM(${ColumnNames.amount}) as total FROM transaksi WHERE ${ColumnNames.type} = 'expense' AND ${ColumnNames.isDeleted} = 0");
      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }
      Log.info('Total pengeluaran: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung total pengeluaran', e: e, st: st);
      return 0.0;
    }
  }

  /// Mendapatkan total bersih (pemasukan - pengeluaran).
  Future<double> getNetTotal() async {
    Log.info('Menghitung Net Total (Pemasukan - Pengeluaran)');
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    final net = income - expense;
    Log.info('Hasil Net Total: $net');
    return net;
  }

  /// Mendapatkan total poin yang dihasilkan oleh [customerId].
  Future<int> getEarnedPoints(final String customerId) async {
    final db = await dbHelper.database;
    try {
      Log.info('Menghitung poin yang dihasilkan Customer: $customerId');
      final result = await db.rawQuery(
          'SELECT SUM(${ColumnNames.earnedPoints}) as total FROM transaksi WHERE ${ColumnNames.customerId} = ? AND ${ColumnNames.isDeleted} = 0',
          [customerId]);
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin dihasilkan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin dihasilkan', e: e, st: st);
      return 0;
    }
  }

  /// Mendapatkan total poin yang digunakan oleh [customerId].
  Future<int> getUsedPoints(final String customerId) async {
    final db = await dbHelper.database;
    try {
      Log.info('Menghitung poin yang digunakan Customer: $customerId');
      final result = await db.rawQuery(
          'SELECT SUM(${ColumnNames.usedPoints}) as total FROM transaksi WHERE ${ColumnNames.customerId} = ? AND ${ColumnNames.isDeleted} = 0',
          [customerId]);
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin digunakan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin digunakan', e: e, st: st);
      return 0;
    }
  }

  /// Mendapatkan total poin yang dimiliki oleh [customerId].
  Future<int> getTotalPoints(final String customerId) async {
    Log.info('Menghitung saldo poin akhir Customer: $customerId');
    final earnedPoints = await getEarnedPoints(customerId);
    final usedPoints = await getUsedPoints(customerId);
    final total = earnedPoints - usedPoints;
    Log.info('Saldo poin akhir: $total');
    return total;
  }

  /// Menyisipkan atau memperbarui sekumpulan [TransactionModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<TransactionModel> items, {
    final bool fromServer = false,
  }) async {
    final Set<String> affectedWallets = {};

    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info(
              'Memulai proses Batch insert/update untuk ${items.length} item');
          final batch = txn.batch();
          for (final item in items) {
            batch.insert(
              'transaksi',
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            affectedWallets.add(item.walletId);
            if (item.destinationWalletId != null) {
              affectedWallets.add(item.destinationWalletId!);
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
      Log.error('Gagal menjalankan Batch transaksi', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [TransactionModel] berdasarkan daftar [ids].
  Future<List<TransactionModel>> getTransactionsByIds(
      final List<String> ids) async {
    if (ids.isEmpty) {
      Log.warning('Pencarian Batch ID dibatalkan karena list ID kosong');
      return [];
    }
    final db = await _db;
    try {
      Log.info('Mengambil transaksi berdasarkan list ID: $ids');
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'transaksi',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} transaksi dari list ID');
      return List.generate(maps.length, (final i) {
        return TransactionModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, st) {
      Log.error('Error saat ambil transaksi by IDs', e: e, st: st);
      return [];
    }
  }
}

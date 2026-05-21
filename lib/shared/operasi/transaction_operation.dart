// path: lib/shared/operasi/transaction_operation.dart
// diubah: Menambahkan fungsi getLatestPaidTransactionByUserId.
// diperbaiki: Menggabungkan operasi soft delete dan kalkulasi saldo dalam satu transaksi atomik.
// diperbaiki: Memperbaiki typo Columnames menjadi ColumnNames.

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data transaksi di database lokal.
class TransactionOperation {
  /// Instance dari `DatabaseHelper` untuk mengakses database SQLite.
  final DatabaseHelper dbHelper;

  /// Instance dari `BaseOperation` untuk operasi CRUD umum.
  final BaseOperation _baseOperation;

  final String _tableName = TableNameValue.get(TableName.transactions);

  /// Konstruktor untuk `TransactionOperation`.
  TransactionOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('TransactionOperation diinisialisasi');
  }

  Future<Database> get _db async => await dbHelper.database;

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
        FROM $_tableName
        WHERE ${ColumnNames.isDeleted} = 0 AND (${ColumnNames.walletId} = ? OR ${ColumnNames.destinationWalletId} = ?)
        ''',
        [walletId, walletId, walletId, walletId, walletId, walletId],
      );

      final totalBalance =
          (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

      await txn.update(
        TableNameValue.get(TableName.wallet),
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
            _tableName,
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

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      Log.info('Mengambil data semua transaksi dari SQLite');
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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

  Future<TransactionModel?> getTransactionById(final String id) async {
    try {
      final db = await _db;
      Log.info('Mencari transaksi berdasarkan ID: $id');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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

  Future<TransactionModel?> getLatestPaidTransactionByUserId(
      final String customerId) async {
    try {
      final db = await _db;
      Log.info(
          'Mencari transaksi lunas terbaru untuk pengguna ID: $customerId');

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where:
            '${ColumnNames.customerId} = ? AND ${ColumnNames.paymentStatus} = ? AND ${ColumnNames.isDeleted} = ?',
        whereArgs: [customerId, PaymentStatus.paid.name, 0],
        orderBy: '${ColumnNames.endDate} DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        Log.warning(
            'Tidak ada transaksi lunas yang aktif untuk pengguna ID: $customerId');
        return null;
      }

      Log.info(
          'Transaksi lunas terbaru ditemukan untuk pengguna ID: $customerId');
      return TransactionModel.fromSqlite(maps.first);
    } on Exception catch (e, st) {
      Log.error(
          'Gagal mengambil transaksi lunas terbaru untuk pengguna ID: $customerId',
          e: e,
          st: st);
      return null;
    }
  }

  Future<List<TransactionModel>> getTransactionsByCustomerId(
    final String customerId,
  ) async {
    try {
      final db = await _db;
      Log.info('Mengambil transaksi untuk Customer ID: $customerId');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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

  Future<List<TransactionModel>> getTransactionsByWalletId(
      final String walletId) async {
    try {
      final db = await _db;
      Log.info('Mengambil transaksi terkait Wallet ID: $walletId');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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

  Future<List<TransactionModel>> getTransactionsByPackageActivation() async {
    try {
      final db = await _db;
      Log.info('Mengambil transaksi dengan status isActivated = 1');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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

  Future<void> updateTransaction(
    final String id,
    final TransactionModel newTransaction, {
    final bool fromServer = false,
  }) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info('Memulai update transaksi database ID: $id');
          final maps = await txn.query(_tableName,
              where: '${ColumnNames.id} = ?', whereArgs: [id]);

          if (maps.isNotEmpty) {
            final oldTransaction = TransactionModel.fromSqlite(maps.first);
            final updateData =
                newTransaction.copyWith(updatedAt: DateTime.now().toUtc());

            await txn.update(_tableName, updateData.toSqlite(),
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

  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info('Memulai soft delete atomik untuk ID: $id');
          final maps = await txn.query(_tableName,
              where: '${ColumnNames.id} = ?', whereArgs: [id]);

          if (maps.isEmpty) {
            Log.warning('Soft delete gagal: Transaksi ID $id tidak ditemukan');
            return;
          }

          final oldTransaction = TransactionModel.fromSqlite(maps.first);
          final now = DateTime.now().toUtc().millisecondsSinceEpoch;

          await txn.update(
            _tableName,
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.updatedAt: now,
              ColumnNames.archivedAt: now,
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
        },
        fromServer: fromServer,
      );
      Log.info('Transaksi ID: $id berhasil diarsipkan secara atomik');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan transaksi ID: $id', e: e, st: st);
      rethrow;
    }
  }

  Future<int> softDeleteAll({final bool fromServer = false}) async {
    try {
      final count = await _baseOperation.runComplexOperation<int>(
        (final Transaction txn) async {
          Log.warning('Memulai soft delete semua transaksi secara atomik');
          final now = DateTime.now().toUtc();

          final rowsAffected = await txn.update(
            _tableName,
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.updatedAt: now.millisecondsSinceEpoch,
              ColumnNames.archivedAt: now.millisecondsSinceEpoch,
            },
            where: '${ColumnNames.isDeleted} = ?',
            whereArgs: [0],
          );
          Log.info('$rowsAffected transaksi telah ditandai sebagai dihapus');

          await txn.update(
            TableNameValue.get(TableName.wallet),
            {
              ColumnNames.balance: 0,
              ColumnNames.updatedAt: now.millisecondsSinceEpoch,
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
      Log.error('Gagal menghapus semua transaksi', e: e, st: st);
      rethrow;
    }
  }

  Future<double> getTotalIncome() async {
    try {
      final db = await _db;
      Log.info('Menghitung total seluruh pemasukan');
      final result = await db.rawQuery(
          "SELECT SUM(${ColumnNames.amount}) as total FROM $_tableName WHERE ${ColumnNames.type} = 'income' AND ${ColumnNames.isDeleted} = 0");
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

  Future<double> getTotalExpense() async {
    try {
      final db = await _db;
      Log.info('Menghitung total seluruh pengeluaran');
      final result = await db.rawQuery(
          "SELECT SUM(${ColumnNames.amount}) as total FROM $_tableName WHERE ${ColumnNames.type} = 'expense' AND ${ColumnNames.isDeleted} = 0");
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

  Future<double> getNetTotal() async {
    Log.info('Menghitung Net Total (Pemasukan - Pengeluaran)');
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    final net = income - expense;
    Log.info('Hasil Net Total: $net');
    return net;
  }

  Future<int> getEarnedPoints(final String customerId) async {
    try {
      final db = await dbHelper.database;
      Log.info('Menghitung poin yang dihasilkan Customer: $customerId');
      final result = await db.rawQuery(
          'SELECT SUM(${ColumnNames.earnedPoints}) as total FROM $_tableName WHERE ${ColumnNames.customerId} = ? AND ${ColumnNames.isDeleted} = 0',
          [customerId]);
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin dihasilkan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin dihasilkan', e: e, st: st);
      return 0;
    }
  }

  Future<int> getUsedPoints(final String customerId) async {
    try {
      final db = await dbHelper.database;
      Log.info('Menghitung poin yang digunakan Customer: $customerId');
      final result = await db.rawQuery(
          'SELECT SUM(${ColumnNames.usedPoints}) as total FROM $_tableName WHERE ${ColumnNames.customerId} = ? AND ${ColumnNames.isDeleted} = 0',
          [customerId]);
      final total = result.first['total'] as int? ?? 0;
      Log.info('Poin digunakan: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Error hitung poin digunakan', e: e, st: st);
      return 0;
    }
  }

  Future<int> getTotalPoints(final String customerId) async {
    Log.info('Menghitung saldo poin akhir Customer: $customerId');
    final earnedPoints = await getEarnedPoints(customerId);
    final usedPoints = await getUsedPoints(customerId);
    final total = earnedPoints - usedPoints;
    Log.info(
        'Saldo poin akhir Customer $customerId: $total (earned=$earnedPoints, used=$usedPoints)');
    return total;
  }

  Future<void> insertOrUpdateBatch(
    final List<TransactionModel> items, {
    final bool fromServer = false,
  }) async {
    if (items.isEmpty) {
      Log.warning('Batch dibatalkan karena daftar transaksi kosong');
      return;
    }
    final Set<String> affectedWallets = {};

    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          Log.info(
              'Memulai proses Batch insert/update untuk ${items.length} item');
          final batch = txn.batch();
          for (final item in items) {
            batch.insert(
              _tableName,
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

  Future<List<TransactionModel>> getTransactionsByIds(
      final List<String> ids) async {
    if (ids.isEmpty) {
      Log.warning('Pencarian Batch ID dibatalkan karena list ID kosong');
      return [];
    }
    try {
      final db = await _db;
      Log.info('Mengambil transaksi berdasarkan list ID: $ids');
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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

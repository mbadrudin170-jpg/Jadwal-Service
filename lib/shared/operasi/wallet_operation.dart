// path: lib/shared/operasi/wallet_operation.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

final walletOperationProvider = Provider<WalletOperation>((ref) {
  Log.info('Membuat instance FeedbackOperation...');
  final dbHelper = ref.read(databaseHelperProvider);
  final baseOperation = ref.read(baseOperationProvider);

  return WalletOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
});

/// Kelas untuk operasi terkait data dompet di database lokal.
class WalletOperation {
  /// Instance dari DatabaseHelper dan BaseOperation untuk mengakses database.
  final DatabaseHelper dbHelper;
  final BaseOperation _baseOperation;
  final String _tableName = TableNameValue.get(TableName.wallet);
  final _nowUtc = DateTime.now().toUtc();

  /// Konstruktor dengan injeksi dependensi untuk pengujian.
  WalletOperation({
    required this.dbHelper,
    required final BaseOperation baseOperation,
  }) : _baseOperation = baseOperation;

  Future<void> createWallet(
    final WalletModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createWallet untuk wallet: ${wallet.id}');
    try {
      final data = wallet.copyWith(updatedAt: _nowUtc).toSqlite();
      await _baseOperation.insert(
        _tableName,
        data,
        fromServer: fromServer,
      );
      Log.info('Berhasil membuat wallet dengan ID: ${wallet.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat createWallet', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua dompet dari database.
  ///
  /// Jika [showArchived] `true`, maka dompet yang telah diarsipkan juga akan diambil.
  Future<List<WalletModel>> getWallets({
    final bool showArchived = false,
  }) async {
    Log.info('Memulai getWallets (showArchived: $showArchived).');
    try {
      final db = await dbHelper.database;
      final query = showArchived
          ? null
          : '${ColumnNames.isDeleted} = 0 AND ${ColumnNames.archivedAt} IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: query,
      );

      final listWallet = List.generate(
        maps.length,
        (final i) => WalletModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listWallet.length} data wallet.');
      return listWallet;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getWallets', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [WalletModel] berdasarkan [id].
  Future<WalletModel?> getWalletById(final String id) async {
    Log.info('Memulai getWalletById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} = ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final wallet = WalletModel.fromSqlite(maps.first);
        Log.info('Wallet dengan ID: $id ditemukan.');
        return wallet;
      }

      Log.warning('Wallet dengan ID: $id tidak ditemukan di database.');
      return null;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat getWalletById untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [WalletModel] yang ada di database.
  Future<void> updateWallet(
    final WalletModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai updateWallet untuk wallet ID: ${wallet.id}');
    try {
      final data = wallet.copyWith(updatedAt: _nowUtc).toSqlite();
      await _baseOperation.update(
        _tableName,
        data,
        wallet.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updateWallet untuk ID: ${wallet.id}.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat updateWallet untuk ID: ${wallet.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua dompet dari database secara permanen.
  Future<void> deleteAllWallets({final bool fromServer = false}) async {
    Log.warning(
        'PERINGATAN: Memulai deleteAllWallets. Ini adalah operasi destruktif.');
    try {
      await dbHelper.database;
      await _baseOperation.runComplexOperation<void>(
        (final txn) async {
          final count = await txn.delete(_tableName);
          Log.info(
              'Berhasil deleteAllWallets. Total baris yang dihapus: $count');
        },
        fromServer: fromServer,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal saat deleteAllWallets', e: e, st: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada satu dompet berdasarkan [id].
  Future<void> softDelete(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk wallet ID: $id');
    try {
      await _baseOperation.softDelete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft delete wallet ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat soft delete wallet ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua dompet.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua dompet');
    try {
      final count = await _baseOperation.softDeleteAll(
        _tableName,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft delete semua dompet. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error(
        'Gagal saat soft delete semua dompet',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghitung total saldo dari semua dompet aktif.
  Future<double> getTotalBalance() async {
    Log.info(
        'Memulai getTotalBalance (menghitung total saldo dari semua wallet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(${ColumnNames.balance}) as total FROM $_tableName WHERE ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getTotalBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total saldo positif dari semua dompet aktif.
  Future<double> getPositiveBalance() async {
    Log.info(
        'Memulai getPositiveBalance (menghitung total saldo > 0 dari wallet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(${ColumnNames.balance}) as total FROM $_tableName WHERE ${ColumnNames.balance} > 0 AND ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getPositiveBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total saldo negatif dari semua dompet aktif.
  Future<double> getNegativeBalance() async {
    Log.info(
        'Memulai getNegativeBalance (menghitung total saldo < 0 dari wallet aktif).');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(${ColumnNames.balance}) as total FROM $_tableName WHERE ${ColumnNames.balance} < 0 AND ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getNegativeBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan dompet dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<WalletModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} data dompet.');
    if (items.isEmpty) {
      Log.warning('Daftar dompet kosong, membatalkan operasi batch.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) => item.copyWith(updatedAt: _nowUtc).toSqlite(),
          )
          .toList();
      await _baseOperation.insertOrUpdateBatch(
        _tableName,
        data,
        fromServer: fromServer,
      );
      Log.info('Batch dompet selesai diproses.');
    } on Exception catch (e, st) {
      Log.error('Gagal menjalankan batch dompet', e: e, st: st);
      rethrow;
    }
  }
}

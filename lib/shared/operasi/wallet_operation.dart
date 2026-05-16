// path: lib/shared/operasi/wallet_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Menambahkan konstruktor yang dapat diinjeksi untuk pengujian.
// diubah: Mengganti nama class dari DompetOperasi menjadi WalletOperation.
// diubah: Menggunakan BaseOperation (bukan OperasiDasar) dan WalletModel (bukan DompetModel).

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data dompet di database lokal.
class WalletOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  late final DatabaseHelper dbHelper;
  late final BaseOperation _baseOperation;

  /// Konstruktor dengan injeksi dependensi untuk pengujian.
  WalletOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('WalletOperation instance dibuat.');
  }

  /// Menyimpan [WalletModel] baru ke dalam database.
  ///
  /// [fromServer] menandakan apakah operasi ini berasal dari sinkronisasi server.
  Future<void> createWallet(
    final WalletModel wallet, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createWallet untuk wallet: ${wallet.toSqlite()}');
    try {
      final data =
          wallet.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.insert('dompet', data, fromServer: fromServer);
      Log.info('Berhasil membuat wallet dengan ID: ${wallet.id}');
    } catch (e, st) {
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
          ? '${ColumnNames.isDeleted} = 0'
          : '${ColumnNames.isDeleted} = 0 AND ${ColumnNames.archivedAt} IS NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: query,
      );

      final listWallet = List.generate(
        maps.length,
        (final i) => WalletModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listWallet.length} data wallet.');
      return listWallet;
    } catch (e, st) {
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
        'dompet',
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
    } catch (e, st) {
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
      final data =
          wallet.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        'dompet',
        data,
        wallet.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updateWallet untuk ID: ${wallet.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateWallet untuk ID: ${wallet.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengarsipkan semua dompet yang aktif.
  Future<void> archiveAllWallets({final bool fromServer = false}) async {
    Log.info('Memulai proses pengarsipan untuk semua wallet.');
    try {
      final activeWallets = await getWallets();
      Log.info(
          'Ditemukan ${activeWallets.length} wallet aktif untuk diarsipkan.');

      for (final wallet in activeWallets) {
        await updateWallet(
          wallet.copyWith(archivedAt: DateTime.now().toUtc()),
          fromServer: fromServer,
        );
      }

      Log.info('Proses pengarsipan semua wallet telah selesai.');
    } catch (e, st) {
      Log.error(
        'Gagal saat proses pengarsipan massal wallet.',
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
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final count = await txn.delete('dompet');
          Log.info(
              'Berhasil deleteAllWallets. Total baris yang dihapus: $count');
        },
        fromServer: fromServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat deleteAllWallets', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan satu dompet berdasarkan [id] (soft delete).
  Future<void> archiveOneWallet(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai archiveOneWallet (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now().toUtc();
      final Map<String, dynamic> dataToUpdate = {
        ColumnNames.archivedAt: now.millisecondsSinceEpoch,
        ColumnNames.updatedAt: now.millisecondsSinceEpoch,
        ColumnNames.isDeleted: 1,
      };

      await _baseOperation.update(
        'dompet',
        dataToUpdate,
        id,
        fromServer: fromServer,
      );

      Log.info('Berhasil archiveOneWallet untuk ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat archiveOneWallet untuk ID: $id',
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
        'SELECT SUM(${ColumnNames.balance}) as total FROM dompet WHERE ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo: $total');
      return total;
    } catch (e, st) {
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
        'SELECT SUM(${ColumnNames.balance}) as total FROM dompet WHERE ${ColumnNames.balance} > 0 AND ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo positif: $total');
      return total;
    } catch (e, st) {
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
        'SELECT SUM(${ColumnNames.balance}) as total FROM dompet WHERE ${ColumnNames.balance} < 0 AND ${ColumnNames.isDeleted} = 0',
      );

      double total = 0.0;
      if (result.isNotEmpty && result.first['total'] != null) {
        total = (result.first['total'] as num).toDouble();
      }

      Log.info('Berhasil menghitung total saldo negatif: $total');
      return total;
    } catch (e, st) {
      Log.error('Gagal saat getNegativeBalance', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan dompet dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<WalletModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item wallet.');
    if (items.isEmpty) {
      Log.warning(
          'List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = items.map((final item) => item.toSqlite()).toList();
      await _baseOperation.insertOrUpdateBatch(
        'dompet',
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan insertOrUpdateBatch', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [WalletModel] berdasarkan daftar [ids].
  Future<List<WalletModel>> getWalletsByIds(final List<String> ids) async {
    Log.info('Memulai getWalletsByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
          'List ID untuk getWalletsByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'dompet',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );

      final listWallet = List.generate(
        maps.length,
        (final i) => WalletModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil mengambil ${listWallet.length} wallet dari ${ids.length} ID yang diminta.');
      return listWallet;
    } catch (e, st) {
      Log.error('Gagal saat getWalletsByIds', e: e, st: st);
      rethrow;
    }
  }
}

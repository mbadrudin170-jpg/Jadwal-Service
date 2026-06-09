// path: lib/shared/operasi/order_operation.dart
// diperbaiki: Mengganti string literal 'pesanan' dengan konstanta TableNameValue.get(TableName.customerOrder)
// diperbaiki: Menambahkan import table_name_value.dart dan enum

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pesanan di database lokal.
class OrderOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  final BaseOperation baseOperation;

  /// Konstruktor untuk [OrderOperation].
  OrderOperation({
    required this.dbHelper,
    required this.baseOperation,
  });

  /// Mendapatkan nama tabel pesanan dari konstanta.
  String get _tableName => TableNameValue.get(TableName.customerOrder);

  Future<int> getJumlahByStatus(StatusOrderEnum status) async {
    Log.info('Menghitung pesanan dengan status: ${status.name}');
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE ${ColumnNames.status} = ? AND ${ColumnNames.isDeleted} = 0',
        [status.name],
      );
      final count = result.first.values.first as int? ?? 0;
      Log.info(
          'Berhasil menghitung $count data pesanan aktif berstatus ${status.name}.');
      return count;
    } on Exception catch (e, s) {
      Log.error('Gagal menghitung pesanan berdasarkan status.', e: e, st: s);
      rethrow;
    }
  }

  /// Menyimpan [OrderModel] baru ke dalam database.
  Future<void> saveOrder(
    final OrderModel order, {
    final bool fromServer = false,
  }) async {
    Log.info('Menyimpan pesanan baru ID: ${order.id}');
    try {
      final orderToSave = order.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      await baseOperation.insert(
        _tableName,
        orderToSave.toSqlite(),
        fromServer: fromServer,
      );
      Log.info('Berhasil menyimpan pesanan ID: ${order.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan pesanan.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pesanan dari database (termasuk yang sudah di-soft-delete).
  Future<List<OrderModel>> getAllOrders() async {
    Log.info('Mengambil semua pesanan dari database.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: '${ColumnNames.date} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan.');
      return maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pesanan.', e: e, st: s);
      rethrow;
    }
  }

  Stream<List<OrderModel>> getAllActiveOrdersStream() async* {
    Log.info('Mengambil semua pesanan aktif dari database (stream sekali).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.isDeleted} = 0',
        orderBy: '${ColumnNames.date} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan aktif.');
      yield maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pesanan aktif.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil pesanan berdasarkan [status].
  Future<List<OrderModel>> getOrdersByStatus(
      final StatusOrderEnum status) async {
    Log.info('Mengambil pesanan dengan status: ${status.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.status} = ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [status.name],
        orderBy: '${ColumnNames.date} DESC',
      );
      Log.info(
          'Berhasil mengambil ${maps.length} data pesanan aktif berstatus ${status.name}.');
      return maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil pesanan berdasarkan status.', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui status [OrderModel] berdasarkan [id].
  Future<void> updateOrderStatus(
    final String id,
    final StatusOrderEnum status, {
    final bool fromServer = false,
  }) async {
    Log.info('Memperbarui status pesanan ID: $id menjadi ${status.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final oldOrder = OrderModel.fromSqlite(maps.first);
        final newOrder = oldOrder.copyWith(
          status: status,
          updatedAt: DateTime.now().toUtc(),
        );
        await baseOperation.update(
          _tableName,
          newOrder.toSqlite(),
          id,
          fromServer: fromServer,
        );
        Log.info(
          'Status pesanan ID: $id berhasil diperbarui beserta timestamp-nya.',
        );
      } else {
        Log.warning(
          'Gagal memperbarui status: Pesanan dengan ID: $id tidak ditemukan.',
        );
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memperbarui status pesanan.', e: e, st: s);
      rethrow;
    }
  }

  Future<void> deleteOrder(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.warning('Menghapus pesanan ID: $id (hard delete)');
    try {
      await baseOperation.delete(_tableName, id, fromServer: fromServer);
      Log.info('Berhasil menghapus pesanan dengan ID: $id.');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus pesanan.', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada pesanan berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk pesanan ID: $id');
    try {
      await baseOperation.softDelete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft delete pesanan ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete pesanan ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua pesanan.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua pesanan');
    try {
      final count = await baseOperation.softDeleteAll(
        _tableName,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft delete semua pesanan. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua pesanan', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [OrderModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<OrderModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} pesanan.');
    if (items.isEmpty) {
      Log.warning('List item kosong, menghentikan batch pesanan.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await baseOperation.insertOrUpdateBatch(
        _tableName,
        data,
        fromServer: fromServer,
      );
      Log.info('Batch pesanan selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch pesanan.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [OrderModel] berdasarkan daftar [ids].
  Future<List<OrderModel>> getOrdersByIds(final List<String> ids) async {
    Log.info('Mengambil pesanan untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('List ID kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where:
            '${ColumnNames.id} IN (${List.filled(ids.length, '?').join(',')}) AND ${ColumnNames.isDeleted} = 0',
        whereArgs: ids,
      );
      Log.info(
          'Berhasil mengambil ${maps.length} data pesanan berdasarkan daftar ID.');
      return List.generate(maps.length, (final i) {
        return OrderModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil data pesanan berdasarkan daftar ID.',
          e: e, st: s);
      rethrow;
    }
  }
}

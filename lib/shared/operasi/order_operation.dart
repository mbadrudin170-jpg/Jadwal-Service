// path: lib/shared/operasi/order_operation.dart

import 'package:meta/meta.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/order_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pesanan di database lokal.
class OrderOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  @visibleForTesting
  final BaseOperation baseOperation;

  /// Konstruktor untuk [OrderOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  OrderOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        baseOperation = baseOperation ?? BaseOperation();

  /// Menyimpan [OrderModel] baru ke dalam database.
  Future<void> saveOrder(
    final OrderModel order, {
    final bool fromServer = false,
  }) async {
    Log.info('Menyimpan pesanan baru ID: ${order.id}');
    final orderToSave = order.copyWith(
      updatedAt: DateTime.now().toUtc(),
    );
    await baseOperation.insert(
      'pesanan',
      orderToSave.toSqlite(),
      fromServer: fromServer,
    );
  }

  /// Mengambil semua pesanan dari database.
  Future<List<OrderModel>> getAllOrders() async {
    Log.info('Mengambil semua pesanan dari database.');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      orderBy: 'tanggal DESC',
    );
    return maps.map(OrderModel.fromSqlite).toList();
  }

  /// Mengambil pesanan berdasarkan [status].
  Future<List<OrderModel>> getOrdersByStatus(final String status) async {
    Log.info('Mengambil pesanan dengan status: $status');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'tanggal DESC',
    );
    return maps.map(OrderModel.fromSqlite).toList();
  }

  /// Memperbarui status [OrderModel] berdasarkan [id].
  Future<void> updateOrderStatus(
    final String id,
    final String status, {
    final bool fromServer = false,
  }) async {
    Log.info('Memperbarui status pesanan ID: $id menjadi $status');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final oldOrder = OrderModel.fromSqlite(maps.first);
      final newOrder = oldOrder.copyWith(
        status: status,
        updatedAt: DateTime.now().toUtc(),
      );
      await baseOperation.update(
        'pesanan',
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
  }

  /// Menghapus [OrderModel] dari database berdasarkan [id].
  Future<void> deleteOrder(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Menghapus pesanan ID: $id');
    await baseOperation.delete('pesanan', id, fromServer: fromServer);
  }

  /// Menyisipkan atau memperbarui sekumpulan [OrderModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<OrderModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} pesanan.');
    if (items.isEmpty) return;
    final data = items
        .map(
          (final item) =>
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
        )
        .toList();
    await baseOperation.insertOrUpdateBatch(
      'pesanan',
      data,
      fromServer: fromServer,
    );
    Log.info('Batch pesanan selesai.');
  }

  /// Mengambil beberapa [OrderModel] berdasarkan daftar [ids].
  Future<List<OrderModel>> getOrdersByIds(final List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    Log.info('Mengambil pesanan untuk ${ids.length} ID.');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    return List.generate(maps.length, (final i) {
      return OrderModel.fromSqlite(maps[i]);
    });
  }
}

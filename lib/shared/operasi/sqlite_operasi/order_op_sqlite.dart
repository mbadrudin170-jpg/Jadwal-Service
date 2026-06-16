// path: lib/shared/operasi/sqlite_operasi/order_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pesanan di database lokal.
class OrderOpsqlite {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final SqliteDatabase sqliteDb;

  /// Instance dari [BaseOpSqlite] untuk operasi CRUD dasar.
  final BaseOpSqlite baseOpSqlite;

  /// Konstruktor untuk [OrderOpsqlite].
  OrderOpsqlite({
    required this.sqliteDb,
    required this.baseOpSqlite,
  });

  /// Mendapatkan nama tabel pesanan dari konstanta.
  String get _tableName => NamaTabel.pesananPelanggan;

  Future<int> getJumlahByStatus(StatusOrderEnum status) async {
    Log.info('Menghitung pesanan dengan status: ${status.name}');
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE ${NamaKolom.status} = ? AND ${NamaKolom.dihapus} = 0',
        [status.name],
      );
      final count = result.first.values.first as int? ?? 0;
      Log.info(
          'Berhasil menghitung $count data pesanan aktif berstatus ${status.name}.');
      return count;
    } on Exception catch (e, s) {
      Log.error('Gagal menghitung pesanan berdasarkan status.', e: e, s: s);
      rethrow;
    }
  }

  /// Menyimpan [OrderModel] baru ke dalam database.
  Future<void> tambahOrder(
    final OrderModel order, {
    final bool dariServer = false,
  }) async {
    Log.info('Menyimpan pesanan baru ID: ${order.id}');
    try {
      final dataOrderBaru = order.copyWith(
        diperbaruiPada: DateTime.now().toUtc(),
      );
      await baseOpSqlite.sisipkan(
        _tableName,
        dataOrderBaru.toSqlite(),
        dariServer: dariServer,
      );
      Log.info('Berhasil menyimpan pesanan ID: ${order.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan pesanan.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua pesanan dari database (termasuk yang sudah di-soft-delete).
  Future<List<OrderModel>> ambilSemuaOrder() async {
    Log.info('Mengambil semua pesanan dari database.');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan.');
      return maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Stream<List<OrderModel>> getAllActiveOrdersStream() async* {
    Log.info('Mengambil semua pesanan aktif dari database (stream sekali).');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.dihapus} = 0',
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan aktif.');
      yield maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pesanan aktif.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil pesanan berdasarkan [status].
  Future<List<OrderModel>> ambilOrderBerdasarkanStatus(
      StatusOrderEnum status) async {
    Log.info('Mengambil pesanan dengan status: ${status.name}');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.status} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [status.name],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info(
          'Berhasil mengambil ${maps.length} data pesanan aktif berstatus ${status.name}.');
      return maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil pesanan berdasarkan status.', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui status [OrderModel] berdasarkan [id].
  Future<void> updateStatusOrder(
    final String id,
    final StatusOrderEnum status, {
    final bool dariServer = false,
  }) async {
    Log.info('Memperbarui status pesanan ID: $id menjadi ${status.name}');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final orderLama = OrderModel.fromSqlite(maps.first);
        final orderBaru = orderLama.copyWith(
          status: status,
          diperbaruiPada: DateTime.now().toUtc(),
        );
        await baseOpSqlite.update(
          _tableName,
          orderBaru.toSqlite(),
          id,
          dariServer: dariServer,
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
      Log.error('Gagal memperbarui status pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> deleteOrder(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.warning('Menghapus pesanan ID: $id (hard delete)');
    try {
      await baseOpSqlite.delete(_tableName, id, dariServer: fromServer);
      Log.info('Berhasil menghapus pesanan dengan ID: $id.');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus pesanan.', e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada pesanan berdasarkan [id].
  Future<void> softDeleteorder(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk pesanan ID: $id');
    try {
      await baseOpSqlite.softDelete(
        _tableName,
        id,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft delete pesanan ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete pesanan ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua pesanan.
  Future<int> softDeleteAllOrder({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua pesanan');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _tableName,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua pesanan. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua pesanan', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [OrderModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<OrderModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} pesanan.');
    if (items.isEmpty) {
      Log.warning('List item kosong, menghentikan batch pesanan.');
      return;
    }
    try {
      final data = items
          .map(
            (item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tableName,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch pesanan selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch pesanan.', e: e, s: s);
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
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where:
            '${NamaKolom.id} IN (${List.filled(ids.length, '?').join(',')}) AND ${NamaKolom.dihapus} = 0',
        whereArgs: ids,
      );
      Log.info(
          'Berhasil mengambil ${maps.length} data pesanan berdasarkan daftar ID.');
      return List.generate(maps.length, (final i) {
        return OrderModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil data pesanan berdasarkan daftar ID.',
          e: e, s: s);
      rethrow;
    }
  }
}

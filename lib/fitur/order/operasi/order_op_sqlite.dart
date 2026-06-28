// path: lib/fitur/order/operasi/order_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class OrderOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  OrderOpSqlite({required this.sqliteDb, required this.baseOpSqlite});

  String get _namaTabel => NamaTabel.pesananPelanggan;
  DateTime? get _nowUtc => DateTime.now().toUtc();

  Future<void> tambahOrder(
    final OrderModel order, {
    final bool dariServer = false,
  }) async {
    Log.info('Menyimpan pesanan baru ID: ${order.id}');
    try {
      final dataOrderBaru = order.copyWith(diperbaruiPada: _nowUtc);
      await baseOpSqlite.sisipkan(
        _namaTabel,
        dataOrderBaru.toSqlite(),
        dariServer: dariServer,
      );
      Log.info('Berhasil menyimpan pesanan ID: ${order.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(OrderModel order, {bool dariServer = false}) async {
    try {
      final dataBaru = order.copyWith(diperbaruiPada: _nowUtc);
      await baseOpSqlite.update(
        _namaTabel,
        dataBaru.toSqlite(),
        order.id,
        dariServer: dariServer,
      );
      Log.info(
        'Status pesanan ID: $order berhasil diperbarui beserta timestamp-nya.',
      );
    } on Exception catch (e, s) {
      Log.error('Gagal memperbarui status pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<int> ambilTotalDataPerStatus(StatusOrderEnum status) async {
    Log.info('Menghitung pesanan dengan status: ${status.name}');
    try {
      final db = await sqliteDb.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM $_namaTabel WHERE ${NamaKolom.status} = ? AND ${NamaKolom.dihapus} = 0',
        [status.name],
      );
      final count = result.first.values.first as int? ?? 0;
      Log.info(
        'Berhasil menghitung $count data pesanan aktif berstatus ${status.name}.',
      );
      return count;
    } on Exception catch (e, s) {
      Log.error('Gagal menghitung pesanan berdasarkan status.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua pesanan dari database.');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info('Berhasil mengambil ${maps.length} data pesanan.');

      return maps.map(OrderModel.fromSqlite).toList();
    } catch (e, s) {
      Log.error('Gagal mengambil semua pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Stream<List<OrderModel>> ambilStreamSemuaOrderAktif() async* {
    Log.info('Mengambil semua pesanan aktif dari database (stream sekali).');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
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

  Future<List<OrderModel>> ambilOrderBerdasarkanStatus(
    StatusOrderEnum status,
  ) async {
    Log.info('Mengambil pesanan dengan status: ${status.name}');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.status} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [status.name],
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      Log.info(
        'Berhasil mengambil ${maps.length} data pesanan aktif berstatus ${status.name}.',
      );
      return maps.map(OrderModel.fromSqlite).toList();
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil pesanan berdasarkan status.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteorder(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk pesanan ID: $id');
    try {
      await baseOpSqlite.softDelete(_namaTabel, id, dariServer: dariServer);
      Log.info('Berhasil soft delete pesanan ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete pesanan ID: $id', e: e, s: st);
      rethrow;
    }
  }

  Future<int> softDeleteAllOrder({final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk semua pesanan');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua pesanan. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua pesanan', e: e, s: st);
      rethrow;
    }
  }

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
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch pesanan selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch pesanan.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilOrderBerdasarkanIds(
    final List<String> ids,
  ) async {
    Log.info('Mengambil pesanan untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('List ID kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where:
            '${NamaKolom.id} IN (${List.filled(ids.length, '?').join(',')}) AND ${NamaKolom.dihapus} = 0',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} data pesanan berdasarkan daftar ID.',
      );
      return List.generate(maps.length, (final i) {
        return OrderModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil data pesanan berdasarkan daftar ID.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}

// path: lib/fitur/kategori/operasi/kategori_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

class KategoriOpSqlite {
  final SqliteDatabase sqlitedb;

  final BaseOpSqlite _baseOpSqlite;

  final String _tableName = NamaTabel.category;

  KategoriOpSqlite({
    required this.sqlitedb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite;

  Future<KategoriModel> tambahKategori(
    final KategoriModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createCategory untuk category: ${category.toSqlite()}');
    try {
      final kategoriBaru = category.copyWith(diperbaruiPada: DateTime.now().toUtc());
      final data = kategoriBaru.toSqlite();

      await _baseOpSqlite.sisipkan(
        _tableName,
        data,
        dariServer: fromServer,
      );
      Log.info('Berhasil membuat category baru dengan ID: ${kategoriBaru.id}');
      return kategoriBaru;
    } catch (e, st) {
      Log.error('Gagal saat createCategory', e: e, s: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> ambilSemua() async {
    Log.info(
        'Memulai getCategories (mengambil semua kategori yang tidak diarsipkan).');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.diHapus} = 0',
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listCategory.length} data category.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategories', e: e, s: st);
      rethrow;
    }
  }

  Future<KategoriModel> ambilKategoriBerdasarkanId(final String id) async {
    Log.info('Memulai getCategoryById untuk ID: $id');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final kategori = KategoriModel.fromSqlite(maps.first);
        Log.info('Category dengan ID: $id ditemukan.');
        return kategori;
      } else {
        Log.error('Category dengan ID $id tidak ditemukan di database.');
        throw Exception('Category dengan ID $id tidak ditemukan.');
      }
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoryById untuk ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<List<KategoriModel>> ambilKategoriBerdasarkanTipe(
      final TipeKategori type) async {
    Log.info('Memulai getCategoriesByType untuk tipe: ${type.name}');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.tipe} = ? AND ${NamaKolom.diHapus} = 0',
        whereArgs: [type.name],
      );
      final daftarKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarKategori.length} data category untuk tipe ${type.name}.',
      );
      return daftarKategori;
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoriesByType untuk tipe: ${type.name}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> updateKategori(
    final KategoriModel category, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai updateCategory untuk category ID: ${category.id}');
    try {
      final data =
          category.copyWith(diperbaruiPada: DateTime.now().toUtc()).toSqlite();
      await _baseOpSqlite.update(
        _tableName,
        data,
        category.id,
        dariServer: dariServer,
      );
      Log.info('Berhasil updateCategory untuk ID: ${category.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateCategory untuk ID: ${category.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> softDeleteKategori(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk category ID: $id');
    try {
      await _baseOpSqlite.softDelete(
        _tableName,
        id,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft delete category ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat soft delete category ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<int> softDeleteAllKategori({
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua kategori');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _tableName,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft delete semua kategori. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error(
        'Gagal saat soft delete semua kategori',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> insertOrUpdateBatch(
    final List<KategoriModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info(
        'Memulai insertOrUpdateBatch untuk ${items.length} item category.');
    if (items.isEmpty) {
      Log.warning(
          'List item untuk batch kosong, tidak ada operasi yang dilakukan.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) =>
                item.copyWith(diperbaruiPada: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await _baseOpSqlite.insertOrUpdateBatch(
        _tableName,
        data,
        dariServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item category.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan insertOrUpdateBatch category',
          e: e, s: st);
      rethrow;
    }
  }

  Future<List<KategoriModel>> getCategoriesByIds(final List<String> ids) async {
    Log.info('Memulai getCategoriesByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
          'List ID untuk getCategoriesByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await sqlitedb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil mengambil ${listCategory.length} category dari ${ids.length} ID yang diminta.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategoriesByIds', e: e, s: st);
      rethrow;
    }
  }
}

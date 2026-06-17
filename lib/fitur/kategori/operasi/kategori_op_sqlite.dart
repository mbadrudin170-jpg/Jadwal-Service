// path: lib/fitur/kategori/operasi/kategori_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class KategoriOpSqlite {
  final SqliteDatabase sqlitedb;

  final BaseOpSqlite _baseOpSqlite;

  final String _namaTabel = NamaTabel.kategori;

  KategoriOpSqlite({
    required this.sqlitedb,
    required final BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite;

  Future<KategoriModel> tambahKategori(
    final KategoriModel kategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createCategory untuk category: ${kategori.toSqlite()}');
    try {
      final kategoriBaru =
          kategori.copyWith(diperbaruiPada: DateTime.now().toUtc());
      final data = kategoriBaru.toSqlite();

      await _baseOpSqlite.sisipkan(
        _namaTabel,
        data,
        dariServer: dariServer,
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
        _namaTabel,
        where: '${NamaKolom.dihapus} = 0',
      );
      final daftarKategori = List.generate(
        maps.length,
        ( i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarKategori.length} data category.');
      return daftarKategori;
    } catch (e, st) {
      Log.error('Gagal saat getCategories', e: e, s: st);
      rethrow;
    }
  }

  Future<KategoriModel> ambilKategoriBerdasarkanId( String id) async {
    Log.info('Memulai getCategoryById untuk ID: $id');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
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
       TipeKategori tipe) async {
    Log.info('Memulai getCategoriesByType untuk tipe: ${tipe.name}');
    try {
      final db = await sqlitedb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.tipe} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [tipe.name],
      );
      final daftarKategori = List.generate(
        maps.length,
        (i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarKategori.length} data category untuk tipe ${tipe.name}.',
      );
      return daftarKategori;
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoriesByType untuk tipe: ${tipe.name}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  Future<void> updateKategori(
    final KategoriModel kategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai updateCategory untuk category ID: ${kategori.id}');
    try {
      final data =
          kategori.copyWith(diperbaruiPada: DateTime.now().toUtc()).toSqlite();
      await _baseOpSqlite.update(
        _namaTabel,
        data,
        kategori.id,
        dariServer: dariServer,
      );
      Log.info('Berhasil updateCategory untuk ID: ${kategori.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateCategory untuk ID: ${kategori.id}',
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
        _namaTabel,
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
        _namaTabel,
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

  Future<void> sisipkanAtauPerbaruiBatch(
    final List<KategoriModel> items, {
    final bool dariServer = false,
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
            (final item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
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
        _namaTabel,
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

// path: lib/shared/operasi/category_operation.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data kategori di database lokal.
class CategoryOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final SqliteDatabase dbHelper;

  /// Instance dari BaseOperation untuk operasi database umum.
  final BaseOpSqlite _baseOperation;

  final String _tableName = NamaTabel.category;

  /// Konstruktor untuk CategoryOperation.
  CategoryOperation({
    required this.dbHelper,
    required final BaseOpSqlite baseOperation,
  }) : _baseOperation = baseOperation {
    Log.info('CategoryOperation instance dibuat.');
  }

  /// Membuat [KategoriModel] baru di database.
  Future<KategoriModel> createCategory(
    final KategoriModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createCategory untuk category: ${category.toSqlite()}');
    try {
      final newCategory = category.copyWith(updatedAt: DateTime.now().toUtc());
      final data = newCategory.toSqlite();

      await _baseOperation.sisipkan(
        _tableName,
        data,
        dariServer: fromServer,
      );
      Log.info('Berhasil membuat category baru dengan ID: ${newCategory.id}');
      return newCategory;
    } catch (e, st) {
      Log.error('Gagal saat createCategory', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang tidak diarsipkan.
  Future<List<KategoriModel>> getAll() async {
    Log.info(
        'Memulai getCategories (mengambil semua kategori yang tidak diarsipkan).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.isDeleted} = 0',
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

  /// Mengambil [KategoriModel] berdasarkan [id].
  Future<KategoriModel> getCategoryById(final String id) async {
    Log.info('Memulai getCategoryById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final category = KategoriModel.fromSqlite(maps.first);
        Log.info('Category dengan ID: $id ditemukan.');
        return category;
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

  /// Mengambil semua kategori berdasarkan [TipeKategori].
  Future<List<KategoriModel>> getCategoriesByType(
      final TipeKategori type) async {
    Log.info('Memulai getCategoriesByType untuk tipe: ${type.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.type} = ? AND ${NamaKolom.isDeleted} = 0',
        whereArgs: [type.name],
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listCategory.length} data category untuk tipe ${type.name}.',
      );
      return listCategory;
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoriesByType untuk tipe: ${type.name}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [KategoriModel] yang ada di database.
  Future<void> updateCategory(
    final KategoriModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai updateCategory untuk category ID: ${category.id}');
    try {
      final data =
          category.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        _tableName,
        data,
        category.id,
        dariServer: fromServer,
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

  /// Menghapus [KategoriModel] dari database secara permanen.
  Future<void> deleteCategory(final String id,
      {final bool fromServer = false}) async {
    Log.warning(
        'PERINGATAN: Memulai deleteCategory (hard delete) untuk category ID: $id');
    try {
      await _baseOperation.delete(
        _tableName,
        id,
        dariServer: fromServer,
      );
      Log.info('Berhasil deleteCategory untuk ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat deleteCategory untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada satu kategori berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk category ID: $id');
    try {
      await _baseOperation.hapusSementara(
        _tableName,
        id,
        dariServer: fromServer,
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

  /// Melakukan soft delete pada semua kategori.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua kategori');
    try {
      final count = await _baseOperation.hapusSementaraSemua(
        _tableName,
        dariServer: fromServer,
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

  /// Menghapus semua kategori yang ada dan menyisipkan yang baru secara atomik.
  Future<void> clearAndInsertAll(
    final List<KategoriModel> items, {
    final bool fromServer = false,
  }) async {
    Log.warning(
      'PERINGATAN: Memulai clearAndInsertAll. Ini akan menghapus semua category dan menggantinya dengan ${items.length} item baru.',
    );
    if (items.isEmpty) {
      Log.warning(
          'List item untuk clearAndInsertAll kosong, hanya operasi pembersihan yang akan dilakukan.');
    }
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final batch = txn.batch();

          batch.delete(_tableName);
          Log.info('Antrean hapus tabel kategori ditambahkan ke batch.');

          for (final item in items) {
            batch.insert(
              _tableName,
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          Log.info('Menjalankan commit batch untuk clearAndInsertAll...');
          await batch.commit(noResult: true);

          Log.info(
              'Berhasil menyisipkan ${items.length} item baru ke tabel kategori.');
        },
        fromServer: fromServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat menjalankan clearAndInsertAll', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang telah diubah sejak [since].
  Future<List<KategoriModel>> getChangesSince(final DateTime since) async {
    Log.info(
        'Memulai getChangesSince untuk category sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => KategoriModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil menemukan ${listCategory.length} perubahan category sejak ${since.toIso8601String()}.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getChangesSince category', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [KategoriModel] dalam satu batch.
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
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await _baseOperation.insertOrUpdateBatch(
        _tableName,
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item category.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan insertOrUpdateBatch category',
          e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [KategoriModel] berdasarkan daftar [ids].
  Future<List<KategoriModel>> getCategoriesByIds(final List<String> ids) async {
    Log.info('Memulai getCategoriesByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
          'List ID untuk getCategoriesByIds kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
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

// path: lib/shared/operasi/category_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari KategoriOperasi menjadi CategoryOperation.
// diubah: Menggunakan BaseOperation dan CategoryModel.

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data kategori di database lokal.
class CategoryOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper;

  /// Instance dari BaseOperation untuk operasi database umum.
  final BaseOperation _baseOperation;

  /// Konstruktor untuk CategoryOperation.
  CategoryOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('CategoryOperation instance dibuat.');
  }

  /// Membuat [CategoryModel] baru di database.
  Future<CategoryModel> createCategory(
    final CategoryModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createCategory untuk category: ${category.toSqlite()}');
    try {
      final newCategory = category.copyWith(updatedAt: DateTime.now().toUtc());
      final data = newCategory.toSqlite();

      await _baseOperation.insert('kategori', data, fromServer: fromServer);
      Log.info('Berhasil membuat category baru dengan ID: ${newCategory.id}');
      return newCategory;
    } catch (e, st) {
      Log.error('Gagal saat createCategory', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang tidak diarsipkan.
  Future<List<CategoryModel>> getCategories() async {
    Log.info(
        'Memulai getCategories (mengambil semua kategori yang tidak diarsipkan).');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.archivedAt} IS NULL',
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${listCategory.length} data category.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategories', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [CategoryModel] berdasarkan [id].
  Future<CategoryModel> getCategoryById(final String id) async {
    Log.info('Memulai getCategoryById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final category = CategoryModel.fromSqlite(maps.first);
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
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua kategori berdasarkan [CategoryType].
  Future<List<CategoryModel>> getCategoriesByType(
      final CategoryType type) async {
    Log.info('Memulai getCategoriesByType untuk tipe: ${type.name}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.type} = ? AND ${ColumnNames.archivedAt} IS NULL',
        whereArgs: [type.name],
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${listCategory.length} data category untuk tipe ${type.name}.',
      );
      return listCategory;
    } catch (e, st) {
      Log.error(
        'Gagal saat getCategoriesByType untuk tipe: ${type.name}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Memperbarui [CategoryModel] yang ada di database.
  Future<void> updateCategory(
    final CategoryModel category, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai updateCategory untuk category ID: ${category.id}');
    try {
      final data =
          category.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        'kategori',
        data,
        category.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updateCategory untuk ID: ${category.id}.');
    } catch (e, st) {
      Log.error(
        'Gagal saat updateCategory untuk ID: ${category.id}',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus [CategoryModel] dari database secara permanen.
  Future<void> deleteCategory(final String id,
      {final bool fromServer = false}) async {
    Log.warning(
        'PERINGATAN: Memulai deleteCategory (hard delete) untuk category ID: $id');
    try {
      await _baseOperation.delete('kategori', id, fromServer: fromServer);
      Log.info('Berhasil deleteCategory untuk ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat deleteCategory untuk ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Mengarsipkan satu kategori berdasarkan [id] (soft delete).
  Future<void> archiveOneCategory(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai archiveOneCategory (soft delete) untuk ID: $id');
    try {
      final now = DateTime.now().toUtc();
      final Map<String, dynamic> dataToUpdate = {
        ColumnNames.archivedAt: now.millisecondsSinceEpoch,
        ColumnNames.updatedAt: now.millisecondsSinceEpoch,
        ColumnNames.isDeleted: 1,
      };

      await _baseOperation.update(
        'kategori',
        dataToUpdate,
        id,
        fromServer: fromServer,
      );

      Log.info('Berhasil archiveOneCategory untuk ID: $id.');
    } catch (e, st) {
      Log.error(
        'Gagal saat archiveOneCategory untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua kategori yang ada dan menyisipkan yang baru.
  Future<void> clearAndInsertAll(
    final List<CategoryModel> items, {
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
          await txn.delete('kategori');
          Log.info('Tabel kategori berhasil dibersihkan.');
          for (final item in items) {
            await txn.insert(
              'kategori',
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
            );
          }
          Log.info(
              'Berhasil menyisipkan ${items.length} item baru ke tabel kategori.');
        },
        fromServer: fromServer,
      );
    } catch (e, st) {
      Log.error('Gagal saat menjalankan clearAndInsertAll', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kategori yang telah diubah sejak [since].
  Future<List<CategoryModel>> getChangesSince(final DateTime since) async {
    Log.info(
        'Memulai getChangesSince untuk category sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kategori',
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil menemukan ${listCategory.length} perubahan category sejak ${since.toIso8601String()}.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getChangesSince category', e: e, st: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [CategoryModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<CategoryModel> items, {
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
        'kategori',
        data,
        fromServer: fromServer,
      );
      Log.info(
          'Berhasil menyelesaikan insertOrUpdateBatch untuk ${items.length} item category.');
    } catch (e, st) {
      Log.error('Gagal saat menjalankan insertOrUpdateBatch category',
          e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [CategoryModel] berdasarkan daftar [ids].
  Future<List<CategoryModel>> getCategoriesByIds(final List<String> ids) async {
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
        'kategori',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      final listCategory = List.generate(
        maps.length,
        (final i) => CategoryModel.fromSqlite(maps[i]),
      );
      Log.info(
          'Berhasil mengambil ${listCategory.length} category dari ${ids.length} ID yang diminta.');
      return listCategory;
    } catch (e, st) {
      Log.error('Gagal saat getCategoriesByIds', e: e, st: st);
      rethrow;
    }
  }
}

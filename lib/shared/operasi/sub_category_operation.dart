// path: lib/shared/operasi/sub_category_operation.dart

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data sub-kategori di database lokal.
class SubCategoryOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  @visibleForTesting
  BaseOperation baseOperation;

  /// Konstruktor untuk [SubCategoryOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  SubCategoryOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        baseOperation = baseOperation ?? BaseOperation();

  /// Menyimpan [SubCategoryModel] baru ke dalam database.
  Future<void> createSubCategory(
    final SubCategoryModel subCategory, {
    final bool fromServer = false,
  }) async {
    Log.info('Membuat sub-kategori baru: ${subCategory.name}');
    final data =
        subCategory.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
    await baseOperation.insert(
      'sub_kategori',
      data,
      fromServer: fromServer,
    );
  }

  /// Mengambil semua sub-kategori yang terkait dengan [categoryId].
  Future<List<SubCategoryModel>> getSubCategoryByCategoryId(
    final String categoryId,
  ) async {
    Log.info('Mengambil sub-kategori untuk kategori ID: $categoryId');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id_kategori = ? AND isDeleted = ?',
      whereArgs: [categoryId, 0],
    );
    return List.generate(maps.length, (final i) {
      return SubCategoryModel.fromSqlite(maps[i]);
    });
  }

  /// Mengambil [SubCategoryModel] berdasarkan [id].
  Future<SubCategoryModel?> getSubCategoryById(final String id) async {
    Log.info('Mengambil sub-kategori dengan ID: $id');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SubCategoryModel.fromSqlite(maps.first);
    }
    return null;
  }

  /// Memperbarui [SubCategoryModel] yang ada di database.
  Future<void> updateSubCategory(
    final SubCategoryModel subCategory, {
    final bool fromServer = false,
  }) async {
    Log.info('Memperbarui sub-kategori: ${subCategory.name}');
    final data =
        subCategory.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
    await baseOperation.update(
      'sub_kategori',
      data,
      subCategory.id,
      fromServer: fromServer,
    );
  }

  /// Menghapus [SubCategoryModel] dari database.
  ///
  /// Jika [softDelete] bernilai `true`, maka hanya akan menandai `isDeleted` menjadi `1`.
  /// Jika `false`, maka akan menghapus data secara permanen.
  Future<void> deleteSubCategory(
    final String id, {
    final bool softDelete = true,
    final bool fromServer = false,
  }) async {
    Log.info('Menghapus sub-kategori ID: $id (softDelete: $softDelete)');
    if (softDelete) {
      final dataToUpdate = {
        'isDeleted': 1,
        'diperbarui': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
      await baseOperation.update(
        'sub_kategori',
        dataToUpdate,
        id,
        fromServer: fromServer,
      );
    } else {
      await baseOperation.delete(
        'sub_kategori',
        id,
        fromServer: fromServer,
      );
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [SubCategoryModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<SubCategoryModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Memulai batch insert/update untuk ${items.length} sub-kategori.',
    );
    if (items.isEmpty) return;
    final data = items
        .map(
          (final item) =>
              item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
        )
        .toList();
    await baseOperation.insertOrUpdateBatch(
      'sub_kategori',
      data,
      fromServer: fromServer,
    );
    Log.info('Batch sub-kategori selesai.');
  }

  /// Mengambil beberapa [SubCategoryModel] berdasarkan daftar [ids].
  Future<List<SubCategoryModel>> getSubCategoryByIds(
    final List<String> ids,
  ) async {
    if (ids.isEmpty) {
      return [];
    }
    Log.info('Mengambil sub-kategori untuk ${ids.length} ID.');
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (final i) {
      return SubCategoryModel.fromSqlite(maps[i]);
    });
  }
}

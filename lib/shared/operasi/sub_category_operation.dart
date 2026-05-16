// path: lib/shared/operasi/sub_category_operation.dart

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data sub-kategori di database lokal.
class SubCategoryOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  @visibleForTesting
  final BaseOperation baseOperation;

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
    try {
      final data =
          subCategory.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
      await baseOperation.insert(
        TableNameValue.get(TableName.subCategory),
        data,
        fromServer: fromServer,
      );
      Log.info('Berhasil membuat sub-kategori ID: ${subCategory.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal membuat sub-kategori.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua sub-kategori yang terkait dengan [categoryId].
  Future<List<SubCategoryModel>> getSubCategoryByCategoryId(
    final String categoryId,
  ) async {
    Log.info('Mengambil sub-kategori untuk kategori ID: $categoryId');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
      final List<Map<String, dynamic>> maps = await db.query(
        TableNameValue.get(TableName.subCategory),
        where: 'id_kategori = ? AND isDeleted = ?',
        whereArgs: [categoryId, 0],
      );
      Log.info('Berhasil mengambil ${maps.length} sub-kategori aktif.');
      return List.generate(maps.length, (final i) {
        return SubCategoryModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan kategori ID.',
          e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [SubCategoryModel] berdasarkan [id].
  Future<SubCategoryModel?> getSubCategoryById(final String id) async {
    Log.info('Mengambil sub-kategori dengan ID: $id');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
      final List<Map<String, dynamic>> maps = await db.query(
        TableNameValue.get(TableName.subCategory),
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Sub-kategori dengan ID: $id ditemukan.');
        return SubCategoryModel.fromSqlite(maps.first);
      }
      Log.warning('Sub-kategori dengan ID: $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan ID.', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui [SubCategoryModel] yang ada di database.
  Future<void> updateSubCategory(
    final SubCategoryModel subCategory, {
    final bool fromServer = false,
  }) async {
    Log.info('Memperbarui sub-kategori: ${subCategory.name}');
    try {
      final data =
          subCategory.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
      await baseOperation.update(
        TableNameValue.get(TableName.subCategory),
        data,
        subCategory.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil memperbarui sub-kategori ID: ${subCategory.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal memperbarui sub-kategori.', e: e, st: s);
      rethrow;
    }
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
    Log.warning('Menghapus sub-kategori ID: $id (softDelete: $softDelete)');
    try {
      if (softDelete) {
        final dataToUpdate = {
          'isDeleted': 1,
          'diperbarui': DateTime.now().toUtc().millisecondsSinceEpoch,
        };
        // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
        await baseOperation.update(
          TableNameValue.get(TableName.subCategory),
          dataToUpdate,
          id,
          fromServer: fromServer,
        );
        Log.info('Berhasil melakukan soft delete sub-kategori ID: $id');
      } else {
        // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
        await baseOperation.delete(
          TableNameValue.get(TableName.subCategory),
          id,
          fromServer: fromServer,
        );
        Log.warning('Berhasil melakukan hard delete sub-kategori ID: $id');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus sub-kategori.', e: e, st: s);
      rethrow;
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
    if (items.isEmpty) {
      Log.warning('List item kosong, membatalkan proses operasi batch.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
      await baseOperation.insertOrUpdateBatch(
        TableNameValue.get(TableName.subCategory),
        data,
        fromServer: fromServer,
      );
      Log.info('Batch sub-kategori selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch sub-kategori.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [SubCategoryModel] berdasarkan daftar [ids].
  Future<List<SubCategoryModel>> getSubCategoryByIds(
    final List<String> ids,
  ) async {
    Log.info('Mengambil sub-kategori untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      // DIUBAH: Menggunakan TableNameValue untuk nama tabel subCategory
      final List<Map<String, dynamic>> maps = await db.query(
        TableNameValue.get(TableName.subCategory),
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} sub-kategori dari list ID.');
      return List.generate(maps.length, (final i) {
        return SubCategoryModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan list ID.',
          e: e, st: s);
      rethrow;
    }
  }
}

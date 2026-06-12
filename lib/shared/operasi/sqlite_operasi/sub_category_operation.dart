// path: lib/shared/operasi/sub_category_operation.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data sub-kategori di database lokal.
class SubCategoryOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  final BaseOperation baseOperation;

  final String _tableName = TableNameValue.get(TableName.subCategory);

  SubCategoryOperation({
    required this.dbHelper,
    required this.baseOperation,
  });

  /// Menyimpan [SubCategoryModel] baru ke dalam database.
  Future<void> createSubCategory(
    final SubCategoryModel subCategory, {
    final bool fromServer = false,
  }) async {
    Log.info('Membuat sub-kategori baru: ${subCategory.name}');
    try {
      final data =
          subCategory.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await baseOperation.insert(
        _tableName,
        data,
        dariServer: fromServer,
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
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.categoryId} = ? AND ${ColumnNames.isDeleted} = ?',
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
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
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
      await baseOperation.update(
        _tableName,
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

  /// Menghapus [SubCategoryModel] dari database secara permanen.
  Future<void> delete(final String id, {final bool fromServer = false}) async {
    Log.warning('PERINGATAN: Menghapus sub-kategori ID: $id secara permanen');
    try {
      await baseOperation.delete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.warning('Berhasil melakukan hard delete sub-kategori ID: $id');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus sub-kategori secara permanen.', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada sub-kategori berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk sub-kategori ID: $id');
    try {
      await baseOperation.softDelete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft delete sub-kategori ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete sub-kategori ID: $id', e: e, st: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua sub-kategori.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua sub-kategori');
    try {
      final count = await baseOperation.softDeleteAll(
        _tableName,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua sub-kategori. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua sub-kategori', e: e, st: st);
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
      await baseOperation.insertOrUpdateBatch(
        _tableName,
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
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id IN ($placeholders) AND ${ColumnNames.isDeleted} = 0',
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

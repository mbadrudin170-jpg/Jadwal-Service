// path: lib/shared/operasi/package_operation.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

final packageOperationProvider = Provider<PackageOperation>((ref) {
  Log.info('Membuat instance FeedbackOperation...');
  final dbHelper = ref.read(databaseHelperProvider);
  final baseOperation = ref.read(baseOperationProvider);

  return PackageOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
});

/// Kelas untuk operasi terkait data paket di database lokal.
class PackageOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  final BaseOperation baseOperation;
  final String _tableName = TableNameValue.get(TableName.package);
  final _nowUtc = DateTime.now().toUtc();

  PackageOperation({
    required this.dbHelper,
    required this.baseOperation,
  }) {
    Log.info('PackageOperation instance dibuat.');
  }

  /// Menyimpan [PackageModel] baru ke dalam database.
  Future<void> add(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai createPackage untuk id: ${package.id}');
    try {
      final data = package.copyWith(updatedAt: _nowUtc).toSqlite();
      await baseOperation.insert(
        _tableName,
        data,
        fromServer: fromServer,
      );
      Log.info('Berhasil createPackage untuk id: ${package.id}');
    } catch (e, s) {
      Log.error('Gagal createPackage untuk id: ${package.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket, termasuk yang diarsipkan.
  Future<List<PackageModel>> getAll() async {
    Log.info('Memulai proses pengambilan semua data paket');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tableName
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket aktif (tidak diarsipkan).
  Future<List<PackageModel>> getByAktif() async {
    Log.info('Memulai proses pengambilan semua data paket aktif');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tableName
        WHERE ${ColumnNames.isDeleted} = 0
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket aktif');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket aktif', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang bersifat publik.
  Future<List<PackageModel>> getByIsPublic() async {
    Log.info('Memulai proses pengambilan semua data paket publik');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tableName
        WHERE ${ColumnNames.isDeleted} = 0 AND ${ColumnNames.isPublic} = 1
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket publik');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket publik', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [PackageModel] berdasarkan [id].
  Future<PackageModel?> getById(final String id) async {
    Log.info('Memulai pencarian paket berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Paket ditemukan untuk ID: $id');
        return PackageModel.fromSqlite(maps.first);
      } else {
        Log.warning('Paket dengan ID $id tidak ditemukan');
        return null;
      }
    } catch (e, s) {
      Log.error('Gagal mencari paket berdasarkan ID: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui [PackageModel] yang ada di database.
  Future<void> update(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai updatePackage untuk id: ${package.id}');
    try {
      final data = package.copyWith(updatedAt: _nowUtc).toSqlite();
      await baseOperation.update(
        _tableName,
        data,
        package.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updatePackage untuk id: ${package.id}');
    } catch (e, s) {
      Log.error('Gagal updatePackage untuk id: ${package.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada [PackageModel] berdasarkan [id].
  Future<void> softDelete(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk package id: $id');
    try {
      await baseOperation.softDelete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft delete untuk package id: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete untuk package id: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Menandai semua paket sebagai soft-deleted (diarsipkan).
  Future<int> softDeleteAll({final bool fromServer = false}) async {
    Log.info('Memulai soft-delete untuk semua paket');
    try {
      final count = await baseOperation.softDeleteAll(
        _tableName,
        fromServer: fromServer,
      );
      Log.info('Berhasil soft-delete semua paket. Total terupdate: $count');
      return count;
    } catch (e, s) {
      Log.error('Gagal soft-delete semua paket', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus [PackageModel] dari database secara permanen.
  Future<void> delete(final String id, {final bool fromServer = false}) async {
    Log.info('Memulai deletePackage untuk id: $id');
    try {
      await baseOperation.delete(
        _tableName,
        id,
        fromServer: fromServer,
      );
      Log.info('Berhasil deletePackage untuk id: $id');
    } catch (e, s) {
      Log.error('Gagal deletePackage untuk id: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus semua paket dari database secara permanen.
  Future<void> deleteAll({final bool fromServer = false}) async {
    Log.info('Memulai proses penghapusan semua data paket');
    try {
      await baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final int count = await txn.delete(
            _tableName,
          );
          Log.info(
              'Berhasil menghapus semua data paket. Total terhapus: $count');
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error('Gagal menghapus semua data paket', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang telah diubah sejak [since].
  Future<List<PackageModel>> getChangesSince(final DateTime since) async {
    Log.info(
        'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info('Ditemukan ${maps.length} perubahan paket');
      return List.generate(
          maps.length, (final i) => PackageModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan paket', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [PackageModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<PackageModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item paket');
    if (items.isEmpty) {
      Log.warning('List item batch kosong, operasi dibatalkan');
      return;
    }
    try {
      final dataList = items
          .map(
            (final item) => item.copyWith(updatedAt: _nowUtc).toSqlite(),
          )
          .toList();
      await baseOperation.insertOrUpdateBatch(
        _tableName,
        dataList,
        fromServer: fromServer,
      );
      Log.info('Berhasil insertOrUpdateBatch untuk ${items.length} item');
    } catch (e, s) {
      Log.error('Gagal insertOrUpdateBatch', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [PackageModel] berdasarkan daftar [ids].
  Future<List<PackageModel>> getByIds(final List<String> ids) async {
    Log.info('Memulai pengambilan paket berdasarkan list ID: $ids');
    try {
      if (ids.isEmpty) {
        Log.warning('List ID kosong, mengembalikan list kosong');
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} paket dari ${ids.length} ID');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil paket berdasarkan list ID', e: e, st: s);
      rethrow;
    }
  }
}

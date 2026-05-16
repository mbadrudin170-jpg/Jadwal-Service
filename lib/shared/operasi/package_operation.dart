// path: lib/shared/operasi/package_operation.dart

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data paket di database lokal.
class PackageOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  final BaseOperation _baseOperation;

  /// Konstruktor untuk [PackageOperation].
  PackageOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('PackageOperation instance dibuat.');
  }

  /// Menyimpan [PackageModel] baru ke dalam database.
  Future<void> createPackage(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai createPackage untuk id: ${package.id}');
    try {
      final data =
          package.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      await _baseOperation.insert(
        TableNameValue.get(TableName.package),
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
  Future<List<PackageModel>> getAllPackages() async {
    Log.info('Memulai proses pengambilan semua data paket');
    try {
      final db = await dbHelper.database;
      final String packageTable = TableNameValue.get(TableName.package);
      // DIUBAH: Menggunakan nama tabel dinamis di dalam rawQuery
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $packageTable
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
  Future<List<PackageModel>> getPackages() async {
    Log.info('Memulai proses pengambilan semua data paket aktif');
    try {
      final db = await dbHelper.database;
      final String packageTable = TableNameValue.get(TableName.package);
      // DIUBAH: Menggunakan nama tabel dinamis di dalam rawQuery
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $packageTable
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
  Future<List<PackageModel>> getPublicPackages() async {
    Log.info('Memulai proses pengambilan semua data paket publik');
    try {
      final db = await dbHelper.database;
      final String packageTable = TableNameValue.get(TableName.package);
      // DIUBAH: Menggunakan nama tabel dinamis di dalam rawQuery
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $packageTable
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
  Future<PackageModel?> getPackageById(final String id) async {
    Log.info('Memulai pencarian paket berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        TableNameValue.get(TableName.package),
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
  Future<void> updatePackage(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai updatePackage untuk id: ${package.id}');
    try {
      final data =
          package.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      await _baseOperation.update(
        TableNameValue.get(TableName.package),
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

  /// Menghapus [PackageModel] dari database secara permanen.
  Future<void> deletePackage(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai deletePackage untuk id: $id');
    try {
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      await _baseOperation.delete(
        TableNameValue.get(TableName.package),
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
  Future<void> deleteAllPackages({final bool fromServer = false}) async {
    Log.info('Memulai proses penghapusan semua data paket');
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
          final int count = await txn.delete(
            TableNameValue.get(TableName.package),
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
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        TableNameValue.get(TableName.package),
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
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      await _baseOperation.insertOrUpdateBatch(
        TableNameValue.get(TableName.package),
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
  Future<List<PackageModel>> getPackagesByIds(final List<String> ids) async {
    Log.info('Memulai pengambilan paket berdasarkan list ID: $ids');
    try {
      if (ids.isEmpty) {
        Log.warning('List ID kosong, mengembalikan list kosong');
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      // DIUBAH: Menggunakan nama tabel dari TableNameValue berbasis v50
      final List<Map<String, dynamic>> maps = await db.query(
        TableNameValue.get(TableName.package),
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

// path: lib/shared/operasi/upload_status_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/upload_status_model.dart';

final uploadStatusOperationProvider = Provider<UploadStatusOperation>((ref) {
  Log.info('Membuat instance UploadStatusOperation...');
  // Dapatkan instance DatabaseHelper dari provider-nya
  final dbHelper = ref.read(sqliteDatabaseProvider);
  // Buat instance UploadStatusOperation dengan dependensi yang di-inject
  return UploadStatusOperation(dbHelper: dbHelper);
});

/// Kelas ini mengelola satu flag tunggal di database: apakah ada
/// data yang perlu diunggah ke server atau tidak.
class UploadStatusOperation {
  final SqliteDatabase _dbHelper;

  /// Konstruktor untuk `UploadStatusOperation`.
  UploadStatusOperation({@visibleForTesting final SqliteDatabase? dbHelper})
      : _dbHelper = dbHelper ?? SqliteDatabase.instance {
    Log.info('UploadStatusOperation instance dibuat.');
  }

  /// Mengatur status `needUpload`.
  Future<void> setNeedUpload(
    final bool needUpload, {
    final Transaction? transaction,
  }) async {
    Log.info('Memulai setNeedUpload: needUpload=$needUpload');
    try {
      final db = transaction ?? await _dbHelper.database;
      final model = UploadStatusModel(
        id: UploadStatusModel.idNeedUpload,
        needUpload: needUpload,
        updatedAt: DateTime.now().toUtc(),
      );
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await db.insert(
        TableNameValue.get(TableName.uploadStatus),
        model.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Log.info('setNeedUpload berhasil: needUpload=$needUpload');
    } on Exception catch (e, st) {
      Log.error('Gagal setNeedUpload: $e', e: e, st: st);
      rethrow;
    }
  }

  /// Membaca status `needUpload`.
  /// Mengembalikan true jika flag diatur, selain itu false.
  Future<bool> getNeedUpload() async {
    Log.info('Memulai getNeedUpload');
    try {
      final db = await _dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final result = await db.query(
        TableNameValue.get(TableName.uploadStatus),
        where: 'id = ?',
        whereArgs: [UploadStatusModel.idNeedUpload],
      );
      if (result.isNotEmpty) {
        final needUpload =
            UploadStatusModel.fromSqlite(result.first).needUpload;
        Log.info('getNeedUpload berhasil: needUpload=$needUpload');
        return needUpload;
      }
      Log.info('getNeedUpload: tidak ada data, mengembalikan false');
      return false;
    } on Exception catch (e, st) {
      Log.error('Gagal getNeedUpload: $e', e: e, st: st);
      return false;
    }
  }

  /// Mereset status `needUpload` menjadi false setelah unggah berhasil.
  Future<void> resetNeedUpload() async {
    Log.info('Memulai resetNeedUpload');
    try {
      await setNeedUpload(false);
      Log.info('resetNeedUpload berhasil');
    } on Exception catch (e, st) {
      Log.error('Gagal resetNeedUpload: $e', e: e, st: st);
      rethrow;
    }
  }

  /// Mendapatkan model UploadStatusModel lengkap, termasuk waktu terakhir diperbarui.
  Future<UploadStatusModel?> getUploadStatusModel() async {
    Log.info('Memulai getUploadStatusModel');
    try {
      final db = await _dbHelper.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final result = await db.query(
        TableNameValue.get(TableName.uploadStatus),
        where: 'id = ?',
        whereArgs: [UploadStatusModel.idNeedUpload],
      );
      if (result.isNotEmpty) {
        final model = UploadStatusModel.fromSqlite(result.first);
        Log.info(
            'getUploadStatusModel berhasil: needUpload=${model.needUpload}');
        return model;
      }
      Log.info('getUploadStatusModel: tidak ada data, mengembalikan null');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal getUploadStatusModel: $e', e: e, st: st);
      return null;
    }
  }
}

// path: lib/shared/operasi/upload_status_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/upload_status_model.dart';

/// Kelas ini mengelola satu flag tunggal di database: apakah ada
/// data yang perlu diunggah ke server atau tidak.
class UploadStatusOperasi {
  final DatabaseHelper _dbHelper;

  /// Konstruktor untuk `UploadStatusOperasi`.
  UploadStatusOperasi({@visibleForTesting final DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance {
    Log.info('UploadStatusOperasi instance dibuat.');
  }

  /// Mengatur status `needUpload`.
  Future<void> setNeedUpload(
    final bool needUpload, {
    final Transaction? transaction,
  }) async {
    Log.info('Memulai setNeedUpload: needUpload=$needUpload');
    final db = transaction ?? await _dbHelper.database;
    final model = UploadStatusModel(
      id: UploadStatusModel.idNeedUpload,
      needUpload: needUpload,
      updatedAt: DateTime.now().toUtc(),
    );
    await db.insert(
      UploadStatusModel.tableName,
      model.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Log.info('setNeedUpload berhasil: needUpload=$needUpload');
  }

  /// Membaca status `needUpload`.
  /// Mengembalikan true jika flag diatur, selain itu false.
  Future<bool> getNeedUpload() async {
    Log.info('Memulai getNeedUpload');
    final db = await _dbHelper.database;
    final result = await db.query(
      UploadStatusModel.tableName,
      where: 'id = ?',
      whereArgs: [UploadStatusModel.idNeedUpload],
    );
    if (result.isNotEmpty) {
      final needUpload = UploadStatusModel.fromSqlite(result.first).needUpload;
      Log.info('getNeedUpload berhasil: needUpload=$needUpload');
      return needUpload;
    }
    Log.info('getNeedUpload: tidak ada data, mengembalikan false');
    return false;
  }

  /// Mereset status `needUpload` menjadi false setelah unggah berhasil.
  Future<void> resetNeedUpload() async {
    Log.info('Memulai resetNeedUpload');
    await setNeedUpload(false);
    Log.info('resetNeedUpload berhasil');
  }

  /// Mendapatkan model UploadStatusModel lengkap, termasuk waktu terakhir diperbarui.
  Future<UploadStatusModel?> getUploadStatusModel() async {
    Log.info('Memulai getUploadStatusModel');
    final db = await _dbHelper.database;
    final result = await db.query(
      UploadStatusModel.tableName,
      where: 'id = ?',
      whereArgs: [UploadStatusModel.idNeedUpload],
    );
    if (result.isNotEmpty) {
      final model = UploadStatusModel.fromSqlite(result.first);
      Log.info('getUploadStatusModel berhasil: needUpload=${model.needUpload}');
      return model;
    }
    Log.info('getUploadStatusModel: tidak ada data, mengembalikan null');
    return null;
  }
}

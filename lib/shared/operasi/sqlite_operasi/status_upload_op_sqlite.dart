// path: lib/shared/operasi/upload_status_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/upload_status_model.dart';

final statusUploadOpSlite = Provider<StatusUploadOpSqlite>((ref) {
  Log.info('Membuat instance UploadStatusOperation...');
  // Dapatkan instance DatabaseHelper dari provider-nya
  final sqliteDb = ref.read(sqliteDatabaseProvider);
  // Buat instance UploadStatusOperation dengan dependensi yang di-inject
  return StatusUploadOpSqlite(sqliteDb: sqliteDb);
});

/// Kelas ini mengelola satu flag tunggal di database: apakah ada
/// data yang perlu diunggah ke server atau tidak.
class StatusUploadOpSqlite {
  final SqliteDatabase _sqloteDb;

  /// Konstruktor untuk `UploadStatusOperation`.
  StatusUploadOpSqlite({@visibleForTesting final SqliteDatabase? sqliteDb})
  StatusUploadOpSqlite({@visibleForTesting SqliteDatabase? sqliteDb})
      : _sqloteDb = sqliteDb ?? SqliteDatabase.instance {
    Log.info('UploadStatusOperation instance dibuat.');
  }

  /// Mengatur status `needUpload`.
  Future<void> tandaiButuhUpload(
    final bool needUpload, {
    final Transaction? transaction,
    bool needUpload, {
    Transaction? transaction,
  }) async {
    Log.info('Memulai setNeedUpload: needUpload=$needUpload');
    try {
      final db = transaction ?? await _sqloteDb.database;
      final data = UploadStatusModel(
      final data = UploadStatusModel.buat(
        id: UploadStatusModel.idNeedUpload,
        needUpload: needUpload,
        updatedAt: DateTime.now().toUtc(),
      );
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      await db.insert(
        NamaTabel.get(TableName.uploadStatus),
        data.toSqlite(),
        NamaTabel.ambil(TableName.uploadStatus),
        data.keSqlite(),
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
  Future<bool> ambilButuhUpload() async {
    Log.info('Memulai getNeedUpload');
    try {
      final db = await _sqloteDb.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final query = await db.query(
        NamaTabel.get(TableName.uploadStatus),
        NamaTabel.ambil(TableName.uploadStatus),
        where: 'id = ?',
        whereArgs: [UploadStatusModel.idNeedUpload],
      );
      if (query.isNotEmpty) {
        final needUpload = UploadStatusModel.fromSqlite(query.first).needUpload;
        final needUpload = UploadStatusModel.dariSqlite(query.first).needUpload;
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
  Future<void> resetStatusUpload() async {
    Log.info('Memulai resetNeedUpload');
    try {
      await tandaiButuhUpload(false);
      Log.info('resetNeedUpload berhasil');
    } on Exception catch (e, st) {
      Log.error('Gagal resetNeedUpload: $e', e: e, st: st);
      rethrow;
    }
  }

  /// Mendapatkan model UploadStatusModel lengkap, termasuk waktu terakhir diperbarui.
  Future<UploadStatusModel?> getStatusUpload() async {
  Future<UploadStatusModel?> ambilStatusUpload() async {
    Log.info('Memulai getUploadStatusModel');
    try {
      final db = await _sqloteDb.database;
      // DIUBAH: Menggunakan TableNameValue berbasis v50
      final query = await db.query(
        NamaTabel.get(TableName.uploadStatus),
        NamaTabel.ambil(TableName.uploadStatus),
        where: 'id = ?',
        whereArgs: [UploadStatusModel.idNeedUpload],
      );
      if (query.isNotEmpty) {
        final data = UploadStatusModel.fromSqlite(query.first);
        final data = UploadStatusModel.dariSqlite(query.first);
        Log.info(
            'getUploadStatusModel berhasil: needUpload=${data.needUpload}');
        return data;
      }
      Log.info('getUploadStatusModel: tidak ada data, mengembalikan null');
      return null;
    } on Exception catch (e, st) {
      Log.error('Gagal getUploadStatusModel: $e', e: e, st: st);
      return null;
    }
  }
}

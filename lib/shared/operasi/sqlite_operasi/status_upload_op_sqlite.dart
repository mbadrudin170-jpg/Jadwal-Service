// path: lib/shared/operasi/upload_status_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/status_unggah_model.dart';

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
  final SqliteDatabase _sqliteDb;

  /// Konstruktor untuk `UploadStatusOperation`.
  StatusUploadOpSqlite({@visibleForTesting SqliteDatabase? sqliteDb})
      : _sqliteDb = sqliteDb ?? SqliteDatabase.instance {
    Log.info('UploadStatusOperation instance dibuat.');
  }

  /// Mengatur status `needUpload`.
  Future<void> tandaiButuhUpload(
    bool needUpload, {
    Transaction? transaction,
  }) async {
    Log.info('Memulai setNeedUpload: needUpload=$needUpload');
    try {
      final db = transaction ?? await _sqliteDb.database;
      final data = StatusUnggahModel(
        id: idNeedUpload,
        butuhUnggah: needUpload,
        diperbaruiPada: DateTime.now().toUtc(),
      );

      await db.insert(
        NamaTabel.statusUnggah,
        data.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Log.info('setNeedUpload berhasil: needUpload=$needUpload');
    } catch (e, st) {
      Log.error('Gagal setNeedUpload: $e', e: e, s: st);
      rethrow;
    }
  }

  /// Membaca status `needUpload`.
  Future<bool> ambilButuhUpload() async {
    Log.info('Memulai getNeedUpload');
    try {
      final db = await _sqliteDb.database;
      final query = await db.query(
        NamaTabel.statusUnggah,
        where: 'id = ?',
        whereArgs: [idNeedUpload],
      );
      if (query.isNotEmpty) {
        final needUpload =
            StatusUnggahModel.fromSqlite(query.first).butuhUnggah;
        Log.info('getNeedUpload berhasil: needUpload=$needUpload');
        return needUpload;
      }
      Log.info('getNeedUpload: tidak ada data, mengembalikan false');
      return false;
    } catch (e, st) {
      Log.error('Gagal getNeedUpload: $e', e: e, s: st);
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
      Log.error('Gagal resetNeedUpload: $e', e: e, s: st);
      rethrow;
    }
  }

  /// Mendapatkan model UploadStatusModel lengkap, termasuk waktu terakhir diperbarui.
  Future<StatusUnggahModel?> ambilStatusUpload() async {
    Log.info('Memulai getUploadStatusModel');
    try {
      final db = await _sqliteDb.database;
      final query = await db.query(
        NamaTabel.statusUnggah,
        where: 'id = ?',
        whereArgs: [idNeedUpload],
      );
      if (query.isNotEmpty) {
        final data = StatusUnggahModel.fromSqlite(query.first);
        Log.info(
            'getUploadStatusModel berhasil: needUpload=${data.butuhUnggah}');
        return data;
      }
      Log.info('getUploadStatusModel: tidak ada data, mengembalikan null');
      return null;
    } catch (e, st) {
      Log.error('Gagal getUploadStatusModel: $e', e: e, s: st);
      return null;
    }
  }
}

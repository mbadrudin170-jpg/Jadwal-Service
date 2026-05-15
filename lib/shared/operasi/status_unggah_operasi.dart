// path: lib/shared/operasi/status_unggah_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/status_unggah_model.dart';

/// Kelas ini mengelola satu flag tunggal di database: apakah ada
/// data yang perlu diunggah ke server atau tidak.
class StatusUnggahOperasi {
  final DatabaseHelper _dbHelper;

  /// Konstruktor untuk `StatusUnggahOperasi`.
  StatusUnggahOperasi({@visibleForTesting final DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengatur status `perlu_unggah`.
  Future<void> setPerluUnggah(
    final bool perluUnggah, {
    final Transaction? transaction,
  }) async {
    final db = transaction ?? await _dbHelper.database;
    final model = StatusUnggahModel(
      id: StatusUnggahModel.idPerluUnggah,
      perluUnggah: perluUnggah,
      diperbarui:
          DateTime.now().toUtc(), // Secara otomatis mencatat waktu perubahan
    );
    await db.insert(
      StatusUnggahModel.tableName,
      model.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Membaca status `perlu_unggah`.
  /// Mengembalikan true jika flag diatur, selain itu false.
  Future<bool> getPerluUnggah() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      StatusUnggahModel.tableName,
      where: 'id = ?',
      whereArgs: [StatusUnggahModel.idPerluUnggah],
    );
    if (result.isNotEmpty) {
      return StatusUnggahModel.fromSqlite(result.first).perluUnggah;
    }
    return false;
  }

  /// Mereset status `perlu_unggah` menjadi false setelah unggah berhasil.
  Future<void> resetPerluUnggah() async {
    await setPerluUnggah(false);
  }

  /// Mendapatkan model StatusUnggahModel lengkap, termasuk waktu terakhir diperbarui.
  Future<StatusUnggahModel?> getStatusUnggahModel() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      StatusUnggahModel.tableName,
      where: 'id = ?',
      whereArgs: [StatusUnggahModel.idPerluUnggah],
    );
    if (result.isNotEmpty) {
      return StatusUnggahModel.fromSqlite(result.first);
    }
    return null;
  }
}

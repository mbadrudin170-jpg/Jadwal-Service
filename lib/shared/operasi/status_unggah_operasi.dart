// path: lib/data/operasi/status_unggah_operasi.dart
// diubah: Menambahkan konstruktor untuk Dependency Injection agar bisa diuji.

import 'package:admin_wifi/data/sqlite.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Kelas ini mengelola satu flag tunggal di database: apakah ada
/// data yang perlu diunggah ke server atau tidak.
class StatusUnggahOperasi {
  // diubah: dbHelper sekarang final dan diinisialisasi di konstruktor.
  final DatabaseHelper _dbHelper;
  static const String _tableName = 'status_aplikasi';
  static const String _key = 'perlu_unggah';

  // diubah: Konstruktor untuk injeksi dependensi.
  StatusUnggahOperasi({@visibleForTesting DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Mengatur status `perlu_unggah`.
  /// true = 1, false = 0.
  Future<void> setPerluUnggah(
    bool perluUnggah, {
    Transaction? transaction,
  }) async {
    final db = transaction ?? await _dbHelper.database;
    await db.insert(_tableName, {
      'id': _key,
      'value': perluUnggah ? '1' : '0',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Membaca status `perlu_unggah`.
  /// Mengembalikan true jika flag diatur ke '1', selain itu false.
  Future<bool> getPerluUnggah() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [_key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] == '1';
    }
    return false;
  }
}

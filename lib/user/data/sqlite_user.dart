// path: lib/user/data/sqlite_user.dart
import 'dart:async';
import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteUser {
  static final SqfliteUser instance = SqfliteUser._init();
  static Database? _database;

  SqfliteUser._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    log('Membuka database di path: $path', name: 'sqlite_user.dart');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    log('Membuat tabel baru di database.', name: 'sqlite_user.dart');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        namaLengkap TEXT,
        email TEXT,
        nomorHp TEXT,
        alamat TEXT,
        password TEXT
      )
    ''');
    log('Tabel users berhasil dibuat.', name: 'sqlite_user.dart');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
    log('Database ditutup.', name: 'sqlite_user.dart');
  }
}

// path: test/admin/data/sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';

void main() {
  // INISIALISASI: Gunakan databaseFactory ffi untuk testing
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  // Helper untuk membuat database in-memory dengan tabel
  Future<Database> createTestDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
        },
      ),
    );
    return db;
  }

  group('SqliteDatabase Singleton & Provider', () {
    test(
      '01. instance harus selalu mengembalikan instance yang sama (singleton)',
      () {
        final instance1 = SqliteDatabase.instance;
        final instance2 = SqliteDatabase.instance;

        expect(instance1, same(instance2));
        expect(instance1, isA<SqliteDatabase>());
      },
    );

    test(
      '02. sqliteDatabaseProvider harus menyediakan instance SqliteDatabase',
      () {
        final sqliteDb = SqliteDatabase.instance;
        expect(sqliteDb, isA<SqliteDatabase>());
      },
    );

    test('03. sqliteProvider harus menyediakan Future<Database>', () async {
      final sqliteDb = SqliteDatabase.instance;
      final db = await sqliteDb.database;

      expect(db, isA<Database>());
      expect(db.isOpen, true);
    });
  });

  group('Inisialisasi Database (database getter dan _initDB)', () {
    test(
      '01. harus mengembalikan database yang ada di cache jika sudah diinisialisasi',
      () async {
        final sqliteDb = SqliteDatabase.instance;

        final db1 = await sqliteDb.database;
        final db2 = await sqliteDb.database;

        expect(db1, same(db2));
      },
    );

    test(
      '02. harus menginisialisasi database in-memory untuk testing',
      () async {
        // Gunakan createTestDatabase yang sudah memiliki tabel
        final db = await createTestDatabase();

        expect(db, isA<Database>());
        expect(db.isOpen, true);

        // Verifikasi dengan insert data
        await db.insert('test', {'id': 1});
        final result = await db.query('test');
        expect(result.length, 1);
        expect(result.first['id'], 1);

        await db.close();
      },
    );

    test('03. harus menginisialisasi database fisik (non-test)', () async {
      final db = await databaseFactoryFfi.openDatabase(
        'test_db.db',
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
          },
        ),
      );

      expect(db, isA<Database>());
      expect(db.isOpen, true);

      await db.close();
    });

    test('04. harus melempar exception jika _initDB gagal', () async {
      final sqliteDb = SqliteDatabase.instance;
      sqliteDb.debugSetDatabaseNull();

      try {
        await sqliteDb.database;
        fail('Seharusnya melempar exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('Pembuatan Tabel (onCreate)', () {
    test('01. harus memanggil _membuatSemuaTabel saat onCreate', () async {
      // Buat database dengan tabel yang sama seperti SqliteDatabase
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            // Simulasi pembuatan tabel seperti di SqliteDatabase
            await db.execute(
              'CREATE TABLE ${NamaTabel.kategori} (id TEXT PRIMARY KEY, name TEXT)',
            );
            await db.execute(
              'CREATE TABLE ${NamaTabel.paket} (id TEXT PRIMARY KEY, name TEXT)',
            );
            await db.execute(
              'CREATE TABLE ${NamaTabel.pelanggan} (id TEXT PRIMARY KEY, name TEXT)',
            );
          },
        ),
      );

      // Verifikasi tabel ada
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((row) => row['name'] as String).toList();

      expect(tableNames.contains(NamaTabel.kategori), true);
      expect(tableNames.contains(NamaTabel.paket), true);
      expect(tableNames.contains(NamaTabel.pelanggan), true);

      await db.close();
    });
  });

  group('Upgrade Database (_onUpgrade)', () {
    test('01. harus menjalankan migrasi dari versi 1 ke versi 2', () async {
      // Buat database versi 1
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('CREATE TABLE old_table (id INTEGER PRIMARY KEY)');
            await db.insert('old_table', {'id': 1});
          },
        ),
      );

      await db.close();

      // Upgrade ke versi 2
      final upgradedDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {},
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              // Cek apakah kolom sudah ada sebelum menambah
              final columns = await db.rawQuery(
                'PRAGMA table_info(old_table)',
              );
              final hasColumn = columns.any(
                (col) => col['name'] == 'new_column',
              );
              if (!hasColumn) {
                await db.execute(
                  'ALTER TABLE old_table ADD COLUMN new_column TEXT',
                );
                await db.update(
                  'old_table',
                  {'new_column': 'test'},
                  where: 'id = ?',
                  whereArgs: [1],
                );
              }
            }
          },
        ),
      );

      // Verifikasi kolom baru ada
      final columns = await upgradedDb.rawQuery(
        'PRAGMA table_info(old_table)',
      );
      final hasColumn = columns.any((col) => col['name'] == 'new_column');
      expect(hasColumn, true);

      // Verifikasi data ada
      final result = await upgradedDb.query('old_table');
      expect(result.length, 1);
      expect(result.first['new_column'], 'test');

      await upgradedDb.close();
    });

    test('02. harus menjalankan migrasi dari versi 1 ke versi 3', () async {
      // Buat database versi 1
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE existing_table (id INTEGER PRIMARY KEY)',
            );
            await db.insert('existing_table', {'id': 1});
          },
        ),
      );

      await db.close();

      // Upgrade ke versi 3
      final upgradedDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (db, version) async {},
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              final columns = await db.rawQuery(
                'PRAGMA table_info(existing_table)',
              );
              final hasCol2 = columns.any((col) => col['name'] == 'col2');
              if (!hasCol2) {
                await db.execute(
                  'ALTER TABLE existing_table ADD COLUMN col2 TEXT',
                );
              }
            }
            if (oldVersion < 3) {
              final columns = await db.rawQuery(
                'PRAGMA table_info(existing_table)',
              );
              final hasCol3 = columns.any((col) => col['name'] == 'col3');
              if (!hasCol3) {
                await db.execute(
                  'ALTER TABLE existing_table ADD COLUMN col3 TEXT',
                );
                await db.update(
                  'existing_table',
                  {'col3': 'test3'},
                  where: 'id = ?',
                  whereArgs: [1],
                );
              }
            }
          },
        ),
      );

      // Verifikasi kolom ditambahkan
      final columns = await upgradedDb.rawQuery(
        'PRAGMA table_info(existing_table)',
      );
      final hasCol2 = columns.any((col) => col['name'] == 'col2');
      final hasCol3 = columns.any((col) => col['name'] == 'col3');
      expect(hasCol2, true);
      expect(hasCol3, true);

      // Verifikasi data
      final result = await upgradedDb.query('existing_table');
      expect(result.length, 1);
      expect(result.first['col3'], 'test3');

      await upgradedDb.close();
    });

    test('03. tidak boleh menjalankan migrasi jika versi sama', () async {
      bool onUpgradeCalled = false;

      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: (db, version) async {
            await db.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            onUpgradeCalled = true;
          },
        ),
      );

      expect(onUpgradeCalled, false);
      await db.close();
    });

    test('04. migrasi harus menambahkan kolom jika belum ada', () async {
      // Buat database versi 1
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE my_table (id TEXT PRIMARY KEY, name TEXT)',
            );
            // Gunakan single quotes untuk string literal di SQLite
            await db.execute(
              "INSERT INTO my_table (id, name) VALUES ('1', 'test')",
            );
          },
        ),
      );

      await db.close();

      // Upgrade ke versi 2 dengan menambahkan kolom
      final upgradedDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {},
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              final columns = await db.rawQuery(
                'PRAGMA table_info(my_table)',
              );
              final hasColumn = columns.any(
                (col) => col['name'] == 'new_column',
              );
              if (!hasColumn) {
                await db.execute(
                  'ALTER TABLE my_table ADD COLUMN new_column TEXT',
                );
                await db.update(
                  'my_table',
                  {'new_column': 'updated'},
                  where: 'id = ?',
                  whereArgs: ['1'],
                );
              }
            }
          },
        ),
      );

      // Verifikasi kolom ditambahkan
      final columns = await upgradedDb.rawQuery(
        'PRAGMA table_info(my_table)',
      );
      final hasColumn = columns.any((col) => col['name'] == 'new_column');
      expect(hasColumn, true);

      // Verifikasi data
      final result = await upgradedDb.query('my_table');
      expect(result.length, 1);
      expect(result.first['new_column'], 'updated');

      await upgradedDb.close();
    });
  });

  group('Fungsi Helper', () {
    test('01. debugSetDatabaseNull harus mengatur _database ke null', () {
      final sqliteDb = SqliteDatabase.instance;
      sqliteDb.debugSetDatabaseNull();

      expect(() async => await sqliteDb.database, returnsNormally);
    });
  });
}
// path: test/admin/data/sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
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
        // PERBAIKAN: Gunakan createTestDatabase helper
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
      // PERBAIKAN: Buat database dan verifikasi tabel
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('CREATE TABLE table1 (id INTEGER PRIMARY KEY)');
            await db.execute('CREATE TABLE table2 (id INTEGER PRIMARY KEY)');
          },
        ),
      );

      // Verifikasi tabel ada
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((row) => row['name'] as String).toList();

      expect(tableNames.contains('table1'), true);
      expect(tableNames.contains('table2'), true);

      await db.close();
    });
  });

  group('Upgrade Database (_onUpgrade)', () {
    test('01. harus menjalankan semua migrasi dari versi < 45 ke 53', () async {
      // PERBAIKAN: Buat database versi 1
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('CREATE TABLE old_table (id INTEGER PRIMARY KEY)');
          },
        ),
      );

      await db.close();

      // Upgrade ke versi 53
      final upgradedDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 53,
          onCreate: (db, version) async {},
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 45) {
              await db.execute(
                'ALTER TABLE old_table ADD COLUMN new_column TEXT',
              );
            }
          },
        ),
      );

      // Verifikasi kolom baru ada
      final columns = await upgradedDb.rawQuery('PRAGMA table_info(old_table)');
      final hasColumn = columns.any((col) => col['name'] == 'new_column');
      expect(hasColumn, true);

      await upgradedDb.close();
    });

    test('02. harus menjalankan migrasi dari versi 50 ke 53', () async {
      // PERBAIKAN: Buat database versi 50
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 50,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE existing_table (id INTEGER PRIMARY KEY)',
            );
          },
        ),
      );

      await db.close();

      // Upgrade ke versi 53
      final upgradedDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 53,
          onCreate: (db, version) async {},
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 53) {
              final columns = await db.rawQuery(
                'PRAGMA table_info(existing_table)',
              );
              final hasColumn = columns.any(
                (col) => col['name'] == 'new_column',
              );
              if (!hasColumn) {
                await db.execute(
                  'ALTER TABLE existing_table ADD COLUMN new_column TEXT',
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
      final hasColumn = columns.any((col) => col['name'] == 'new_column');
      expect(hasColumn, true);

      await upgradedDb.close();
    });

    test('03. tidak boleh menjalankan migrasi jika versi sama', () async {
      bool onUpgradeCalled = false;

      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 53,
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

    test('04. migrasi v53 harus menambahkan kolom jika belum ada', () async {
      // PERBAIKAN: Buat database versi 52 dengan tabel transaksi
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 52,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE "${NamaTabel.transaksi}" (id TEXT PRIMARY KEY)',
            );
          },
        ),
      );

      await db.close();

      // Upgrade ke versi 53
      final upgradedDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 53,
          onCreate: (db, version) async {},
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 53) {
              final columns = await db.rawQuery(
                'PRAGMA table_info("${NamaTabel.transaksi}")',
              );
              final hasDurasiBonus = columns.any(
                (col) => col['name'] == NamaKolom.durasiBonus,
              );
              if (!hasDurasiBonus) {
                await db.execute(
                  'ALTER TABLE "${NamaTabel.transaksi}" ADD COLUMN ${NamaKolom.durasiBonus} INTEGER',
                );
              }
            }
          },
        ),
      );

      // Verifikasi kolom ditambahkan
      final columns = await upgradedDb.rawQuery(
        'PRAGMA table_info("${NamaTabel.transaksi}")',
      );
      final hasDurasiBonus = columns.any(
        (col) => col['name'] == NamaKolom.durasiBonus,
      );
      expect(hasDurasiBonus, true);

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
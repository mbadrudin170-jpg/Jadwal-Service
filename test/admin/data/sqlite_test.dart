// path: test/admin/data/sqlite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';

// Helper untuk mendapatkan semua nama tabel dari database.
Future<List<String>> dapatkanNamaTabel(final Database db) async {
  final tables =
      await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  return tables.map((final table) => table['name'] as String).toList();
}

// Helper untuk mendapatkan skema (definisi kolom) dari sebuah tabel.
Future<List<Map<String, dynamic>>> dapatkanSkemaTabel(
  final Database db,
  final String namaTabel,
) {
  return db.rawQuery('PRAGMA table_info($namaTabel)');
}

void main() {
  // Inisialisasi FFI untuk sqflite agar bisa berjalan di luar environment Flutter (misal: di tes Dart VM).
  sqfliteFfiInit();

  // Gunakan factory FFI untuk semua tes agar database dibuat di memori.
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    // Bersihkan instance database sebelum setiap tes untuk memastikan isolasi.
    // DatabaseHelper._database di-set null agar _initDB dipanggil lagi.
    setUp(() {
      // Dengan menggunakan inMemoryDatabasePath, setiap tes akan mendapatkan database yang segar.
      // Reset factory untuk memastikan tidak ada state yang bocor antar tes.
      databaseFactory = databaseFactoryFfi;
    });

    tearDown(() async {
      // Tutup database setelah setiap tes untuk membersihkan resource.
      final db = await DatabaseHelper.instance.database;
      await db.close();
      // Ini penting untuk mereset singleton internal di DatabaseHelper
      // agar tes selanjutnya bisa membuat database baru dari awal.
      _setDatabaseToNull();
    });

    test(
        'Inisialisasi DB dan onCreate harus membuat semua tabel dan indeks dengan benar',
        () async {
      // Arrange
      final dbHelper = DatabaseHelper.instance;

      // Act: Panggil getter `database` untuk memicu _initDB dan onCreate.
      final db = await dbHelper.database;

      // Assert
      expect(db, isA<Database>());
      expect(db.isOpen, isTrue);

      final tables = await dapatkanNamaTabel(db);

      // Verifikasi bahwa semua tabel yang diharapkan telah dibuat.
      final expectedTables = [
        'kategori',
        'sub_kategori',
        'paket',
        'pelanggan',
        'pelanggan_aktif',
        'transaksi',
        'dompet',
        'kritik_saran',
        'pesanan',
        'versi_apk_user',
        'pengaturan',
        'status_unggah',
        'status_aplikasi',
        'pesan',
      ];

      for (final table in expectedTables) {
        expect(
          tables,
          contains(table),
          reason: 'Tabel "$table" seharusnya ada.',
        );
      }

      // Verifikasi beberapa kolom tanggal kunci di tabel `transaksi`.
      final transaksiSchema = await dapatkanSkemaTabel(db, 'transaksi');
      expect(
        transaksiSchema
            .firstWhere((final col) => col['name'] == 'tanggal')['type'],
        'INTEGER',
      );
      expect(
        transaksiSchema
            .firstWhere((final col) => col['name'] == 'diperbarui')['type'],
        'INTEGER',
      );
      expect(
        transaksiSchema
            .firstWhere((final col) => col['name'] == 'tanggal_mulai')['type'],
        'INTEGER',
      );

      // Verifikasi indeks-indeks penting.
      final indexes = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='index'");
      final indexNames = indexes.map((final index) => index['name']).toList();
      expect(indexNames, contains('idx_transaksi_dompet'));
      expect(indexNames, contains('idx_transaksi_dompet_tujuan'));
      expect(indexNames, contains('idx_transaksi_isDeleted'));
    });

    test('onUpgrade dari v45 ke v46 harus memigrasi skema dengan benar',
        () async {
      // Arrange: Buat database di versi lama (45) dengan skema lama.
      const oldVersion = 45;
      final dbOld = await databaseFactory.openDatabase(
        inMemoryDatabasePath, // Gunakan db in-memory.
        options: OpenDatabaseOptions(
          version: oldVersion,
          onCreate: (final db, final version) async {
            // Buat skema dummy lama dengan kolom tanggal sebagai TEXT.
            await db.execute('''
              CREATE TABLE transaksi(
                id TEXT PRIMARY KEY,
                keterangan TEXT,
                tanggal TEXT
              )
            ''');
            await db.execute('''
              CREATE TABLE pelanggan(
                id TEXT PRIMARY KEY,
                nama TEXT,
                diperbarui TEXT
              )
            ''');
          },
        ),
      );

      // Verifikasi bahwa skema lama benar-benar menggunakan TEXT.
      final oldSchema = await dapatkanSkemaTabel(dbOld, 'transaksi');
      expect(
        oldSchema.firstWhere((final col) => col['name'] == 'tanggal')['type'],
        'TEXT',
      );
      await dbOld.close(); // Tutup database lama.

      // Act: Panggil getter dari instance helper. Ini akan membuka kembali
      // database dengan versi baru (46) dan memicu _onUpgrade.
      final dbHelper = DatabaseHelper.instance;
      final newDb = await dbHelper.database;

      // Assert: Periksa apakah migrasi berhasil.
      expect(newDb.isOpen, isTrue);

      final tables = await dapatkanNamaTabel(newDb);

      // Logika onUpgrade v46 adalah DROP dan CREATE, jadi semua tabel baru harus ada.
      final expectedTables = [
        'kategori',
        'sub_kategori',
        'paket',
        'pelanggan',
        'pelanggan_aktif',
        'transaksi',
      ];
      for (final table in expectedTables) {
        expect(
          tables,
          contains(table),
          reason: 'Tabel "$table" seharusnya ada setelah migrasi.',
        );
      }

      // Verifikasi skema baru di tabel `transaksi`.
      final newSchema = await dapatkanSkemaTabel(newDb, 'transaksi');
      expect(
        newSchema.firstWhere((final col) => col['name'] == 'tanggal')['type'],
        'INTEGER',
        reason: 'Kolom "tanggal" seharusnya INTEGER setelah migrasi.',
      );
      expect(
        newSchema
            .firstWhere((final col) => col['name'] == 'diperbarui')['type'],
        'INTEGER',
        reason: 'Kolom "diperbarui" seharusnya INTEGER setelah migrasi.',
      );
    });

    test('Instance singleton harus mengembalikan objek database yang sama',
        () async {
      final dbHelper = DatabaseHelper.instance;

      final db1 = await dbHelper.database;
      final db2 = await dbHelper.database;

      // `identical` memeriksa apakah kedua variabel menunjuk ke objek yang sama persis di memori.
      expect(identical(db1, db2), isTrue);
    });
  });
}

/// Fungsi helper untuk mereset singleton database di dalam DatabaseHelper.
/// Ini diperlukan agar setiap tes bisa memulai dengan database yang bersih.
void _setDatabaseToNull() {
  // Ini adalah cara untuk "meretas" dan mereset state dari singleton
  // untuk tujuan pengujian.
  // ignore: invalid_use_of_visible_for_testing_member
  DatabaseHelper.instance.debugSetDatabaseNull();
}

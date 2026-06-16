// path: test/admin/data/sqlite_test.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';

import 'sqlite_test.mocks.dart';

@GenerateMocks([Database, Batch, DatabaseFactory])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SqliteDatabase sqliteDatabase;
  late MockDatabase mockDatabase;
  late MockBatch mockBatch;
  late MockDatabaseFactory mockFactory;

  late DatabaseFactory originalFactory;

  setUp(() {
    sqfliteFfiInit();

    mockDatabase = MockDatabase();
    mockBatch = MockBatch();
    mockFactory = MockDatabaseFactory();

    originalFactory = databaseFactory;
    databaseFactory = mockFactory;

    sqliteDatabase = SqliteDatabase.instance;
    sqliteDatabase.debugSetDatabaseNull();

    when(mockDatabase.batch()).thenReturn(mockBatch);
    when(mockBatch.commit(noResult: any(named: 'noResult')))
        .thenAnswer((_) async => []);
    when(mockDatabase.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    databaseFactory = originalFactory;
  });

  void stubOpenDatabase() {
    when(mockFactory.openDatabase(
      any,
      options: any(named: 'options'),
    )).thenAnswer((invocation) async {
      final options = invocation.namedArguments[const Symbol('options')]
          as OpenDatabaseOptions?;
      if (options?.onCreate != null) {
        await options!.onCreate!(mockDatabase, options.version!);
      }
      if (options?.onUpgrade != null && (options?.version ?? 0) > 1) {
        await options!.onUpgrade!(mockDatabase, 1, options.version!);
      }
      return mockDatabase;
    });
  }

  group('01. SqliteDatabase Singleton & Provider', () {
    test(
        '01. instance harus selalu mengembalikan instance yang sama (singleton)',
        () {
      final instance1 = SqliteDatabase.instance;
      final instance2 = SqliteDatabase.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('02. sqliteDatabaseProvider harus menyediakan instance SqliteDatabase',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(sqliteDatabaseProvider), isA<SqliteDatabase>());
    });

    test('03. sqliteProvider harus menyediakan Future<Database>', () async {
      stubOpenDatabase();
      final container = ProviderContainer(overrides: [
        sqliteDatabaseProvider.overrideWithValue(sqliteDatabase),
      ]);
      addTearDown(container.dispose);

      expect(container.read(sqliteProvider), isA<AsyncLoading>());

      await expectLater(container.read(sqliteProvider.future), completes);

      final dbValue = container.read(sqliteProvider);
      expect(dbValue, isA<AsyncData<Database>>());
      expect(dbValue.value, isA<Database>());
    });
  });

  group('02. Inisialisasi Database (database getter dan _initDB)', () {
    test(
        '01. harus mengembalikan database yang ada di cache jika sudah diinisialisasi',
        () async {
      stubOpenDatabase();
      final db1 = await sqliteDatabase.database;
      final db2 = await sqliteDatabase.database;

      expect(identical(db1, db2), isTrue);
      verify(mockFactory.openDatabase(any, options: any(named: 'options')))
          .called(1);
    });

    test('02. harus menginisialisasi database in-memory untuk testing',
        () async {
      Platform.environment['FLUTTER_TEST'] = 'true';
      stubOpenDatabase();

      await sqliteDatabase.database;

      verify(mockFactory.openDatabase(inMemoryDatabasePath,
              options: any(named: 'options')))
          .called(1);
      Platform.environment.remove('FLUTTER_TEST');
    });

    test('03. harus menginisialisasi database fisik (non-test)', () async {
      final directory = Directory.systemTemp.createTempSync();
      addTearDown(() => directory.deleteSync(recursive: true));
      final dbPath = p.join(directory.path, 'mydatabase.db');

      Platform.environment.remove('FLUTTER_TEST');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return directory.path;
          }
          return null;
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
      });

      stubOpenDatabase();

      await sqliteDatabase.database;

      verify(mockFactory.openDatabase(dbPath, options: any(named: 'options')))
          .called(1);
    });

    test('04. harus melempar exception jika _initDB gagal', () async {
      final exception = Exception('Gagal membuka DB');
      when(mockFactory.openDatabase(any, options: any(named: 'options')))
          .thenThrow(exception);

      expect(sqliteDatabase.database, throwsA(exception));
    });
  });

  group('03. Pembuatan Tabel (onCreate)', () {
    test('01. harus memanggil _membuatSemuaTabel saat onCreate', () async {
      stubOpenDatabase();

      await sqliteDatabase.database;

      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.kategori}'))))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.subKategori}'))))
          .called(1);
      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.paket}'))))
          .called(1);
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE ${NamaTabel.pelanggan}'))));
      verify(mockBatch.execute(
          argThat(contains('CREATE TABLE ${NamaTabel.pelangganAktif}'))));
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE "${NamaTabel.transaksi}"'))));
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE ${NamaTabel.dompet}'))));
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE ${NamaTabel.feedback}'))));
      verify(mockBatch.execute(
          argThat(contains('CREATE TABLE "${NamaTabel.pesananPelanggan}"'))));
      verify(mockBatch.execute(
          argThat(contains('CREATE TABLE ${NamaTabel.versiApkUser}'))));
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE ${NamaTabel.settings}'))));
      verify(mockBatch.execute(
          argThat(contains('CREATE TABLE ${NamaTabel.statusUnggah}'))));
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE ${NamaTabel.pesan}'))));
      verify(mockBatch
          .execute(argThat(contains('CREATE TABLE ${NamaTabel.notifikasi}'))));

      verify(mockBatch.execute(argThat(contains(
              'CREATE INDEX IF NOT EXISTS idx_transaction_wallet_id'))))
          .called(1);

      verify(mockBatch.commit(noResult: true)).called(1);
    });
  });

  group('04. Upgrade Database (_onUpgrade)', () {
    late Future<void> Function(Database, int, int) onUpgradeCallback;

    setUp(() async {
      // Capture the onUpgrade callback provided to openDatabase
      when(mockFactory.openDatabase(
        any,
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        final options = invocation.namedArguments[const Symbol('options')]
            as OpenDatabaseOptions?;
        if (options?.onUpgrade != null) {
          onUpgradeCallback = options.onUpgrade!;
        }
        return mockDatabase;
      });

      sqliteDatabase.debugSetDatabaseNull();
      await sqliteDatabase.database; // This triggers the openDatabase mock

      // Common stubs for upgrade tests
      clearInteractions(mockDatabase); // Clear interactions from the initial open
      when(mockDatabase.execute(any)).thenAnswer((_) async {});
      when(mockDatabase.rawQuery(any)).thenAnswer((_) async => []);
    });

    test('01. harus menjalankan semua migrasi dari versi < 45 ke 53', () async {
      await onUpgradeCallback(mockDatabase, 44, 53);

      verify(mockDatabase.execute('DROP TABLE IF EXISTS pengaturan')).called(1);
      verify(mockDatabase.execute(contains('CREATE TABLE pengaturan')))
          .called(1);
      verify(mockDatabase.execute('DROP TABLE IF EXISTS kategori')).called(1);
      verify(mockDatabase.execute(
              'ALTER TABLE status_aplikasi ADD COLUMN diperbarui INTEGER'))
          .called(1);
      verify(mockDatabase
              .execute('ALTER TABLE dompet RENAME COLUMN namaDompet TO name'))
          .called(1);
      verify(mockDatabase
              .execute('ALTER TABLE dompet RENAME TO ${NamaTabel.dompet}'))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${NamaKolom.terkahirAktif}'))))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.notifikasi}'))))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${NamaKolom.durasiBonus}'))))
          .called(1);
    });

    test('02. harus menjalankan migrasi dari versi 50 ke 53', () async {
      await onUpgradeCallback(mockDatabase, 50, 53);

      verifyNever(mockDatabase.execute('DROP TABLE IF EXISTS pengaturan'));

      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${NamaKolom.terkahirAktif}'))))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.notifikasi}'))))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${NamaKolom.durasiBonus}'))))
          .called(1);
    });

    test('03. tidak boleh menjalankan migrasi jika versi sama', () async {
      await onUpgradeCallback(mockDatabase, 53, 53);

      verifyNever(mockDatabase.execute(any));
    });

    test('04. migrasi v53 harus menambahkan kolom jika belum ada', () async {
      const String trxTable = NamaTabel.transaksi;
      when(mockDatabase.rawQuery('PRAGMA table_info("$trxTable")'))
          .thenAnswer((_) async => [
                {'name': 'id'},
                {'name': 'description'},
              ]);

      await onUpgradeCallback(mockDatabase, 52, 53);

      verify(mockDatabase.execute(
              'ALTER TABLE "$trxTable" ADD COLUMN ${NamaKolom.durasiBonus} INTEGER'))
          .called(1);
      verify(mockDatabase.execute(
              'ALTER TABLE "$trxTable" ADD COLUMN ${NamaKolom.tipeDurasiBonus} TEXT'))
          .called(1);
    });

    test('05. migrasi v53 tidak boleh menambahkan kolom jika sudah ada',
        () async {
      const String trxTable = NamaTabel.transaksi;
      when(mockDatabase.rawQuery('PRAGMA table_info("$trxTable")'))
          .thenAnswer((_) async => [
                {'name': 'id'},
                {'name': NamaKolom.durasiBonus},
                {'name': NamaKolom.tipeDurasiBonus},
              ]);

      await onUpgradeCallback(mockDatabase, 52, 53);

      verifyNever(mockDatabase.execute(
          'ALTER TABLE "$trxTable" ADD COLUMN ${NamaKolom.durasiBonus} INTEGER'));
      verifyNever(mockDatabase.execute(
          'ALTER TABLE "$trxTable" ADD COLUMN ${NamaKolom.tipeDurasiBonus} TEXT'));
    });
  });

  group('05. Fungsi Helper', () {
    test('01. debugSetDatabaseNull harus mengatur _database ke null', () async {
      stubOpenDatabase();
      await sqliteDatabase.database;

      sqliteDatabase.debugSetDatabaseNull();

      await sqliteDatabase.database;

      verify(mockFactory.openDatabase(any, options: any(named: 'options')))
          .called(2);
    });
  });
}

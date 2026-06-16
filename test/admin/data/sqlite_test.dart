// path: test/admin/data/sqlite_test.dart
import 'dart:io';

import 'package:flutter/services.dart' show MethodCall, MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:path/path.dart' as p;
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/constant/column_names.dart';

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

    sqliteDatabase = DatabaseHelper.instance;
    sqliteDatabase = SqliteDatabase.instance;
    sqliteDatabase.debugSetDatabaseNull();

    when(mockDatabase.batch()).thenReturn(mockBatch);
    when(mockBatch.commit(noResult: anyNamed('noResult')))
        .thenAnswer((_) async => []);
    when(mockDatabase.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    databaseFactory = originalFactory;
  });

  void stubOpenDatabase() {
    when(mockFactory.openDatabase(
      any,
      options: anyNamed('options'),
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

  group('01. DatabaseHelper Singleton & Provider', () {
  group('01. SqliteDatabase Singleton & Provider', () {
    test(
        '01. instance harus selalu mengembalikan instance yang sama (singleton)',
        () {
      final instance1 = DatabaseHelper.instance;
      final instance2 = DatabaseHelper.instance;
      final instance1 = SqliteDatabase.instance;
      final instance2 = SqliteDatabase.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('02. databaseHelperProvider harus menyediakan instance DatabaseHelper',
    test('02. sqliteDatabaseProvider harus menyediakan instance SqliteDatabase',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(databaseHelperProvider), isA<DatabaseHelper>());
      expect(container.read(sqliteDatabaseProvider), isA<SqliteDatabase>());
    });

    test('03. databaseProvider harus menyediakan Future<Database>', () async {
      stubOpenDatabase();
      final container = ProviderContainer(overrides: [
        databaseHelperProvider.overrideWithValue(sqliteDatabase),
        sqliteDatabaseProvider.overrideWithValue(sqliteDatabase),
      ]);
      addTearDown(container.dispose);

      expect(container.read(databaseProvider), isA<AsyncLoading>());

      await expectLater(container.read(databaseProvider.future), completes);

      final dbValue = container.read(databaseProvider);
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
      verify(mockFactory.openDatabase(any, options: anyNamed('options')))
          .called(1);
    });

    test('02. harus menginisialisasi database in-memory untuk testing',
        () async {
      Platform.environment['FLUTTER_TEST'] = 'true';
      stubOpenDatabase();

      await sqliteDatabase.database;

      verify(mockFactory.openDatabase(inMemoryDatabasePath,
              options: anyNamed('options')))
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

      verify(mockFactory.openDatabase(dbPath, options: anyNamed('options')))
          .called(1);
    });

    test('04. harus melempar exception jika _initDB gagal', () async {
      final exception = Exception('Gagal membuka DB');
      when(mockFactory.openDatabase(any, options: anyNamed('options')))
          .thenThrow(exception);

      expect(sqliteDatabase.database, throwsA(exception));
    });
  });

  group('03. Pembuatan Tabel (onCreate)', () {
    test('01. harus memanggil _membuatSemuaTabel saat onCreate', () async {
      stubOpenDatabase();

      await sqliteDatabase.database;

      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.category}'))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.category)}'))
                  as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.subCategory}'))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.subCategory)}'))
                  as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.package}')) as String))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.package)}')) as String))
          .called(1);
      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.customer}'))))
              .execute(argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.customer)}')) as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.activeCustomer}'))))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.activeCustomer)}')) as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE "${NamaTabel.transactions}"'))))
              argThat(contains('CREATE TABLE "${TableNameValue.get(TableName.transactions)}"')) as String))
          .called(1);
      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.wallet}'))))
              .execute(argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.wallet)}')) as String))
          .called(1);
      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.feedback}'))))
              .execute(argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.feedback)}')) as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE "${NamaTabel.customerOrder}"'))))
              argThat(contains('CREATE TABLE "${TableNameValue.get(TableName.customerOrder)}"')) as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.userApkVersion}'))))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.userApkVersion)}')) as String))
          .called(1);
      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.settings}'))))
              .execute(argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.settings)}')) as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.uploadStatus}'))))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.uploadStatus)}')) as String))
          .called(1);
      verify(mockBatch
              .execute(argThat(contains('CREATE TABLE ${NamaTabel.message}'))))
              .execute(argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.message)}')) as String))
          .called(1);
      verify(mockBatch.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.notification}'))))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.notification)}')) as String))
          .called(1);

      verify(mockBatch.execute(argThat(contains(
              'CREATE INDEX IF NOT EXISTS idx_transaction_wallet_id'))))
              'CREATE INDEX IF NOT EXISTS idx_transaction_wallet_id')) as String))
          .called(1);

      verify(mockBatch.commit(noResult: true)).called(1);
    });
  });

  group('04. Upgrade Database (_onUpgrade)', () {
    Future<void> runUpgrade(int oldVersion, int newVersion) async {
      final options = OpenDatabaseOptions(
        version: newVersion,
        onUpgrade: sqliteDatabase.testOnUpgrade,
      );
      await options.onUpgrade!(mockDatabase, oldVersion, newVersion);
    }

    setUp(() {
      when(mockDatabase.execute(any)).thenAnswer((_) async {});
      when(mockDatabase.rawQuery(any)).thenAnswer((_) async => []);
    });

    test('01. harus menjalankan semua migrasi dari versi < 45 ke 53', () async {
      await runUpgrade(44, 53);

      verify(mockDatabase.execute('DROP TABLE IF EXISTS pengaturan')).called(1);
      verify(mockDatabase.execute(contains('CREATE TABLE pengaturan')))
          .called(1);
      verify(mockDatabase.execute('DROP TABLE IF EXISTS category')).called(1);
      verify(mockDatabase.execute(
              'ALTER TABLE status_aplikasi ADD COLUMN diperbarui INTEGER'))
          .called(1);
      verify(mockDatabase
              .execute('ALTER TABLE dompet RENAME COLUMN namaDompet TO name'))
          .called(1);
      verify(mockDatabase
              .execute('ALTER TABLE dompet RENAME TO ${NamaTabel.dompet}'))
              .execute('ALTER TABLE dompet RENAME TO ${TableNameValue.get(TableName.wallet)}'))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${ColumnNames.lastActiveAt}'))))
              argThat(contains('ADD COLUMN ${ColumnNames.lastActiveAt}')) as String))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.notification}'))))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.notification)}')) as String))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${ColumnNames.durasiBonus}'))))
              argThat(contains('ADD COLUMN ${ColumnNames.durasiBonus}')) as String))
          .called(1);
    });

    test('02. harus menjalankan migrasi dari versi 50 ke 53', () async {
      await runUpgrade(50, 53);

      verifyNever(mockDatabase.execute('DROP TABLE IF EXISTS pengaturan'));

      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${ColumnNames.lastActiveAt}'))))
              argThat(contains('ADD COLUMN ${ColumnNames.lastActiveAt}')) as String))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('CREATE TABLE ${NamaTabel.notification}'))))
              argThat(contains('CREATE TABLE ${TableNameValue.get(TableName.notification)}')) as String))
          .called(1);
      verify(mockDatabase.execute(
              argThat(contains('ADD COLUMN ${ColumnNames.durasiBonus}'))))
              argThat(contains('ADD COLUMN ${ColumnNames.durasiBonus}')) as String))
          .called(1);
    });

    test('03. tidak boleh menjalankan migrasi jika versi sama', () async {
      await runUpgrade(53, 53);

      verifyNever(mockDatabase.execute(any));
    });

    test('04. _migrateToV53 harus menambahkan kolom jika belum ada', () async {
      when(mockDatabase.rawQuery('PRAGMA table_info("${NamaTabel.transaksi}")'))
      final String trxTable = TableNameValue.get(TableName.transactions);
      when(mockDatabase.rawQuery('PRAGMA table_info("$trxTable")'))
          .thenAnswer((_) async => [
                {'name': 'id'},
                {'name': 'description'},
              ]);

      await sqliteDatabase.testMigrateToV53(mockDatabase);

      verify(mockDatabase.execute(
              'ALTER TABLE "${NamaTabel.transaksi}" ADD COLUMN durasi_bonus INTEGER'))
              'ALTER TABLE "$trxTable" ADD COLUMN ${ColumnNames.durasiBonus} INTEGER'))
          .called(1);
      verify(mockDatabase.execute(
              'ALTER TABLE "${NamaTabel.transaksi}" ADD COLUMN tipe_durasi_bonus TEXT'))
              'ALTER TABLE "$trxTable" ADD COLUMN ${ColumnNames.durasiBonusType} TEXT'))
          .called(1);
    });

    test('05. _migrateToV53 tidak boleh menambahkan kolom jika sudah ada',
        () async {
      when(mockDatabase.rawQuery('PRAGMA table_info("${NamaTabel.transaksi}")'))
      final String trxTable = TableNameValue.get(TableName.transactions);
      when(mockDatabase.rawQuery('PRAGMA table_info("$trxTable")'))
          .thenAnswer((_) async => [
                {'name': 'id'},
                {'name': 'durasi_bonus'},
                {'name': 'tipe_durasi_bonus'},
                {'name': ColumnNames.durasiBonus},
                {'name': ColumnNames.durasiBonusType},
              ]);

      await sqliteDatabase.testMigrateToV53(mockDatabase);

      verifyNever(mockDatabase.execute(
          'ALTER TABLE "${NamaTabel.transaksi}" ADD COLUMN durasi_bonus INTEGER'));
          'ALTER TABLE "$trxTable" ADD COLUMN ${ColumnNames.durasiBonus} INTEGER'));
      verifyNever(mockDatabase.execute(
          'ALTER TABLE "${NamaTabel.transaksi}" ADD COLUMN tipe_durasi_bonus TEXT'));
          'ALTER TABLE "$trxTable" ADD COLUMN ${ColumnNames.durasiBonusType} TEXT'));
    });
  });

  group('05. Fungsi Helper', () {
    test('01. debugSetDatabaseNull harus mengatur _database ke null', () async {
      stubOpenDatabase();
      await sqliteDatabase.database;

      sqliteDatabase.debugSetDatabaseNull();

      await sqliteDatabase.database;

      verify(mockFactory.openDatabase(any, options: anyNamed('options')))
          .called(2);
    });
  });
}

// Extension to expose private methods for testing
extension TestSqliteDatabase on DatabaseHelper {
extension TestSqliteDatabase on SqliteDatabase {
  Future<void> testOnUpgrade(Database db, int oldVersion, int newVersion) {
    return _onUpgrade(db, oldVersion, newVersion);
  }

  Future<void> testMigrateToV53(Database db) {
    return _migrateToV53(db); // Diperbaiki: ini adalah method private
    return _migrateToV53(db);
  }
}

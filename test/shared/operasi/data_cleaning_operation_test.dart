// path: test/shared/operasi/data_cleaning_operation_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/data_cleaning_operation.dart';

import 'data_cleaning_operation_test.mocks.dart';

// Inisialisasi FFI untuk sqflite
void sqfliteTestInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

@GenerateMocks([SqliteDatabase])
void main() {
  sqfliteTestInit();
  late Database mockDatabase;
  late MockDatabaseHelper mockDbHelper;
  late FakeFirebaseFirestore fakeFirestore;
  late DataCleaningOperation dataCleaningOperation;

  // Nama tabel untuk pengujian
  final testTable = TableNameValue.get(TableName.customer);

  setUp(() async {
    // Setup untuk SQLite
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    // Buat tabel pengujian di database mock
    await mockDatabase.execute('''
      CREATE TABLE $testTable (
        id TEXT PRIMARY KEY,
        name TEXT,
        ${ColumnNames.isDeleted} INTEGER DEFAULT 0,
        ${ColumnNames.archivedAt} INTEGER
      )
    ''');

    // Atur mockDbHelper untuk mengembalikan database mock
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);

    // Setup untuk Firestore
    fakeFirestore = FakeFirebaseFirestore();

    // Inisialisasi kelas yang diuji dengan dependensi mock
    dataCleaningOperation = DataCleaningOperation(
      dbHelper: mockDbHelper,
      firestore: fakeFirestore,
    );
  });

  tearDown(() async {
    await mockDatabase.close();
  });

  test(
      'deleteAllExpiredArchivedData should delete old archived data from SQLite and Firestore',
      () async {
    // --- Persiapan Data ---
    final now = DateTime.now().toUtc();
    const retentionDays = 30;
    final timeLimit = now.subtract(const Duration(days: retentionDays));

    // Data yang harus dihapus (lebih tua dari 30 hari)
    const oldDataIdSqlite = 'sqlite_old';
    const oldDataIdFirestore = 'firestore_old';
    await mockDatabase.insert(testTable, {
      'id': oldDataIdSqlite,
      'name': 'Old User SQLite',
      ColumnNames.isDeleted: 1,
      ColumnNames.archivedAt:
          timeLimit.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
    });
    await fakeFirestore.collection(testTable).doc(oldDataIdFirestore).set({
      ColumnNames.isDeleted: true,
      ColumnNames.archivedAt: Timestamp.fromDate(
        timeLimit.subtract(const Duration(days: 1)),
      ),
    });

    // Data yang tidak boleh dihapus (lebih baru dari 30 hari)
    const newDataIdSqlite = 'sqlite_new';
    const newDataIdFirestore = 'firestore_new';
    await mockDatabase.insert(testTable, {
      'id': newDataIdSqlite,
      'name': 'New User SQLite',
      ColumnNames.isDeleted: 1,
      ColumnNames.archivedAt: now.millisecondsSinceEpoch,
    });
    await fakeFirestore.collection(testTable).doc(newDataIdFirestore).set({
      ColumnNames.isDeleted: true,
      ColumnNames.archivedAt: Timestamp.now(),
    });

    // Verifikasi Awal
    final initialSqliteOld = await mockDatabase
        .query(testTable, where: 'id = ?', whereArgs: [oldDataIdSqlite]);
    expect(initialSqliteOld, isNotEmpty,
        reason: 'Initial SQLite old data should exist');
    final initialFirestoreOld =
        await fakeFirestore.collection(testTable).doc(oldDataIdFirestore).get();
    expect(initialFirestoreOld.exists, isTrue,
        reason: 'Initial Firestore old data should exist');

    // --- Eksekusi ---
    final totalDeleted =
        await dataCleaningOperation.deleteAllExpiredArchivedData(
      retentionDays: retentionDays,
    );

    // Verifikasi SQLite: data lama hilang, data baru ada
    final sqliteOldResult = await mockDatabase
        .query(testTable, where: 'id = ?', whereArgs: [oldDataIdSqlite]);
    final sqliteNewResult = await mockDatabase
        .query(testTable, where: 'id = ?', whereArgs: [newDataIdSqlite]);
    expect(sqliteOldResult, isEmpty,
        reason: 'SQLite old data should be deleted');
    expect(sqliteNewResult, isNotEmpty,
        reason: 'SQLite new data should be preserved');

    // Verifikasi Firestore: data lama hilang, data baru ada
    final firestoreOldDoc =
        await fakeFirestore.collection(testTable).doc(oldDataIdFirestore).get();
    final firestoreNewDoc =
        await fakeFirestore.collection(testTable).doc(newDataIdFirestore).get();
    expect(firestoreOldDoc.exists, isFalse,
        reason: 'Firestore old data should be deleted');
    expect(firestoreNewDoc.exists, isTrue,
        reason: 'Firestore new data should be preserved');

    // --- Verifikasi Akhir ---
    expect(totalDeleted, 2,
        reason: 'Total deleted count should be 2 (1 SQLite + 1 Firestore)');
  });
}

// path: test/shared/operasi/base_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/upload_status_operation.dart';

import 'base_operation_test.mocks.dart';

// Menambahkan Transaction ke @GenerateMocks
@GenerateMocks([
  DatabaseHelper,
  Database,
  UploadStatusOperation,
  Batch,
  Transaction,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockUploadStatusOperation mockUploadStatusOperation;
  late BaseOperation baseOperation;
  late MockTransaction mockTxn;
  late MockBatch mockBatch;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockUploadStatusOperation = MockUploadStatusOperation();
    mockTxn = MockTransaction();
    mockBatch = MockBatch();

    baseOperation = BaseOperation(
      dbHelper: mockDbHelper,
      uploadStatusOperasi: mockUploadStatusOperation,
    );

    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);

    // Stubbing yang benar untuk transaction. Ia harus bisa mengembalikan berbagai tipe Future
    // tergantung pada apa yang dijalankan di dalamnya. Kita akan handle ini di setiap tes.
    when(mockDatabase.transaction(any)).thenAnswer((invocation) async {
      final action = invocation.positionalArguments.first as Function;
      return await action(mockTxn);
    });

    // Stubbing umum untuk metode di dalam transaction. Ini mengembalikan nilai default
    // yang tipe-nya benar.
    when(mockTxn.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm'))).thenAnswer((_) async => 1);
    when(mockTxn.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'), conflictAlgorithm: anyNamed('conflictAlgorithm'))).thenAnswer((_) async => 1);
    when(mockTxn.delete(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).thenAnswer((_) async => 1);
    when(mockTxn.batch()).thenReturn(mockBatch);
    // Stub commit untuk mengembalikan List<Object?>
    when(mockBatch.commit(noResult: anyNamed('noResult'), continueOnError: anyNamed('continueOnError'), exclusive: anyNamed('exclusive'))).thenAnswer((_) async => <Object?>[]);

    when(mockUploadStatusOperation.setNeedUpload(any, transaction: anyNamed('transaction'))).thenAnswer((_) async {});
  });

  group('BaseOperation CRUD Methods', () {
    test('insert() harus memanggil txn.insert dengan benar', () async {
      const table = 'test_table';
      final data = {'id': '1', 'name': 'test'};

      await baseOperation.insert(table, data);

      verify(mockTxn.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true, transaction: mockTxn)).called(1);
    });

    test('update() harus memanggil txn.update dengan benar', () async {
      const table = 'test_table';
      final data = {'name': 'updated'};
      const id = '1';

      await baseOperation.update(table, data, id);

      verify(mockTxn.update(table, data, where: 'id = ?', whereArgs: [id])).called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true, transaction: mockTxn)).called(1);
    });

    test('softDelete() harus memanggil txn.update dengan data yang benar', () async {
      const table = 'test_table';
      const id = '1';

      await baseOperation.softDelete(table, id);

      final captured = verify(mockTxn.update(
        table,
        captureAny, 
        where: 'id = ?',
        whereArgs: [id],
      )).captured;

      final capturedMap = captured.first as Map<String, Object?>;
      expect(capturedMap['isDeleted'], 1);
      expect(capturedMap.containsKey('archivedAt'), isTrue);
      verify(mockUploadStatusOperation.setNeedUpload(true, transaction: mockTxn)).called(1);
    });

    test('delete() harus memanggil txn.delete dengan benar', () async {
      const table = 'test_table';
      const id = '1';

      await baseOperation.delete(table, id);

      verify(mockTxn.delete(table, where: 'id = ?', whereArgs: [id])).called(1);
      // Verifikasi bahwa setNeedUpload TIDAK dipanggil untuk delete permanen
      verifyNever(mockUploadStatusOperation.setNeedUpload(any, transaction: anyNamed('transaction')));
    });

    test('insertOrUpdateBatch() harus memanggil batch.commit', () async {
      const table = 'test_table';
      final dataList = [
        {'id': '1', 'name': 'test1'},
        {'id': '2', 'name': 'test2'},
      ];

      await baseOperation.insertOrUpdateBatch(table, dataList);

      verify(mockTxn.batch()).called(1);
      verify(mockBatch.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm'))).called(2);
      verify(mockBatch.commit(noResult: true)).called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true, transaction: mockTxn)).called(1);
    });
  });
}

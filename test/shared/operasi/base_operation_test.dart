// path: test/shared/operasi/base_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/upload_status_operation.dart';

import 'base_operation_test.mocks.dart';

@GenerateMocks([
  SqliteDatabase,
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

    // --- PERBAIKAN ---
    // Mengembalikan hasil `action` secara langsung, karena `action` itu sendiri
    // sudah merupakan sebuah Future.
    when(mockDatabase.transaction(any)).thenAnswer((invocation) {
      final action = invocation.positionalArguments.first as Future<dynamic>
          Function(Transaction);
      return action(mockTxn);
    });

    when(mockTxn.insert(any, any,
            conflictAlgorithm: anyNamed('conflictAlgorithm')))
        .thenAnswer((_) async => 1);
    when(mockTxn.update(any, any,
            where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async => 1);
    when(mockTxn.delete(any,
            where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async => 1);
    when(mockTxn.batch()).thenReturn(mockBatch);

    // Stub untuk batch.commit() sekarang mengembalikan List<Object?>
    when(mockBatch.commit(
            noResult: anyNamed('noResult'),
            continueOnError: anyNamed('continueOnError'),
            exclusive: anyNamed('exclusive')))
        .thenAnswer((_) async => <Object?>[]);

    when(mockUploadStatusOperation.setNeedUpload(any,
            transaction: anyNamed('transaction')))
        .thenAnswer((_) async {});
  });

  group('BaseOperation CRUD Methods', () {
    test('insert() should call txn.insert correctly', () async {
      const table = 'test_table';
      final data = {'id': '1', 'name': 'test'};

      await baseOperation.sisipkan(table, data);

      verify(mockTxn.insert(table, data,
              conflictAlgorithm: ConflictAlgorithm.replace))
          .called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('update() should call txn.update correctly', () async {
      const table = 'test_table';
      final data = {'name': 'updated'};
      const id = '1';

      await baseOperation.update(table, data, id);

      verify(mockTxn.update(table, data,
          where: '${ColumnNames.id} = ?', whereArgs: [id])).called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('softDelete() should call txn.update with correct data', () async {
      const table = 'test_table';
      const id = '1';

      await baseOperation.hapusSementara(table, id);

      final captured = verify(mockTxn.update(
        table,
        captureAny,
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      )).captured;

      final capturedMap = captured.first as Map<String, Object?>;
      expect(capturedMap[ColumnNames.isDeleted], 1);
      expect(capturedMap.containsKey(ColumnNames.archivedAt), isTrue);
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('delete() should call txn.delete correctly', () async {
      const table = 'test_table';
      const id = '1';

      await baseOperation.delete(table, id);

      verify(mockTxn.delete(table,
          where: '${ColumnNames.id} = ?', whereArgs: [id])).called(1);

      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('insertOrUpdateBatch() should call batch.commit', () async {
      const table = 'test_table';
      final dataList = [
        {'id': '1', 'name': 'test1'},
        {'id': '2', 'name': 'test2'},
      ];

      await baseOperation.insertOrUpdateBatch(table, dataList);

      verify(mockTxn.batch()).called(1);
      verify(mockBatch.insert(any, any,
              conflictAlgorithm: ConflictAlgorithm.replace))
          .called(2);
      verify(mockBatch.commit(noResult: true)).called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: mockTxn))
          .called(1);
    });
  });
}

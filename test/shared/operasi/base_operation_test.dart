// path: test/shared/operasi/base_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/status_upload_op_sqlite.dart';

import 'base_operation_test.mocks.dart';

@GenerateMocks([
  SqliteDatabase,
  Database,
  StatusUploadOpSqlite,
  Batch,
  Transaction,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockUploadStatusOperation mockUploadStatusOperation;
  late BaseOpSqlite baseOperation;
  late MockTransaction mockTxn;
  late MockBatch mockBatch;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockUploadStatusOperation = MockUploadStatusOperation();
    mockTxn = MockTransaction();
    mockBatch = MockBatch();

    baseOperation = BaseOpSqlite(
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

    when(mockUploadStatusOperation.tandaiButuhUpload(any,
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
      verify(mockUploadStatusOperation.tandaiButuhUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('update() should call txn.update correctly', () async {
      const table = 'test_table';
      final data = {'name': 'updated'};
      const id = '1';

      await baseOperation.update(table, data, id);

      verify(mockTxn.update(table, data,
          where: '${NamaKolom.id} = ?', whereArgs: [id])).called(1);
      verify(mockUploadStatusOperation.tandaiButuhUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('softDelete() should call txn.update with correct data', () async {
      const table = 'test_table';
      const id = '1';

      await baseOperation.softDelete(table, id);

      final captured = verify(mockTxn.update(
        table,
        captureAny,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      )).captured;

      final capturedMap = captured.first as Map<String, Object?>;
      expect(capturedMap[NamaKolom.diHapus], 1);
      expect(capturedMap.containsKey(NamaKolom.diarsipkanPada), isTrue);
      verify(mockUploadStatusOperation.tandaiButuhUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('delete() should call txn.delete correctly', () async {
      const table = 'test_table';
      const id = '1';

      await baseOperation.delete(table, id);

      verify(mockTxn.delete(table,
          where: '${NamaKolom.id} = ?', whereArgs: [id])).called(1);

      verify(mockUploadStatusOperation.tandaiButuhUpload(true,
              transaction: mockTxn))
          .called(1);
    });

    test('insertOrUpdateBatch() should call batch.commit', () async {
      const table = 'test_table';
      final dataList = [
        {'id': '1', 'name': 'test1'},
        {'id': '2', 'name': 'test2'},
      ];

      await baseOperation.sisipkanAtauPerbaruiBatch(table, dataList);

      verify(mockTxn.batch()).called(1);
      verify(mockBatch.insert(any, any,
              conflictAlgorithm: ConflictAlgorithm.replace))
          .called(2);
      verify(mockBatch.commit(noResult: true)).called(1);
      verify(mockUploadStatusOperation.tandaiButuhUpload(true,
              transaction: mockTxn))
          .called(1);
    });
  });
}

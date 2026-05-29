// path: test/shared/operasi/base_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/upload_status_operation.dart';

import 'base_operation_test.mocks.dart';

// Kelas mock untuk Transaction karena sqflite tidak menyediakannya secara langsung
class MockTransaction extends Mock implements Transaction {}

@GenerateMocks([
  DatabaseHelper,
  Database,
  UploadStatusOperation,
  Batch,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockUploadStatusOperation mockUploadStatusOperation;
  late BaseOperation baseOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockUploadStatusOperation = MockUploadStatusOperation();

    // Inisialisasi BaseOperation dengan dependensi mock
    baseOperation = BaseOperation(
      dbHelper: mockDbHelper,
      uploadStatusOperasi: mockUploadStatusOperation,
    );

    // Atur perilaku default untuk mock
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);

    // Ini bagian penting: kita mock implementasi dari `db.transaction()`
    // Ia akan langsung menjalankan action yang diberikan dengan sebuah mock transaction
    when(mockDatabase.transaction(any)).thenAnswer((invocation) async {
      final action = invocation.positionalArguments.first as Future<dynamic>
          Function(Transaction);
      // Kita buat mock Transaction baru setiap kali transaction dipanggil
      final mockTxn = MockTransaction();
      // Siapkan batch mock jika diperlukan
      final mockBatch = MockBatch();
      when(mockTxn.batch()).thenReturn(mockBatch);
      return await action(mockTxn);
    });
  });

  group('BaseOperation Transaction Logic', () {
    test(
        'harus memanggil setNeedUpload(true) saat fromServer adalah false (default)',
        () async {
      // ATUR & JALANKAN
      await baseOperation.runComplexOperation((txn) async {
        // Aksi dummy
      });

      // VERIFIKASI
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: anyNamed('transaction')))
          .called(1);
    });

    test('TIDAK boleh memanggil setNeedUpload saat fromServer adalah true',
        () async {
      // ATUR & JALANKAN
      await baseOperation.runComplexOperation((txn) async {
        // Aksi dummy
      }, fromServer: true);

      // VERIFIKASI
      verifyNever(mockUploadStatusOperation.setNeedUpload(any,
          transaction: anyNamed('transaction')));
    });

    test('harus menjalankan aksi utama di dalam transaksi', () async {
      // ATUR
      bool actionCalled = false;

      // JALANKAN
      await baseOperation.runComplexOperation((txn) async {
        actionCalled = true;
      });

      // VERIFIKASI
      expect(actionCalled, isTrue);
    });
  });

  group('BaseOperation CRUD Methods', () {
    test('insert() harus memanggil txn.insert dengan benar', () async {
      // ATUR
      const table = 'test_table';
      final data = {'id': '1', 'name': 'test'};

      // JALANKAN
      await baseOperation.insert(table, data);

      // VERIFIKASI
      final verification = verify(mockDatabase.transaction(captureAny));
      verification.called(1);

      final action =
          verification.captured.single as Future<dynamic> Function(Transaction);
      final mockTxn = MockTransaction();
      await action(mockTxn);

      verify(mockTxn.insert(table, data,
              conflictAlgorithm: ConflictAlgorithm.replace))
          .called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: anyNamed('transaction')))
          .called(1);
    });

    test('update() harus memanggil txn.update dengan benar', () async {
      // ATUR
      const table = 'test_table';
      final data = {'name': 'updated'};
      const id = '1';

      // JALANKAN
      await baseOperation.update(table, data, id);

      // VERIFIKASI
      final verification = verify(mockDatabase.transaction(captureAny));
      verification.called(1);

      final action =
          verification.captured.single as Future<dynamic> Function(Transaction);
      final mockTxn = MockTransaction();
      await action(mockTxn);

      verify(mockTxn.update(table, data, where: 'id = ?', whereArgs: [id]))
          .called(1);
      verify(mockUploadStatusOperation.setNeedUpload(true,
              transaction: anyNamed('transaction')))
          .called(1);
    });

    test('delete() harus memanggil txn.delete dengan benar', () async {
      // ATUR
      const table = 'test_table';
      const id = '1';

      // JALANKAN
      await baseOperation.delete(table, id);

      // VERIFIKASI
      final verification = verify(mockDatabase.transaction(captureAny));
      verification.called(1);

      final action =
          verification.captured.single as Future<dynamic> Function(Transaction);
      final mockTxn = MockTransaction();
      await action(mockTxn);

      verify(mockTxn.delete(table, where: 'id = ?', whereArgs: [id])).called(1);
    });

    test('softDelete() harus memanggil txn.update dengan data yang benar',
        () async {
      // ATUR
      const table = 'test_table';
      const id = '1';

      // JALANKAN
      await baseOperation.softDelete(table, id);

      // VERIFIKASI
      final verification = verify(mockDatabase.transaction(captureAny));
      verification.called(1);

      final action =
          verification.captured.single as Future<dynamic> Function(Transaction);
      final mockTxn = MockTransaction();
      when(mockTxn.update(any, any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => 1);
      await action(mockTxn);

      final captured = verify(mockTxn.update(any, captureAny,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .captured;

      expect(captured.first.containsKey('isDeleted'), isTrue);
      expect(captured.first['isDeleted'], 1);
      expect(captured.first.containsKey('archivedAt'), isTrue);
    });

    test('insertOrUpdateBatch() harus memanggil batch.commit', () async {
      // ATUR
      const table = 'test_table';
      final dataList = [
        {'id': '1', 'name': 'test1'},
        {'id': '2', 'name': 'test2'}
      ];
      final mockBatch = MockBatch();

      // JALANKAN
      await baseOperation.insertOrUpdateBatch(table, dataList,
          fromServer: true);

      // VERIFIKASI
      final verification = verify(mockDatabase.transaction(captureAny));
      verification.called(1);

      final action =
          verification.captured.single as Future<dynamic> Function(Transaction);
      final mockTxn = MockTransaction();
      when(mockTxn.batch()).thenReturn(mockBatch);

      await action(mockTxn);

      verify(mockTxn.batch()).called(1);
      verify(mockBatch.insert(any, any,
              conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .called(2);
      verify(mockBatch.commit(noResult: true)).called(1);
      verifyNever(mockUploadStatusOperation.setNeedUpload(any,
          transaction: anyNamed('transaction')));
    });
  });
}

// path: test/shared/operasi/sqlite_operasi/base_op_sqlite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/status_upload_op_sqlite.dart';

// Mocks
class MockSqliteDatabase extends Mock implements SqliteDatabase {}

class MockDatabase extends Mock implements Database {}

class MockTransaction extends Mock implements Transaction {}

class MockBatch extends Mock implements Batch {}

class MockStatusUnggahOpSqlite extends Mock implements StatusUploadOpSqlite {}

void main() {
  late BaseOpSqlite baseOpSqlite;
  late MockSqliteDatabase mockSqliteDatabase;
  late MockDatabase mockDatabase;
  late MockStatusUnggahOpSqlite mockStatusUnggahOpSqlite;
  const String namaTabel = 'test_tabel';

  setUp(() {
    mockSqliteDatabase = MockSqliteDatabase();
    mockDatabase = MockDatabase();
    mockStatusUnggahOpSqlite = MockStatusUnggahOpSqlite();
    baseOpSqlite = BaseOpSqlite(
      sqliteDb: mockSqliteDatabase,
      statusUnggahOpSqlite: mockStatusUnggahOpSqlite,
    );

    // Stubbing default
    when(() => mockSqliteDatabase.database).thenAnswer((_) async => mockDatabase);
    when(() => mockStatusUnggahOpSqlite.tandaiButuhUpload(any(), transaction: any(named: 'transaction')))
        .thenAnswer((_) async {});
  });

  group('BaseOpSqlite', () {
    final data = {'id': '1', 'name': 'Test'};
    final exception = Exception('Database error');

    group('sisipkan', () {
      test(
        '01. harus memanggil db.insert dengan data dan conflictAlgorithm yang benar',
        () async {
          final mockTxn = MockTransaction();
          when(() => mockDatabase.transaction<int>(any()))
              .thenAnswer((invocation) async {
            final action = invocation.positionalArguments[0] as Future<int> Function(Transaction);
            return await action(mockTxn);
          });
          when(() => mockTxn.insert(any(), any(),
              conflictAlgorithm: any(named: 'conflictAlgorithm'))).thenAnswer((_) async => 1);

          await baseOpSqlite.sisipkan(namaTabel, data);

          verify(() => mockTxn.insert(
                namaTabel,
                data,
                conflictAlgorithm: ConflictAlgorithm.replace,
              )).called(1);
          verify(() => mockStatusUnggahOpSqlite.tandaiButuhUpload(true, transaction: mockTxn))
              .called(1);
        },
      );

      test('02. harus melempar kembali exception jika transaksi gagal', () {
        when(() => mockDatabase.transaction<int>(any())).thenThrow(exception);

        expect(baseOpSqlite.sisipkan(namaTabel, data),
            throwsA(isA<Exception>()));
      });
    });

    group('update', () {
      test(
        '03. harus memanggil db.update dengan data dan klausa where yang benar',
        () async {
          final mockTxn = MockTransaction();
          when(() => mockDatabase.transaction<int>(any()))
              .thenAnswer((invocation) async {
            final action = invocation.positionalArguments[0] as Future<int> Function(Transaction);
            return await action(mockTxn);
          });
          when(() => mockTxn.update(any(), any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

          await baseOpSqlite.update(namaTabel, data, '1');

          verify(() => mockTxn.update(
                namaTabel,
                data,
                where: 'id = ?',
                whereArgs: ['1'],
              )).called(1);
        },
      );

      test('04. harus melempar kembali exception jika transaksi gagal', () {
        when(() => mockDatabase.transaction<int>(any())).thenThrow(exception);

        expect(baseOpSqlite.update(namaTabel, data, '1'),
            throwsA(isA<Exception>()));
      });
    });

    group('delete', () {
      test('05. harus memanggil db.delete dengan klausa where yang benar',
          () async {
        final mockTxn = MockTransaction();
        when(() => mockDatabase.transaction<int>(any()))
            .thenAnswer((invocation) async {
          final action = invocation.positionalArguments[0] as Future<int> Function(Transaction);
          return await action(mockTxn);
        });
        when(() => mockTxn.delete(any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

        await baseOpSqlite.delete(namaTabel, '1');

        verify(() => mockTxn.delete(
              namaTabel,
              where: 'id = ?',
              whereArgs: ['1'],
            )).called(1);
      });

      test('06. harus melempar kembali exception jika transaksi gagal', () {
        when(() => mockDatabase.transaction<int>(any())).thenThrow(exception);

        expect(baseOpSqlite.delete(namaTabel, '1'),
            throwsA(isA<Exception>()));
      });
    });

    group('softDelete', () {
      test(
          '07. harus memanggil db.update untuk soft delete dengan data yang benar',
          () async {
        final mockTxn = MockTransaction();
        when(() => mockDatabase.transaction<int>(any()))
            .thenAnswer((invocation) async {
          final action = invocation.positionalArguments[0] as Future<int> Function(Transaction);
          return await action(mockTxn);
        });
        when(() => mockTxn.update(any(), any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

        await baseOpSqlite.softDelete(namaTabel, '1');

        verify(() => mockTxn.update(
              namaTabel,
              any(that: isA<Map<String, dynamic>>().having(
                  (map) => map[NamaKolom.dihapus], 'dihapus', 1)),
              where: '${NamaKolom.id} = ?',
              whereArgs: ['1'],
            )).called(1);
      });

      test(
          '08. harus melempar kembali exception jika transaksi gagal',
          () {
        when(() => mockDatabase.transaction<int>(any())).thenThrow(exception);

        expect(baseOpSqlite.softDelete(namaTabel, '1'),
            throwsA(isA<Exception>()));
      });
    });

    group('sisipkanAtauPerbaruiBatch', () {
      final dataList = [
        {'id': '1', 'name': 'Data 1'},
        {'id': '2', 'name': 'Data 2'},
      ];

      test('09. harus menjalankan operasi batch insert di dalam transaksi',
          () async {
        final mockTransaction = MockTransaction();
        final mockBatch = MockBatch();

        when(() => mockDatabase.transaction<void>(any()))
            .thenAnswer((invocation) async {
          final action =
              invocation.positionalArguments[0] as Future<void> Function(Transaction);
          await action(mockTransaction);
        });

        when(() => mockTransaction.batch()).thenReturn(mockBatch);
        when(() => mockBatch.insert(any(), any(),
            conflictAlgorithm: any(named: 'conflictAlgorithm'))).thenAnswer((_) {});
        when(() => mockBatch.commit(noResult: true)).thenAnswer((_) async => []);

        await baseOpSqlite.sisipkanAtauPerbaruiBatch(namaTabel, dataList);

        verify(() => mockDatabase.transaction<void>(any())).called(1);
        verify(() => mockTransaction.batch()).called(1);
        verify(() => mockBatch.insert(
              namaTabel,
              dataList[0],
              conflictAlgorithm: ConflictAlgorithm.replace,
            )).called(1);
        verify(() => mockBatch.commit(noResult: true)).called(1);
      });

      test('10. tidak melakukan apa-apa jika list data kosong', () async {
        await baseOpSqlite.sisipkanAtauPerbaruiBatch(namaTabel, []);
        verifyNever(() => mockDatabase.transaction(any()));
      });

      test('11. harus melempar kembali exception jika transaksi batch gagal',
          () {
        when(() => mockDatabase.transaction<void>(any())).thenThrow(exception);

        expect(baseOpSqlite.sisipkanAtauPerbaruiBatch(namaTabel, dataList),
            throwsA(isA<Exception>()));
      });
    });

    group('runComplexOperation', () {
      test(
          '12. harus menjalankan action yang diberikan di dalam transaksi dan mengembalikan hasilnya',
          () async {
        final mockTransaction = MockTransaction();
        const expectedResult = 42;

        when(() => mockDatabase.transaction<int>(any()))
            .thenAnswer((invocation) async {
          final action = invocation.positionalArguments[0] as Future<int> Function(Transaction);
          return await action(mockTransaction);
        });

        final result = await baseOpSqlite.runComplexOperation<int>((txn) async {
          expect(txn, same(mockTransaction));
          return Future.value(expectedResult);
        });

        expect(result, expectedResult);
        verify(() => mockDatabase.transaction<int>(any())).called(1);
      });

      test(
          '13. harus melempar kembali exception jika action di dalam transaksi gagal',
          () {
        when(() => mockDatabase.transaction<void>(any())).thenThrow(exception);
            
        expect(baseOpSqlite.runComplexOperation<void>((txn) async {}), throwsA(isA<Exception>()));
      });
    });
  });
}

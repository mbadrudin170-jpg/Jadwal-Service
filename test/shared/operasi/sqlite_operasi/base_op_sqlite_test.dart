// path: test/shared/operasi/sqlite_operasi/base_op_sqlite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/status_upload_op_sqlite.dart';

import 'base_op_sqlite_test.mocks.dart';

// Dummy model for testing
class DummyModel {
  final String id;
  final String name;
  final DateTime? diperbaruiPada;
  final bool? dihapus;

  DummyModel({
    required this.id,
    required this.name,
    this.diperbaruiPada,
    this.dihapus,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'diperbarui_pada': diperbaruiPada?.millisecondsSinceEpoch,
        'dihapus': dihapus == true ? 1 : 0,
      };
}

@GenerateMocks([SqliteDatabase, Database, Transaction, Batch, StatusUploadOpSqlite])
void main() {
  late BaseOpSqlite baseOpSqlite;
  late MockSqliteDatabase mockSqliteDb;
  late MockDatabase mockDb;
  late MockStatusUploadOpSqlite mockStatusUpload;

  setUp(() {
    mockSqliteDb = MockSqliteDatabase();
    mockDb = MockDatabase();
    mockStatusUpload = MockStatusUploadOpSqlite();
    
    baseOpSqlite = BaseOpSqlite(
      sqliteDb: mockSqliteDb,
      statusUnggahOpSqlite: mockStatusUpload,
    );

    when(mockSqliteDb.database).thenAnswer((_) async => mockDb);
  });

  const tableName = 'dummies';
  final model = DummyModel(id: '1', name: 'test');
  final modelMap = model.toMap();

  group('Operasi Dasar', () {
    test('01. sisipkan harus memanggil db.insert dengan benar', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);
      await baseOpSqlite.sisipkan(tableName, modelMap);
      verify(
        mockDb.insert(
          tableName,
          modelMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
    });

    test('02. update harus memanggil db.update dengan benar', () async {
      when(
        mockDb.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);

      final updatedModel = {'name': 'updated'};
      await baseOpSqlite.update(tableName, updatedModel, '1');

      verify(
        mockDb.update(
          tableName,
          updatedModel,
          where: 'id = ?',
          whereArgs: ['1'],
        ),
      ).called(1);
    });

    test('03. delete harus memanggil db.delete dengan benar', () async {
      when(
        mockDb.delete(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);

      await baseOpSqlite.delete(tableName, '1');

      verify(
        mockDb.delete(tableName, where: 'id = ?', whereArgs: ['1']),
      ).called(1);
    });
  });

  group('Operasi Soft Delete', () {
    test('04. softDelete harus memperbarui kolom dihapus dan diperbaruiPada', () async {
      when(
        mockDb.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);

      await baseOpSqlite.softDelete(tableName, '1');

      final captured = verify(
        mockDb.update(
          any,
          captureAny,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).captured;

      final data = captured.first as Map<String, dynamic>;
      expect(data[NamaKolom.dihapus], 1);
      expect(data[NamaKolom.diperbaruiPada], isA<int>());
    });

    test('05. softDeleteAll harus memperbarui semua record', () async {
      when(mockDb.update(any, any)).thenAnswer((_) async => 5);

      final count = await baseOpSqlite.softDeleteAll(tableName);

      expect(count, 5);
      final captured = verify(
        mockDb.update(tableName, captureAny),
      ).captured;

      final data = captured.first as Map<String, dynamic>;
      expect(data[NamaKolom.dihapus], 1);
      expect(data[NamaKolom.diperbaruiPada], isA<int>());
    });
  });

  group('Operasi Batch', () {
    final mockBatch = MockBatch();
    final listMap = [modelMap, modelMap];

    setUp(() {
      when(mockDb.batch()).thenReturn(mockBatch);
      when(mockBatch.commit(noResult: anyNamed('noResult'))).thenAnswer((_) async => []);
    });

    test('06. sisipkanBatch harus mengeksekusi batch insert', () async {
      // PERBAIKAN: Method sisipkanBatch tidak ada, gunakan sisipkanAtauPerbaruiBatch
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(tableName, listMap);
      verify(mockBatch.insert(tableName, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .called(listMap.length);
      verify(mockBatch.commit(noResult: true)).called(1);
    });

    test('07. sisipkanAtauPerbaruiBatch harus mengeksekusi batch insert replace', () async {
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(tableName, listMap);
      verify(mockBatch.insert(tableName, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .called(listMap.length);
      verify(mockBatch.commit(noResult: true)).called(1);
    });

    test('08. updateBatch harus mengeksekusi batch update', () async {
      // PERBAIKAN: Method updateBatch tidak ada, gunakan sisipkanAtauPerbaruiBatch
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(tableName, listMap);
      verify(mockBatch.insert(tableName, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .called(listMap.length);
      verify(mockBatch.commit(noResult: true)).called(1);
    });
  });

  group('Sinkronisasi dari Server', () {
    test('09. sisipkan harus menandai butuhUpload saat dariServer false', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);
      
      await baseOpSqlite.sisipkan(tableName, modelMap, dariServer: false);

      verify(mockStatusUpload.tandaiButuhUpload(true, transaction: null)).called(1);
    });

    test('10. sisipkan tidak boleh menandai butuhUpload saat dariServer true', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);
      
      await baseOpSqlite.sisipkan(tableName, modelMap, dariServer: true);

      verifyNever(mockStatusUpload.tandaiButuhUpload(true, transaction: null));
    });

    test('11. update harus menandai butuhUpload saat dariServer false', () async {
      when(
        mockDb.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);
      
      await baseOpSqlite.update(tableName, modelMap, '1', dariServer: false);

      verify(mockStatusUpload.tandaiButuhUpload(true, transaction: null)).called(1);
    });

    test('12. update tidak boleh menandai butuhUpload saat dariServer true', () async {
      when(
        mockDb.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);
      
      await baseOpSqlite.update(tableName, modelMap, '1', dariServer: true);

      verifyNever(mockStatusUpload.tandaiButuhUpload(true, transaction: null));
    });
  });

  group('runComplexOperation', () {
    test('13. harus menjalankan action di dalam db.transaction', () async {
      when(mockDb.transaction<String>(any)).thenAnswer((invocation) async {
        final action = invocation.positionalArguments.first as Future<String> Function(Transaction);
        final mockTxn = MockTransaction();
        when(mockTxn.rawQuery(any)).thenAnswer((_) async => []);
        return action(mockTxn);
      });

      Future<String> dummyAction(Transaction txn) async {
        await txn.rawQuery('SELECT * FROM test');
        return 'done';
      }

      final result = await baseOpSqlite.runComplexOperation(dummyAction);

      verify(mockDb.transaction<String>(any)).called(1);
      expect(result, 'done');
    });

    test('14. harus menandai butuhUpload jika dariServer false', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);

      await baseOpSqlite.runComplexOperation((txn) async {
        await txn.insert('test', {'id': '1'});
        return 'done';
      }, dariServer: false);

      verify(mockStatusUpload.tandaiButuhUpload(true, transaction: any)).called(1);
    });
  });
}
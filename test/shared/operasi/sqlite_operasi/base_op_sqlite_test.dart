// path: test/shared/operasi/sqlite_operasi/base_op_sqlite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

import 'base_op_sqlite_test.mocks.dart';

// Dummy model for testing
class DummyModel with HasId {
  @override
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

@GenerateMocks([SqliteDatabase, Database, Transaction, Batch])
void main() {
  late BaseOpSqlite baseOpSqlite;
  late MockSqliteDatabase mockSqliteDb;
  late MockDatabase mockDb;

  setUp(() {
    mockSqliteDb = MockSqliteDatabase();
    mockDb = MockDatabase();
    baseOpSqlite = BaseOpSqlite(mockSqliteDb);

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

    test('02. perbarui harus memanggil db.update dengan benar', () async {
      when(
        mockDb.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);

      final updatedModel = {'name': 'updated'};
      await baseOpSqlite.perbarui(tableName, '1', updatedModel);

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
      await baseOpSqlite.sisipkanBatch(tableName, listMap);
      verify(mockBatch.insert(tableName, any, conflictAlgorithm: ConflictAlgorithm.ignore))
          .called(listMap.length);
      verify(mockBatch.commit(noResult: true)).called(1);
    });

    test('07. sisipkanAtauPerbaruiBatch harus mengeksekusi batch insert replace', () async {
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(tableName, listMap);
      verify(mockBatch.insert(tableName, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .called(listMap.length);
      verify(mockBatch.commit(noResult: true)).called(1);
    });

    test('08. perbaruiBatch harus mengeksekusi batch update', () async {
      await baseOpSqlite.perbaruiBatch(tableName, listMap);
      verify(
        mockBatch.update(
          tableName,
          any,
          where: 'id = ?',
          whereArgs: anyNamed('whereArgs'),
        ),
      ).called(listMap.length);
      verify(mockBatch.commit(noResult: true)).called(1);
    });
  });

  group('Sinkronisasi dari Server', () {
    test('09. sisipkan harus menyertakan kolom dariServer saat benar', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);
      await baseOpSqlite.sisipkan(tableName, modelMap, dariServer: true);

      final captured = verify(mockDb.insert(any, captureAny, conflictAlgorithm: ConflictAlgorithm.replace))
          .captured
          .first;
      final data = captured as Map<String, dynamic>;

      expect(data['name'], model.name);
      expect(data[NamaKolom.dariServer], 1);
      expect(data[NamaKolom.diperbaruiPada], isNotNull);
    });

    test('10. sisipkan harus tidak menyertakan kolom dariServer saat salah', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);
      await baseOpSqlite.sisipkan(tableName, modelMap, dariServer: false);

      final captured = verify(mockDb.insert(any, captureAny, conflictAlgorithm: ConflictAlgorithm.replace))
          .captured
          .first;
      final data = captured as Map<String, dynamic>;

      expect(data['name'], model.name);
      expect(data[NamaKolom.dariServer], null); // atau tidak ada sama sekali
      expect(data[NamaKolom.diperbaruiPada], isNotNull);
    });

    test('11. perbarui harus menyertakan kolom dariServer saat benar', () async {
      when(
        mockDb.update(any, any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')),
      ).thenAnswer((_) async => 1);
      await baseOpSqlite.perbarui(tableName, '1', modelMap, dariServer: true);

      final captured = verify(mockDb.update(any, captureAny, where: anyNamed('where')))
          .captured
          .first;
      final data = captured as Map<String, dynamic>;

      expect(data[NamaKolom.dariServer], 1);
      expect(data[NamaKolom.diperbaruiPada], isNotNull);
    });

    test('12. perbaruiBatch harus menyertakan kolom dariServer saat benar', () async {
      final mockBatch = MockBatch();
      when(mockDb.batch()).thenReturn(mockBatch);
      when(mockBatch.commit(noResult: anyNamed('noResult'))).thenAnswer((_) async => []);

      await baseOpSqlite.perbaruiBatch(tableName, [modelMap], dariServer: true);

      final captured = verify(mockBatch.update(any, captureAny, where: anyNamed('where')))
          .captured
          .first;
      final data = captured as Map<String, dynamic>;

      expect(data[NamaKolom.dariServer], 1);
      expect(data[NamaKolom.diperbaruiPada], isNotNull);
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

    test('14. harus menyertakan diperbaruiPada dan dariServer saat dariServer true', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: ConflictAlgorithm.replace))
          .thenAnswer((_) async => 1);

      await baseOpSqlite.sisipkan(tableName, modelMap, dariServer: true);

      final captured = verify(mockDb.insert(tableName, captureAny, conflictAlgorithm: ConflictAlgorithm.replace))
          .captured
          .first;
      final data = captured as Map<String, dynamic>;

      expect(data[NamaKolom.diperbaruiPada], isNotNull);
      expect(data[NamaKolom.dariServer], 1);
    });
  });
}

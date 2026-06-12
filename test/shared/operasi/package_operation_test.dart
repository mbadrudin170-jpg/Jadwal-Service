// path: test/shared/operasi/package_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';

import 'package_operation_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late PaketOpSqlite packageOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    packageOperation = PaketOpSqlite(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('PackageOperation Tests', () {
    final tPackage = PaketModel(
      id: '1',
      name: 'Basic Plan',
      price: 150000,
      duration: 30,
      type: DurationType.days,
      updatedAt: DateTime.now(),
    );
    final tPackageMap = tPackage.toSqlite();
    final tableName = NamaTabel.get(TableName.package);

    test('1. getAll harus mengembalikan daftar paket dari database', () async {
      when(mockDatabase.rawQuery(any)).thenAnswer((_) async => [tPackageMap]);

      final result = await packageOperation.getAll();

      expect(result, isA<List<PaketModel>>());
      expect(result.length, 1);
      expect(result.first.id, tPackage.id);
      verify(mockDatabase.rawQuery(any)).called(1);
    });

    test('2. getById harus mengembalikan satu paket dari database', () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tPackageMap]);

      final result = await packageOperation.getById('1');

      expect(result, isA<PaketModel>());
      expect(result?.id, tPackage.id);
      verify(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: ['1'],
      )).called(1);
    });

    test('3. add harus memanggil insert pada baseOperation', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async => 1);

      await packageOperation.add(tPackage);

      verify(mockBaseOperation.sisipkan(tableName, any)).called(1);
    });

    test('4. update harus memanggil update pada baseOperation', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async => 1);

      await packageOperation.update(tPackage);

      verify(mockBaseOperation.update(tableName, any, tPackage.id)).called(1);
    });

    test('5. delete harus memanggil delete pada baseOperation', () async {
      when(mockBaseOperation.delete(any, any)).thenAnswer((_) async => 1);

      await packageOperation.delete('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('6. softDelete harus memanggil softDelete pada baseOperation',
        () async {
      when(mockBaseOperation.hapusSementara(any, any)).thenAnswer((_) async {});

      await packageOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(tableName, '1')).called(1);
    });

    test(
        '7. insertOrUpdateBatch harus memanggil insertOrUpdateBatch pada baseOperation',
        () async {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async {});

      await packageOperation.insertOrUpdateBatch([tPackage]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}

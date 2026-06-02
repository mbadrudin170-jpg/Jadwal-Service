// path: test/shared/operasi/package_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';

import 'package_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, BaseOperation, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late PackageOperation packageOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    packageOperation = PackageOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('PackageOperation Tests', () {
    final tPackage = PackageModel(
      id: '1',
      name: 'Basic Plan',
      price: 150000,
      duration: 30,
      type: DurationType.days,
      isPublic: true,
      updatedAt: DateTime.now(),
    );
    final tPackageMap = tPackage.toSqlite();
    final tableName = TableNameValue.get(TableName.package);

    test('getAll should return a list of packages from database', () async {
      when(mockDatabase.rawQuery(any)).thenAnswer((_) async => [tPackageMap]);

      final result = await packageOperation.getAll();

      expect(result, isA<List<PackageModel>>());
      expect(result.length, 1);
      expect(result.first.id, tPackage.id);
      verify(mockDatabase.rawQuery(any)).called(1);
    });

    test('getById should return a single package from database', () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tPackageMap]);

      final result = await packageOperation.getById('1');

      expect(result, isA<PackageModel>());
      expect(result?.id, tPackage.id);
      verify(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: ['1'],
      )).called(1);
    });

    test('add should call insert on baseOperation', () {
      when(mockBaseOperation.insert(any, any))
          .thenAnswer((_) async => Future.value());

      packageOperation.add(tPackage);

      verify(mockBaseOperation.insert(tableName, any)).called(1);
    });

    test('update should call update on baseOperation', () {
      when(mockBaseOperation.update(any, any, any))
          .thenAnswer((_) async => Future.value());

      packageOperation.update(tPackage);

      verify(mockBaseOperation.update(tableName, any, tPackage.id)).called(1);
    });

    test('delete should call delete on baseOperation', () {
      when(mockBaseOperation.delete(any, any))
          .thenAnswer((_) async => Future.value());

      packageOperation.delete('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('softDelete should call softDelete on baseOperation', () {
      when(mockBaseOperation.softDelete(any, any))
          .thenAnswer((_) async => Future.value());

      packageOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(tableName, '1')).called(1);
    });

    test('insertOrUpdateBatch should call insertOrUpdateBatch on baseOperation',
        () {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async => Future.value());

      packageOperation.insertOrUpdateBatch([tPackage]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}

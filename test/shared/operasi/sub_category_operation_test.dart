// path: test/shared/operasi/sub_category_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';

import 'sub_category_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, BaseOperation, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late SubCategoryOperation subCategoryOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    subCategoryOperation = SubCategoryOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('SubCategoryOperation Tests', () {
    final tSubCategory = SubCategoryModel(
      id: '1',
      categoryId: 'cat1',
      name: 'Salary',
      updatedAt: DateTime.now(),
    );
    final tSubCategoryMap = tSubCategory.toSqlite();
    final tableName = TableNameValue.get(TableName.subCategory);

    test(
        'getSubCategoryByCategoryId should return a list of sub-categories from database',
        () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tSubCategoryMap]);

      final result =
          await subCategoryOperation.getSubCategoryByCategoryId('cat1');

      expect(result, isA<List<SubCategoryModel>>());
      expect(result.length, 1);
      expect(result.first.id, tSubCategory.id);
      verify(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('getSubCategoryById should return a single sub-category from database',
        () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tSubCategoryMap]);

      final result = await subCategoryOperation.getSubCategoryById('1');

      expect(result, isA<SubCategoryModel>());
      expect(result?.id, tSubCategory.id);
      verify(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: ['1'],
      )).called(1);
    });

    test('createSubCategory should call insert on baseOperation', () {
      when(mockBaseOperation.insert(any, any)).thenReturn(Future.value());

      subCategoryOperation.createSubCategory(tSubCategory);

      verify(mockBaseOperation.insert(tableName, any)).called(1);
    });

    test('updateSubCategory should call update on baseOperation', () {
      when(mockBaseOperation.update(any, any, any)).thenReturn(Future.value());

      subCategoryOperation.updateSubCategory(tSubCategory);

      verify(mockBaseOperation.update(tableName, any, tSubCategory.id))
          .called(1);
    });

    test('delete should call delete on baseOperation', () {
      when(mockBaseOperation.delete(any, any)).thenReturn(Future.value());

      subCategoryOperation.delete('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('softDelete should call softDelete on baseOperation', () {
      when(mockBaseOperation.softDelete(any, any)).thenReturn(Future.value());

      subCategoryOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(tableName, '1')).called(1);
    });

    test('insertOrUpdateBatch should call insertOrUpdateBatch on baseOperation',
        () {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenReturn(Future.value());

      subCategoryOperation.insertOrUpdateBatch([tSubCategory]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}

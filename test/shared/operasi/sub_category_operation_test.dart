// path: test/shared/operasi/sub_category_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';

import 'sub_category_operation_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late SubKategoriOpSqlite subCategoryOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    subCategoryOperation = SubKategoriOpSqlite(
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
    final tableName = NamaTabel.get(TableName.subCategory);

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

    test('createSubCategory should call insert on baseOperation', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async => 1);

      await subCategoryOperation.createSubCategory(tSubCategory);

      verify(mockBaseOperation.sisipkan(tableName, any)).called(1);
    });

    test('updateSubCategory should call update on baseOperation', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async => 1);

      await subCategoryOperation.updateSubCategory(tSubCategory);

      verify(mockBaseOperation.update(tableName, any, tSubCategory.id))
          .called(1);
    });

    test('delete should call delete on baseOperation', () async {
      when(mockBaseOperation.delete(any, any)).thenAnswer((_) async => 1);

      await subCategoryOperation.delete('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('softDelete should call softDelete on baseOperation', () async {
      when(mockBaseOperation.hapusSementara(any, any)).thenAnswer((_) async {});

      await subCategoryOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(tableName, '1')).called(1);
    });

    test('insertOrUpdateBatch should call insertOrUpdateBatch on baseOperation',
        () async {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async {});

      await subCategoryOperation.insertOrUpdateBatch([tSubCategory]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}

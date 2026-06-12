// path: test/shared/operasi/category_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';

import 'category_operation_test.mocks.dart';

@GenerateMocks([
  SqliteDatabase,
  Database,
  BaseOperation,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockBaseOperation mockBaseOperation;
  late CategoryOperation categoryOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockBaseOperation = MockBaseOperation();
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    categoryOperation = CategoryOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
  });

  group('CategoryOperation', () {
    final tCategory = CategoryModel(
      id: '1',
      name: 'Test Category',
      type: CategoryType.expense,
    );
    final tCategoryMap = tCategory.toSqlite();

    test('createCategory should insert a new category and return it', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async => 1);

      final result = await categoryOperation.createCategory(tCategory);

      expect(result.id, tCategory.id);
      verify(mockBaseOperation.sisipkan(any, any)).called(1);
    });

    test('getCategories should return a list of categories', () async {
      when(mockDatabase.query(any, where: anyNamed('where')))
          .thenAnswer((_) async => [tCategoryMap]);

      final result = await categoryOperation.getCategories();

      expect(result, isA<List<CategoryModel>>());
      expect(result.first.id, tCategory.id);
    });

    test('getCategoryById should return a category', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tCategoryMap]);

      final result = await categoryOperation.getCategoryById('1');

      expect(result, isA<CategoryModel>());
      expect(result.id, tCategory.id);
    });

    test('updateCategory should update an existing category', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await categoryOperation.updateCategory(tCategory);

      verify(mockBaseOperation.update(any, any, any)).called(1);
    });

    test('deleteCategory should delete a category', () async {
      when(mockBaseOperation.delete(any, any)).thenAnswer((_) async {});

      await categoryOperation.deleteCategory('1');

      verify(mockBaseOperation.delete(any, '1')).called(1);
    });

    test('softDelete should soft delete a category', () async {
      when(mockBaseOperation.hapusSementara(any, any)).thenAnswer((_) async {});

      await categoryOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(any, '1')).called(1);
    });
  });
}

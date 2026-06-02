// path: test/shared/operasi/category_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<CategoryModel> baseOperation;
  late CategoryOperation categoryOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<CategoryModel>(mockDatabase, 'categories');
    categoryOperation = CategoryOperation(baseOperation);
  });

  group('CategoryOperation Tests', () {
    final tCategory = CategoryModel(
      id: '1',
      name: 'Income',
    );

    test('getCategories should return a list of categories', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tCategory.toMap()]);

      final result = await categoryOperation.getCategories();

      expect(result, isA<List<CategoryModel>>());
      expect(result.length, 1);
      expect(result.first.id, tCategory.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getCategoryById should return a single category', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tCategory.toMap());

      final result = await categoryOperation.getCategoryById('1');

      expect(result, isA<CategoryModel>());
      expect(result?.id, tCategory.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertCategory should insert a new category', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await categoryOperation.insertCategory(tCategory);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateCategory should update an existing category', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await categoryOperation.updateCategory(tCategory.id, tCategory);

      expect(result, 1);
      verify(baseOperation.update(tCategory.id, any)).called(1);
    });

    test('deleteCategory should delete a category', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await categoryOperation.deleteCategory('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}

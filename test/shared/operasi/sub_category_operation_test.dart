// path: test/shared/operasi/sub_category_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<SubCategoryModel> baseOperation;
  late SubCategoryOperation subCategoryOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<SubCategoryModel>(mockDatabase, 'sub_categories');
    subCategoryOperation = SubCategoryOperation(baseOperation);
  });

  group('SubCategoryOperation Tests', () {
    final tSubCategory = SubCategoryModel(
      id: '1',
      categoryId: 'cat1',
      name: 'Salary',
    );

    test('getSubCategories should return a list of sub-categories', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tSubCategory.toMap()]);

      final result = await subCategoryOperation.getSubCategories();

      expect(result, isA<List<SubCategoryModel>>());
      expect(result.length, 1);
      expect(result.first.id, tSubCategory.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getSubCategoryById should return a single sub-category', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tSubCategory.toMap());

      final result = await subCategoryOperation.getSubCategoryById('1');

      expect(result, isA<SubCategoryModel>());
      expect(result?.id, tSubCategory.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertSubCategory should insert a new sub-category', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await subCategoryOperation.insertSubCategory(tSubCategory);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateSubCategory should update an existing sub-category', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await subCategoryOperation.updateSubCategory(tSubCategory.id, tSubCategory);

      expect(result, 1);
      verify(baseOperation.update(tSubCategory.id, any)).called(1);
    });

    test('deleteSubCategory should delete a sub-category', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await subCategoryOperation.deleteSubCategory('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}

// path: test/admin/halaman/form/category_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_kategori.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';

class MockCategoryOperation extends Mock implements CategoryOperation {}

void main() {
  late MockCategoryOperation mockCategoryOperation;
  late KategoriModel testCategory;

  setUp(() {
    mockCategoryOperation = MockCategoryOperation();
    testCategory = KategoriModel(
      id: '1',
      name: 'Test Category',
      type: CategoryType.income,
      subCategories: [],
    );
  });

  Widget createTestWidget({KategoriModel? kategori}) {
    return ProviderScope(
      overrides: [
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
      ],
      child: MaterialApp(
        home: CategoryForm(kategori: kategori),
      ),
    );
  }

  testWidgets('01. CategoryForm should display add form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Tambah Kategori Baru'), findsOneWidget);
  });

  testWidgets('02. CategoryForm should display edit form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget(kategori: testCategory));
    expect(find.text('Edit Kategori'), findsOneWidget);
    expect(find.text('Test Category'), findsOneWidget);
  });
}

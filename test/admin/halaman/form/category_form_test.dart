
// path: test/admin/halaman/form/category_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/category_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockCategoryOperation extends Mock implements CategoryOperation {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockCategoryOperation mockCategoryOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final category = CategoryModel(
    id: '1',
    name: 'Pemasukan',
    type: CategoryType.income,
    subCategories: [],
  );

  setUp(() {
    mockCategoryOperation = MockCategoryOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {CategoryModel? kategori}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: CategoryForm(kategori: kategori),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form kategori (mode edit)', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, kategori: category));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Kategori'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Pemasukan'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form kategori', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
  });
}

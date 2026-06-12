
// path: test/admin/halaman/form/package_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/paket_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';

class MockPackageOperation extends Mock implements PackageOperation {}

void main() {
  late MockPackageOperation mockPackageOperation;

  final package = PackageModel(
    id: '1',
    name: 'Paket 1',
    price: 10000,
    duration: 1,
    type: DurationType.days,
    rewardPoints: 10,
    redemptionPoints: 100,
    isPublic: true,
  );

  setUp(() {
    mockPackageOperation = MockPackageOperation();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        packageOperationProvider.overrideWithValue(mockPackageOperation),
        packageListProvider.overrideWith((ref) => Stream.value([package])),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {PackageModel? package}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: PackageForm(package: package),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form paket (mode edit)', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, package: package));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Paket'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Paket 1'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form paket', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Nama paket tidak boleh kosong'), findsOneWidget);
    expect(find.text('Harga tidak boleh kosong'), findsOneWidget);
    expect(find.text('Durasi tidak boleh kosong'), findsOneWidget);
  });
}

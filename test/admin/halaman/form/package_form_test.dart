// path: test/admin/halaman/form/package_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';

class MockPackageOperation extends Mock implements PaketOpSqlite {}

void main() {
  late MockPackageOperation mockPackageOperation;
  late PaketModel testPackage;

  setUp(() {
    mockPackageOperation = MockPackageOperation();
    testPackage = PaketModel(
      id: '1',
      name: 'Test Package',
      price: 10000,
      duration: 30,
      type: DurationType.days,
    );
  });

  Widget createTestWidget({PaketModel? package}) {
    return ProviderScope(
      overrides: [
        packageOperationProvider.overrideWithValue(mockPackageOperation),
      ],
      child: MaterialApp(
        home: FormPaket(paket: package),
      ),
    );
  }

  testWidgets('01. PackageForm should display add form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Tambah Paket'), findsOneWidget);
  });

  testWidgets('02. PackageForm should display edit form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget(package: testPackage));
    expect(find.text('Edit Paket'), findsOneWidget);
    expect(find.text('Test Package'), findsOneWidget);
    expect(find.text('10000'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });
}

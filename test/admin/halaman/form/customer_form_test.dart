// path: test/admin/halaman/form/customer_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';

class MockCustomerOperation extends Mock implements PelangganOpSqlite {}

void main() {
  late MockCustomerOperation mockCustomerOperation;
  late CustomerModel testCustomer;

  setUp(() {
    mockCustomerOperation = MockCustomerOperation();
    testCustomer = CustomerModel(
      id: '1',
      name: 'Test Customer',
      phone: '1234567890',
      address: 'Test Address',
      password: 'password',
    );
  });

  Widget createTestWidget({CustomerModel? customer}) {
    return ProviderScope(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
      ],
      child: MaterialApp(
        home: CustomerForm(customer: customer),
      ),
    );
  }

  testWidgets('01. CustomerForm should display add form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Tambah Pelanggan'), findsOneWidget);
  });

  testWidgets('02. CustomerForm should display edit form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget(customer: testCustomer));
    expect(find.text('Edit Pelanggan'), findsOneWidget);
    expect(find.text('Test Customer'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Test Address'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);
  });
}

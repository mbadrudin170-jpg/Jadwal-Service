
// path: test/admin/halaman/form/customer_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/customer_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockCustomerOperation extends Mock implements CustomerOperation {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockCustomerOperation mockCustomerOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final customer = CustomerModel(
    id: '1',
    name: 'John Doe',
    phone: '08123456789',
    address: '123 Main St',
    password: 'password',
    macAddress: '00:11:22:33:44:55',
  );

  setUp(() {
    mockCustomerOperation = MockCustomerOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
        customerDetailProvider(customer.id).overrideWith((ref) => Stream.value(customer)),
        customerListProvider.overrideWith((ref) => Stream.value([customer])),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {CustomerModel? customer}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: CustomerForm(customer: customer),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form pelanggan (mode edit)', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, customer: customer));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Pelanggan'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'John Doe'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '08123456789'), findsOneWidget);
    expect(find.text('SIMPAN'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form pelanggan', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle();

    await tester.tap(find.text('SIMPAN'));
    await tester.pump();

    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    expect(find.text('Telepon tidak boleh kosong'), findsOneWidget);
    expect(find.text('Alamat tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    expect(find.text('MAC Address tidak boleh kosong'), findsOneWidget);
  });
}

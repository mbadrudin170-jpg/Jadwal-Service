// path: test/admin/halaman/detail/customer_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class MockCustomerModel extends Mock implements CustomerModel {}

void main() {
  late MockCustomerModel mockCustomer;

  setUp(() {
    mockCustomer = MockCustomerModel();
    when(() => mockCustomer.id).thenReturn('cust-123');
    when(() => mockCustomer.name).thenReturn('Budi Santoso');
    when(() => mockCustomer.phone).thenReturn('08123456789');
    when(() => mockCustomer.address).thenReturn('Jl. Merdeka No. 1');
    when(() => mockCustomer.password).thenReturn('password');
    when(() => mockCustomer.macAddress).thenReturn('00:11:22:33:44:55');
  });

  Widget createTestWidget(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: CustomerDetailPage(customerId: 'cust-123'),
      ),
    );
  }

  testWidgets('01. Menampilkan indikator pemuatan saat status loading',
      (tester) async {
    final overrides = [
      customerDetailProvider('cust-123')
          .overrideWith((ref) => const AsyncValue.loading()),
    ];

    await tester.pumpWidget(createTestWidget(overrides));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('02. Menampilkan pesan kesalahan saat status error',
      (tester) async {
    final overrides = [
      customerDetailProvider('cust-123').overrideWith(
          (ref) => AsyncValue.error('Gagal memuat data', StackTrace.current)),
    ];

    await tester.pumpWidget(createTestWidget(overrides));
    await tester.pump();

    expect(find.text('Error: Gagal memuat data'), findsOneWidget);
  });

  testWidgets('03. Menampilkan UI detail pelanggan saat data berhasil dimuat',
      (tester) async {
    final overrides = [
      customerDetailProvider('cust-123').overrideWith((ref) =>
          Future.value((customer: mockCustomer, totalPoints: 100))),
    ];

    await tester.pumpWidget(createTestWidget(overrides));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerDetailUI), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('100 Poin'), findsOneWidget);
  });

  testWidgets('04. Menampilkan pesan pelanggan tidak ditemukan jika data null',
      (tester) async {
    final overrides = [
      customerDetailProvider('cust-123')
          .overrideWith((ref) => Future.value((customer: null, totalPoints: 0))),
    ];

    await tester.pumpWidget(createTestWidget(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Pelanggan tidak ditemukan'), findsOneWidget);
  });
}

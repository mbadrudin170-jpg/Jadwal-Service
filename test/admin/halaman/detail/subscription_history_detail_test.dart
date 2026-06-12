// path: test/admin/halaman/detail/subscription_history_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_riwayat_aktivasi.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';

import 'active_customer_detail_test.mocks.dart';

void main() {
  late MockCustomerOperation mockCustomerOperation;
  late MockPackageOperation mockPackageOperation;
  late MockTransactionOperation mockTransactionOperation;

  final tCustomer = CustomerModel(
    id: 'cust1',
    name: 'Test Customer',
    phone: '123456789',
    address: 'Test Address',
    password: 'password',
  );

  final tPackage = PackageModel(
    id: 'pkg1',
    name: 'Test Package',
    price: 100000,
    duration: 30,
    type: DurationType.days,
  );

  final tTransaction = TransactionModel(
    id: 'trans1',
    customerId: 'cust1',
    packageId: 'pkg1',
    date: DateTime.now(),
    amount: 100000,
    type: TransactionType.income,
    paymentStatus: PaymentStatus.paid,
    description: 'Test Description',
    walletId: 'wallet1',
    categoryId: 'cat1',
  );

  setUp(() {
    mockCustomerOperation = MockCustomerOperation();
    mockPackageOperation = MockPackageOperation();
    mockTransactionOperation = MockTransactionOperation();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
        packageOperationProvider.overrideWithValue(mockPackageOperation),
        transactionOperationProvider.overrideWithValue(mockTransactionOperation),
      ],
      child: MaterialApp(
        home: DetailLangganan(idTransaksi: tTransaction.id),
      ),
    );
  }

  group('DetailLangganan Widget Test', () {
    testWidgets('01. should show loading indicator when fetching data',
        (tester) async {
      when(() => mockTransactionOperation.getTransactionById(any()))
          .thenAnswer((_) async => tTransaction);
      when(() => mockCustomerOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. should show data when fetch is successful', (tester) async {
      when(() => mockTransactionOperation.getTransactionById(any()))
          .thenAnswer((_) async => tTransaction);
      when(() => mockCustomerOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tCustomer);
      when(() => mockPackageOperation.ambilBerdasarkanId(any()))
          .thenAnswer((_) async => tPackage);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test Customer'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
    });

    testWidgets('03. should show error message when transaction is not found',
        (tester) async {
      when(() => mockTransactionOperation.getTransactionById(any()))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Transaksi tidak ditemukan'), findsOneWidget);
    });
  });
}

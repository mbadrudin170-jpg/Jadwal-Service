// path: test/admin/halaman/detail/transaction_detail_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/transaction_detail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/model.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/category_type_enum.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';

import 'active_customer_detail_test.mocks.dart';

void main() {
  late MockCustomerOperation mockCustomerOperation;
  late MockPackageOperation mockPackageOperation;
  late MockTransactionOperation mockTransactionOperation;
  late MockWalletOperation mockWalletOperation;
  late MockCategoryOperation mockCategoryOperation;
  late MockSubCategoryOperation mockSubCategoryOperation;

  final tTransaction = TransactionModel(
    id: '1',
    date: DateTime.now(),
    description: 'Test Transaction',
    amount: 100.0,
    type: TransactionType.income,
    walletId: 'wallet1',
    categoryId: 'cat1',
    paymentStatus: PaymentStatus.paid,
    customerId: 'cust1',
    packageId: 'pkg1',
  );

  setUp(() {
    mockCustomerOperation = MockCustomerOperation();
    mockPackageOperation = MockPackageOperation();
    mockTransactionOperation = MockTransactionOperation();
    mockWalletOperation = MockWalletOperation();
    mockCategoryOperation = MockCategoryOperation();
    mockSubCategoryOperation = MockSubCategoryOperation();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        customerOperationProvider.overrideWithValue(mockCustomerOperation),
        packageOperationProvider.overrideWithValue(mockPackageOperation),
        transactionOperationProvider.overrideWithValue(mockTransactionOperation),
        walletOperationProvider.overrideWithValue(mockWalletOperation),
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
        subCategoryOperationProvider.overrideWithValue(mockSubCategoryOperation),
      ],
      child: MaterialApp(
        home: TransactionDetailPage(transaction: tTransaction),
      ),
    );
  }

  group('TransactionDetailPage', () {
    testWidgets('01. should display transaction details', (tester) async {
      when(() => mockWalletOperation.getById(any()))
          .thenAnswer((_) async => WalletModel(id: 'wallet1', name: 'Test Wallet'));
      when(() => mockCategoryOperation.getCategoryById(any())).thenAnswer((_) async =>
          CategoryModel(id: 'cat1', name: 'Test Category', type: CategoryType.income));
      when(() => mockCustomerOperation.ambilBerdasarkanId(any())).thenAnswer(
          (_) async => CustomerModel(id: 'cust1', name: 'Test Customer', phone: '', password: '', address: ''));
      when(() => mockPackageOperation.ambilBerdasarkanId(any())).thenAnswer((_) async =>
          PackageModel(id: 'pkg1', name: 'Test Package', price: 100, duration: 30, type: DurationType.days));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pumpAndSettle();

      expect(find.text('Test Transaction'), findsOneWidget);
      expect(find.text('Test Wallet'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('Test Customer'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
    });
  });
}

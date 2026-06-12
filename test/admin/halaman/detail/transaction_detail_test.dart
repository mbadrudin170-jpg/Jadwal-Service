// path: test/admin/halaman/detail/transaction_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/transaction_detail.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/enum/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';

// Mocks
class MockTransactionOperation extends Mock implements TransactionOperation {}
class MockCategoryOperation extends Mock implements CategoryOperation {}
class MockSubCategoryOperation extends Mock implements SubCategoryOperation {}
class MockCustomerOperation extends Mock implements CustomerOperation {}
class MockPackageOperation extends Mock implements PackageOperation {}
class MockWalletOperation extends Mock implements DompetOpSqlite {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockTransactionOperation mockTransactionOp;
  late MockCategoryOperation mockCategoryOp;
  late MockSubCategoryOperation mockSubCategoryOp;
  late MockCustomerOperation mockCustomerOp;
  late MockPackageOperation mockPackageOp;
  late MockWalletOperation mockWalletOp;
  late MockNavigatorObserver mockNavigatorObserver;

  final tTransaction = TransactionModel(
    id: 't1',
    amount: 50000,
    type: TransactionType.income,
    categoryId: 'c1',
    subCategoryId: 'sc1',
    walletId: 'w1',
    customerId: 'cust1',
    packageId: 'p1',
    description: 'Bayar Wifi',
    date: DateTime(2023, 10, 10),
    paymentStatus: PaymentStatus.paid,
  );

  final tWallet = WalletModel(id: 'w1', name: 'Kas Utama', balance: 1000000);
  final tCategory = CategoryModel(id: 'c1', name: 'Internet', type: CategoryType.income);
  final tSubCategory = SubCategoryModel(id: 'sc1', categoryId: 'c1', name: 'Bulanan');
  final tCustomer = CustomerModel(id: 'cust1', name: 'Budi', address: '', password: '', phone: '');
  final tPackage = PackageModel(id: 'p1', name: 'Paket 1 Bln', price: 50000, duration: 30, type: DurationType.day, redemptionPoints: 10, rewardPoints: 10, isPublic: true);

  setUp(() {
    mockTransactionOp = MockTransactionOperation();
    mockCategoryOp = MockCategoryOperation();
    mockSubCategoryOp = MockSubCategoryOperation();
    mockCustomerOp = MockCustomerOperation();
    mockPackageOp = MockPackageOperation();
    mockWalletOp = MockWalletOperation();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createTestWidget(TransactionModel transaction) {
    return ProviderScope(
      overrides: [
        transactionOperationProvider.overrideWithValue(mockTransactionOp),
        categoryOperationProvider.overrideWithValue(mockCategoryOp),
        subCategoryOperationProvider.overrideWithValue(mockSubCategoryOp),
        customerOperationProvider.overrideWithValue(mockCustomerOp),
        packageOperationProvider.overrideWithValue(mockPackageOp),
        walletOperationProvider.overrideWithValue(mockWalletOp),
      ],
      child: MaterialApp(
        home: TransactionDetailPage(transaction: transaction),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Pengujian Halaman Detail Transaksi', () {
    testWidgets('1. Menampilkan semua informasi detail transaksi dengan benar', (tester) async {
      when(() => mockWalletOp.getById(any())).thenAnswer((_) async => tWallet);
      when(() => mockCategoryOp.getCategoryById(any())).thenAnswer((_) async => tCategory);
      when(() => mockSubCategoryOp.getSubCategoryById(any())).thenAnswer((_) async => tSubCategory);
      when(() => mockCustomerOp.getById(any())).thenAnswer((_) async => tCustomer);
      when(() => mockPackageOp.getById(any())).thenAnswer((_) async => tPackage);

      await tester.pumpWidget(createTestWidget(tTransaction));
      await tester.pumpAndSettle();

      expect(find.text('Bayar Wifi'), findsOneWidget);
      expect(find.text('Internet'), findsOneWidget);
      expect(find.text('Bulanan'), findsOneWidget);
      expect(find.text('Kas Utama'), findsOneWidget);
      expect(find.text('Budi'), findsOneWidget);
      expect(find.text('Paket 1 Bln'), findsOneWidget);
      expect(find.text('Rp50.000'), findsOneWidget);
    });

    testWidgets('2. Menangani kondisi ketika data relasi tidak ditemukan', (tester) async {
      when(() => mockWalletOp.getById(any())).thenAnswer((_) async => null);
      when(() => mockCategoryOp.getCategoryById(any())).thenAnswer((_) async => null);
      when(() => mockSubCategoryOp.getSubCategoryById(any())).thenAnswer((_) async => null);
      when(() => mockCustomerOp.getById(any())).thenAnswer((_) async => null);
      when(() => mockPackageOp.getById(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget(tTransaction));
      await tester.pumpAndSettle();

      expect(find.text('Data tidak ditemukan'), findsAtLeastNWidgets(1));
    });

    testWidgets('3. Navigasi ke form edit saat tombol edit ditekan', (tester) async {
      when(() => mockWalletOp.getById(any())).thenAnswer((_) async => tWallet);
      when(() => mockCategoryOp.getCategoryById(any())).thenAnswer((_) async => tCategory);
      when(() => mockSubCategoryOp.getSubCategoryById(any())).thenAnswer((_) async => tSubCategory);
      when(() => mockCustomerOp.getById(any())).thenAnswer((_) async => tCustomer);
      when(() => mockPackageOp.getById(any())).thenAnswer((_) async => tPackage);

      await tester.pumpWidget(createTestWidget(tTransaction));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(FormTransaksiPage), findsOneWidget);
    });
  });
}

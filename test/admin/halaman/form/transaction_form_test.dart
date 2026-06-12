// path: test/admin/halaman/form/transaction_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_transaksi.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockCategoryOperation extends Mock implements CategoryOperation {}

class MockTransactionOperation extends Mock implements TransactionOperation {}

void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockCategoryOperation mockCategoryOperation;
  late MockTransactionOperation mockTransactionOperation;
  late TransactionModel testTransaction;

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockCategoryOperation = MockCategoryOperation();
    mockTransactionOperation = MockTransactionOperation();
    testTransaction = TransactionModel(
      id: '1',
      description: 'Test Transaction',
      amount: 1000,
      date: DateTime.now(),
      type: TransactionType.income,
      walletId: '1',
      categoryId: '1',
    );
  });

  Widget createTestWidget({TransactionModel? transaction}) {
    return ProviderScope(
      overrides: [
        walletOperationProvider.overrideWithValue(mockDompetOpSqlite),
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
        transactionOperationProvider
            .overrideWithValue(mockTransactionOperation),
      ],
      child: MaterialApp(
        home: FormTransaksi(transaksi: transaction),
      ),
    );
  }

  testWidgets('01. FormTransaksiPage should display add form correctly',
      (tester) async {
    when(() => mockDompetOpSqlite.getWallets()).thenAnswer((_) async => []);
    when(() => mockCategoryOperation.getCategories())
        .thenAnswer((_) async => []);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Tambah Transaksi'), findsOneWidget);
  });

  testWidgets('02. FormTransaksiPage should display edit form correctly',
      (tester) async {
    when(() => mockDompetOpSqlite.getWallets()).thenAnswer((_) async => [
          WalletModel(id: '1', name: 'Test Wallet', balance: 0),
        ]);
    when(() => mockCategoryOperation.getCategories()).thenAnswer((_) async => [
          CategoryModel(
              id: '1', name: 'Test Category', type: CategoryType.income),
        ]);
    await tester.pumpWidget(createTestWidget(transaction: testTransaction));
    await tester.pumpAndSettle();
    expect(find.text('Edit Transaksi'), findsOneWidget);
    expect(find.text('Test Transaction'), findsOneWidget);
    expect(find.text('1000.0'), findsOneWidget);
  });
}

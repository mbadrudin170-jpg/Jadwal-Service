
// path: test/admin/halaman/form/transaction_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/transaction_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockWalletOperation extends Mock implements DompetOpSqlite {}
class MockCategoryOperation extends Mock implements CategoryOperation {}
class MockTransactionOperation extends Mock implements TransactionOperation {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockWalletOperation mockWalletOperation;
  late MockCategoryOperation mockCategoryOperation;
  late MockTransactionOperation mockTransactionOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final transaction = TransactionModel(
    id: '1',
    date: DateTime.now(),
    description: 'Test Transaction',
    amount: 10000,
    type: TransactionType.income,
    walletId: 'wallet1',
    categoryId: 'category1',
  );

  final wallet = WalletModel(id: 'wallet1', name: 'Dompet 1', balance: 100000, color: '#FFFFFF');
  final category = CategoryModel(id: 'category1', name: 'Pemasukan', type: CategoryType.income, subCategories: []);

  setUp(() {
    mockWalletOperation = MockWalletOperation();
    mockCategoryOperation = MockCategoryOperation();
    mockTransactionOperation = MockTransactionOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        walletOperationProvider.overrideWithValue(mockWalletOperation),
        categoryOperationProvider.overrideWithValue(mockCategoryOperation),
        transactionOperationProvider.overrideWithValue(mockTransactionOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {TransactionModel? transaction}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: FormTransaksiPage(transaction: transaction),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form transaksi (mode edit)', (tester) async {
    when(() => mockWalletOperation.getWallets()).thenAnswer((_) async => [wallet]);
    when(() => mockCategoryOperation.getCategories()).thenAnswer((_) async => [category]);

    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, transaction: transaction));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Transaksi'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Test Transaction'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form transaksi', (tester) async {
    when(() => mockWalletOperation.getWallets()).thenAnswer((_) async => []);
    when(() => mockCategoryOperation.getCategories()).thenAnswer((_) async => []);

    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Keterangan tidak boleh kosong'), findsOneWidget);
    expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);
  });
}

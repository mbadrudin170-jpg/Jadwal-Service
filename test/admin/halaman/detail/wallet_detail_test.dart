// path: test/admin/halaman/detail/wallet_detail_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_dompet.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockTransactionOperation extends Mock implements TransactionOperation {}

void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockTransactionOperation mockTransactionOperation;
  late WalletModel testWallet;

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockTransactionOperation = MockTransactionOperation();
    testWallet = WalletModel(
      id: '1',
      name: 'Test Wallet',
      balance: 1000,
    );
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        walletOperationProvider.overrideWithValue(mockDompetOpSqlite),
        transactionOperationProvider
            .overrideWithValue(mockTransactionOperation),
      ],
      child: MaterialApp(
        home: DetailDompet(
          dompet: testWallet,
        ),
      ),
    );
  }

  testWidgets('01. WalletDetail displays wallet name and balance',
      (tester) async {
    when(() => mockDompetOpSqlite.getById(any()))
        .thenAnswer((_) async => testWallet);
    when(() => mockTransactionOperation.getTransactionsByWalletId(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Test Wallet'), findsOneWidget);
    expect(find.textContaining('1000'), findsWidgets);
  });
}

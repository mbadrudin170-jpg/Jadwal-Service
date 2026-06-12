// path: test/admin/halaman/form/wallet_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/model/wallet_model.dart';

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late WalletModel testWallet;

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    testWallet = WalletModel(
      id: '1',
      name: 'Test Wallet',
      balance: 100000,
    );
  });

  Widget createTestWidget({WalletModel? wallet}) {
    return ProviderScope(
      overrides: [
        walletOperationProvider.overrideWithValue(mockDompetOpSqlite),
      ],
      child: MaterialApp(
        home: WalletForm(wallet: wallet),
      ),
    );
  }

  testWidgets('01. WalletForm should display add form correctly', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Tambah Dompet Baru'), findsOneWidget);
  });

  testWidgets('02. WalletForm should display edit form correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(wallet: testWallet));
    expect(find.text('Edit Nama Dompet'), findsOneWidget);
    expect(find.text('Test Wallet'), findsOneWidget);
  });
}

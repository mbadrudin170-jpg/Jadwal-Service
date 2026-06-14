// path: test/admin/halaman/form/wallet_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_dompet.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late DompetModel testWallet;

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    testWallet = DompetModel(
      id: '1',
      nama: 'Test Wallet',
      saldo: 100000,
    );
  });

  Widget createTestWidget({DompetModel? wallet}) {
    return ProviderScope(
      overrides: [
        walletOperationProvider.overrideWithValue(mockDompetOpSqlite),
      ],
      child: MaterialApp(
        home: FormDompet(dompet: wallet),
      ),
    );
  }

  testWidgets('01. WalletForm should display add form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Tambah Dompet Baru'), findsOneWidget);
  });

  testWidgets('02. WalletForm should display edit form correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget(wallet: testWallet));
    expect(find.text('Edit Nama Dompet'), findsOneWidget);
    expect(find.text('Test Wallet'), findsOneWidget);
  });
}


// path: test/admin/halaman/form/wallet_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/wallet_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockWalletOperation extends Mock implements DompetOpSqlite {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockWalletOperation mockWalletOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final wallet = WalletModel(
    id: '1',
    name: 'Dompet 1',
    balance: 100000,
    color: '#FFFFFF',
  );

  setUp(() {
    mockWalletOperation = MockWalletOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        walletOperationProvider.overrideWithValue(mockWalletOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {WalletModel? wallet}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: WalletForm(wallet: wallet),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form dompet (mode edit)', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, wallet: wallet));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Nama Dompet'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Dompet 1'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form dompet', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Nama dompet tidak boleh kosong'), findsOneWidget);
  });
}

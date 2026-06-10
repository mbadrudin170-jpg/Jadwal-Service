// path: test/admin/providers/wallet_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/wallet_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/wallet_operation.dart';

import 'wallet_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WalletOperation>()])
void main() {
  late MockWalletOperation mockWalletOperation;
  late ProviderContainer container;

  final tWallet1 = WalletModel(
    id: '1',
    name: 'Dompet Utama',
    balance: 100000,
    updatedAt: DateTime.now(),
  );

  final tWallet2 = WalletModel(
    id: '2',
    name: 'Dompet Cadangan',
    balance: -50000,
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockWalletOperation = MockWalletOperation();
    container = ProviderContainer(
      overrides: [
        walletOperationProvider.overrideWithValue(mockWalletOperation),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  void aturStubSukses() {
    when(mockWalletOperation.getWallets())
        .thenAnswer((_) async => [tWallet1, tWallet2]);
    when(mockWalletOperation.getPositiveBalance()).thenAnswer((_) async => 100000);
    when(mockWalletOperation.getNegativeBalance()).thenAnswer((_) async => -50000);
    when(mockWalletOperation.getTotalBalance()).thenAnswer((_) async => 50000);
  }

  test('1. Pengujian build provider', () async {
    aturStubSukses();

    final future = container.read(walletProvider.future);

    await expectLater(
      future,
      completes,
    );

    final state = await future;
    expect(state.wallets, [tWallet1, tWallet2]);
    expect(state.totalPositiveBalance, 100000);
    expect(state.totalNegativeBalance, 50000);
    expect(state.totalBalance, 50000);

    verify(mockWalletOperation.getWallets()).called(1);
    verify(mockWalletOperation.getPositiveBalance()).called(1);
    verify(mockWalletOperation.getNegativeBalance()).called(1);
    verify(mockWalletOperation.getTotalBalance()).called(1);
  });

  test('2. Pengujian tambah dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    final newWallet = WalletModel(
      id: '3',
      name: 'Dompet Baru',
      balance: 20000,
      updatedAt: DateTime.now(),
    );

    when(mockWalletOperation.createWallet(newWallet)).thenAnswer((_) async {});
    when(mockWalletOperation.getWallets())
        .thenAnswer((_) async => [tWallet1, tWallet2, newWallet]);
    when(mockWalletOperation.getPositiveBalance()).thenAnswer((_) async => 120000);
    when(mockWalletOperation.getTotalBalance()).thenAnswer((_) async => 70000);

    await container.read(walletProvider.notifier).addWallet(newWallet);

    final state = container.read(walletProvider).value;

    expect(state?.wallets.length, 3);
    expect(state?.wallets.last.id, '3');
    expect(state?.totalPositiveBalance, 120000);
    expect(state?.totalBalance, 70000);
    verify(mockWalletOperation.createWallet(newWallet)).called(1);
  });

  test('3. Pengujian update dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    final updatedWallet = tWallet1.copyWith(balance: 150000);

    when(mockWalletOperation.updateWallet(updatedWallet)).thenAnswer((_) async {});
    when(mockWalletOperation.getWallets())
        .thenAnswer((_) async => [updatedWallet, tWallet2]);
    when(mockWalletOperation.getPositiveBalance()).thenAnswer((_) async => 150000);
    when(mockWalletOperation.getTotalBalance()).thenAnswer((_) async => 100000);

    await container.read(walletProvider.notifier).updateWallet(updatedWallet);

    final state = container.read(walletProvider).value;

    expect(state?.wallets.first.balance, 150000);
    expect(state?.totalPositiveBalance, 150000);
    expect(state?.totalBalance, 100000);
    verify(mockWalletOperation.updateWallet(updatedWallet)).called(1);
  });

  test('4. Pengujian hapus sementara dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    when(mockWalletOperation.softDelete(tWallet1.id)).thenAnswer((_) async {});
    when(mockWalletOperation.getWallets()).thenAnswer((_) async => [tWallet2]);
    when(mockWalletOperation.getPositiveBalance()).thenAnswer((_) async => 0);
    when(mockWalletOperation.getNegativeBalance()).thenAnswer((_) async => -50000);
    when(mockWalletOperation.getTotalBalance()).thenAnswer((_) async => -50000);

    await container.read(walletProvider.notifier).softDelete(tWallet1.id);

    final state = container.read(walletProvider).value;

    expect(state?.wallets.length, 1);
    expect(state?.wallets.first.id, '2');
    expect(state?.totalBalance, -50000);
    verify(mockWalletOperation.softDelete(tWallet1.id)).called(1);
  });

  test('5. Pengujian hapus semua dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    when(mockWalletOperation.deleteAllWallets()).thenAnswer((_) async {});
    when(mockWalletOperation.getWallets()).thenAnswer((_) async => []);
    when(mockWalletOperation.getPositiveBalance()).thenAnswer((_) async => 0);
    when(mockWalletOperation.getNegativeBalance()).thenAnswer((_) async => 0);
    when(mockWalletOperation.getTotalBalance()).thenAnswer((_) async => 0);

    await container.read(walletProvider.notifier).deleteAllWallets();

    final state = container.read(walletProvider).value;

    expect(state?.wallets, isEmpty);
    expect(state?.totalBalance, 0);
    verify(mockWalletOperation.deleteAllWallets()).called(1);
  });

  test('6. Pengujian refresh', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    // Simulate data change
    final tWallet3 = WalletModel(
        id: '3',
        name: 'Dompet Lain',
        balance: 30000,
        updatedAt: DateTime.now());
    when(mockWalletOperation.getWallets()).thenAnswer((_) async => [tWallet3]);
    when(mockWalletOperation.getPositiveBalance()).thenAnswer((_) async => 30000);
    when(mockWalletOperation.getNegativeBalance()).thenAnswer((_) async => 0);
    when(mockWalletOperation.getTotalBalance()).thenAnswer((_) async => 30000);

    await container.read(walletProvider.notifier).refresh();

    final state = container.read(walletProvider).value;

    expect(state?.wallets.length, 1);
    expect(state?.wallets.first.id, '3');
    expect(state?.totalBalance, 30000);
    // getWallets dipanggil dua kali (build dan refresh)
    verify(mockWalletOperation.getWallets()).called(2);
  });
}

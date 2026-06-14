// path: test/admin/providers/wallet_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';

import 'wallet_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DompetOpSqlite>()])
void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late ProviderContainer container;

  final tWallet1 = DompetModel(
    id: '1',
    name: 'Dompet Utama',
    balance: 100000,
    updatedAt: DateTime.now(),
  );

  final tWallet2 = DompetModel(
    id: '2',
    name: 'Dompet Cadangan',
    balance: -50000,
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    container = ProviderContainer(
      overrides: [
        walletOperationProvider.overrideWithValue(mockDompetOpSqlite),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  void aturStubSukses() {
    when(mockDompetOpSqlite.ambilSemua())
        .thenAnswer((_) async => [tWallet1, tWallet2]);
    when(mockDompetOpSqlite.ambilSaldoPositif())
        .thenAnswer((_) async => 100000);
    when(mockDompetOpSqlite.ambilSaldoNegatif())
        .thenAnswer((_) async => -50000);
    when(mockDompetOpSqlite.ambilTotalsaldo()).thenAnswer((_) async => 50000);
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
    expect(state.totalSaldoPositif, 100000);
    expect(state.totalSaldoNegatif, 50000);
    expect(state.totalSaldo, 50000);

    verify(mockDompetOpSqlite.ambilSemua()).called(1);
    verify(mockDompetOpSqlite.ambilSaldoPositif()).called(1);
    verify(mockDompetOpSqlite.ambilSaldoNegatif()).called(1);
    verify(mockDompetOpSqlite.ambilTotalsaldo()).called(1);
  });

  test('2. Pengujian tambah dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    final newWallet = DompetModel(
      id: '3',
      name: 'Dompet Baru',
      balance: 20000,
      updatedAt: DateTime.now(),
    );

    when(mockDompetOpSqlite.tambahDompet(newWallet)).thenAnswer((_) async {});
    when(mockDompetOpSqlite.ambilSemua())
        .thenAnswer((_) async => [tWallet1, tWallet2, newWallet]);
    when(mockDompetOpSqlite.ambilSaldoPositif())
        .thenAnswer((_) async => 120000);
    when(mockDompetOpSqlite.ambilTotalsaldo()).thenAnswer((_) async => 70000);

    await container.read(walletProvider.notifier).tambahDompet(newWallet);

    final state = container.read(walletProvider).value;

    expect(state?.wallets.length, 3);
    expect(state?.wallets.last.id, '3');
    expect(state?.totalSaldoPositif, 120000);
    expect(state?.totalSaldo, 70000);
    verify(mockDompetOpSqlite.tambahDompet(newWallet)).called(1);
  });

  test('3. Pengujian update dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    final updatedWallet = tWallet1.copyWith(balance: 150000);

    when(mockDompetOpSqlite.updateDompet(updatedWallet))
        .thenAnswer((_) async {});
    when(mockDompetOpSqlite.ambilSemua())
        .thenAnswer((_) async => [updatedWallet, tWallet2]);
    when(mockDompetOpSqlite.ambilSaldoPositif())
        .thenAnswer((_) async => 150000);
    when(mockDompetOpSqlite.ambilTotalsaldo()).thenAnswer((_) async => 100000);

    await container.read(walletProvider.notifier).updateDompet(updatedWallet);

    final state = container.read(walletProvider).value;

    expect(state?.wallets.first.balance, 150000);
    expect(state?.totalSaldoPositif, 150000);
    expect(state?.totalSaldo, 100000);
    verify(mockDompetOpSqlite.updateDompet(updatedWallet)).called(1);
  });

  test('4. Pengujian hapus sementara dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    when(mockDompetOpSqlite.softDelete(tWallet1.id)).thenAnswer((_) async {});
    when(mockDompetOpSqlite.ambilSemua()).thenAnswer((_) async => [tWallet2]);
    when(mockDompetOpSqlite.ambilSaldoPositif()).thenAnswer((_) async => 0);
    when(mockDompetOpSqlite.ambilSaldoNegatif())
        .thenAnswer((_) async => -50000);
    when(mockDompetOpSqlite.ambilTotalsaldo()).thenAnswer((_) async => -50000);

    await container.read(walletProvider.notifier).softDelete(tWallet1.id);

    final state = container.read(walletProvider).value;

    expect(state?.wallets.length, 1);
    expect(state?.wallets.first.id, '2');
    expect(state?.totalSaldo, -50000);
    verify(mockDompetOpSqlite.softDelete(tWallet1.id)).called(1);
  });

  test('5. Pengujian hapus semua dompet', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    when(mockDompetOpSqlite.softDeleteAll()).thenAnswer((_) async => 2);
    when(mockDompetOpSqlite.ambilSemua()).thenAnswer((_) async => []);
    when(mockDompetOpSqlite.ambilSaldoPositif()).thenAnswer((_) async => 0);
    when(mockDompetOpSqlite.ambilSaldoNegatif()).thenAnswer((_) async => 0);
    when(mockDompetOpSqlite.ambilTotalsaldo()).thenAnswer((_) async => 0);

    await container.read(walletProvider.notifier).softDeleteAll();

    final state = container.read(walletProvider).value;

    expect(state?.wallets, isEmpty);
    expect(state?.totalSaldo, 0);
    verify(mockDompetOpSqlite.softDeleteAll()).called(1);
  });

  test('6. Pengujian refresh', () async {
    aturStubSukses();
    await container.read(walletProvider.future);

    // Simulate data change
    final tWallet3 = DompetModel(
        id: '3',
        name: 'Dompet Lain',
        balance: 30000,
        updatedAt: DateTime.now());
    when(mockDompetOpSqlite.ambilSemua()).thenAnswer((_) async => [tWallet3]);
    when(mockDompetOpSqlite.ambilSaldoPositif()).thenAnswer((_) async => 30000);
    when(mockDompetOpSqlite.ambilSaldoNegatif()).thenAnswer((_) async => 0);
    when(mockDompetOpSqlite.ambilTotalsaldo()).thenAnswer((_) async => 30000);

    await container.read(walletProvider.notifier).refresh();

    final state = container.read(walletProvider).value;

    expect(state?.wallets.length, 1);
    expect(state?.wallets.first.id, '3');
    expect(state?.totalSaldo, 30000);
    // getWallets dipanggil dua kali (build dan refresh)
    verify(mockDompetOpSqlite.ambilSemua()).called(2);
  });
}

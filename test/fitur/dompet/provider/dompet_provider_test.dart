
// path: test/fitur/dompet/provider/dompet_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

void main() {
  late MockDompetOpSqlite mockDompetOp;
  late ProviderContainer container;

  final tDompet1 = DompetModel(id: '1', nama: 'Dompet 1', saldo: 1000);
  final tDompet2 = DompetModel(id: '2', nama: 'Dompet 2', saldo: -500);

  setUp(() {
    mockDompetOp = MockDompetOpSqlite();
    container = ProviderContainer(
      overrides: [
        dompetOpSqliteProvider.overrideWithValue(mockDompetOp),
      ],
    );

    // Default mocks
    when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => [tDompet1, tDompet2]);
    when(() => mockDompetOp.ambilSaldoPositif()).thenAnswer((_) async => 1000);
    when(() => mockDompetOp.ambilSaldoNegatif()).thenAnswer((_) async => -500);
    when(() => mockDompetOp.ambilTotalsaldo()).thenAnswer((_) async => 500);
    when(() => mockDompetOp.tambahDompet(any())).thenAnswer((_) async => 1);
    when(() => mockDompetOp.updateDompet(any())).thenAnswer((_) async => 1);
    when(() => mockDompetOp.softDelete(any())).thenAnswer((_) async => 1);
    when(() => mockDompetOp.softDeleteAll()).thenAnswer((_) async => 2);
    registerFallbackValue(tDompet1);
  });

  group('Dompet Provider', () {
    test('01. harus memuat data dompet dengan benar saat inisialisasi',
        () async {
      final state = await container.read(dompetProvider.future);

      expect(state.wallets, [tDompet1, tDompet2]);
      expect(state.totalSaldoPositif, 1000);
      expect(state.totalSaldoNegatif, 500);
      expect(state.totalSaldo, 500);
    });

    test('02. harus menambah dompet baru dan memuat ulang data', () async {
      final newWallet = DompetModel(id: '3', nama: 'Dompet 3', saldo: 200);
      when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => [tDompet1, tDompet2, newWallet]);
      when(() => mockDompetOp.tambahDompet(any())).thenAnswer((_) async => 1);

      await container.read(dompetProvider.notifier).tambahDompet(newWallet);
      final state = await container.read(dompetProvider.future);

      expect(state.wallets, contains(newWallet));
      verify(() => mockDompetOp.tambahDompet(newWallet)).called(1);
    });

    test('03. harus update dompet dan memuat ulang data', () async {
      final updatedWallet = DompetModel(id: '1', nama: 'Dompet 1 Updated', saldo: 1500);
      when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => [updatedWallet, tDompet2]);
      when(() => mockDompetOp.updateDompet(any())).thenAnswer((_) async => 1);

      await container.read(dompetProvider.notifier).updateDompet(updatedWallet);
      final state = await container.read(dompetProvider.future);

      expect(state.wallets.first, updatedWallet);
      verify(() => mockDompetOp.updateDompet(updatedWallet)).called(1);
    });

    test('04. harus soft delete dompet dan memuat ulang data', () async {
      when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => [tDompet2]);
      when(() => mockDompetOp.softDelete('1')).thenAnswer((_) async => 1);

      await container.read(dompetProvider.notifier).softDelete('1');
      final state = await container.read(dompetProvider.future);

      expect(state.wallets, isNot(contains(tDompet1)));
      verify(() => mockDompetOp.softDelete('1')).called(1);
    });

    test('05. harus soft delete semua dompet dan memuat ulang data', () async {
      when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => []);
      when(() => mockDompetOp.softDeleteAll()).thenAnswer((_) async => 2);

      await container.read(dompetProvider.notifier).softDeleteAll();
      final state = await container.read(dompetProvider.future);

      expect(state.wallets, isEmpty);
      verify(() => mockDompetOp.softDeleteAll()).called(1);
    });

    test('06. harus refresh data dompet', () async {
      await container.read(dompetProvider.notifier).refresh();
      await container.read(dompetProvider.future);

      verify(() => mockDompetOp.ambilSemua()).called(2);
    });
  });
}

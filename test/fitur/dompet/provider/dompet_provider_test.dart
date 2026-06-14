// path: test/fitur/dompet/provider/dompet_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/shared/model/wallet_model.dart';

// Mock DompetOpSqlite
class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

void main() {
  group('DompetProvider', () {
    late MockDompetOpSqlite mockDompetOpSqlite;
    late ProviderContainer container;

    // Data dummy
    final dompet1 = WalletModel(id: '1', name: 'Dompet Utama', balance: 1000.0);
    final dompet2 =
        WalletModel(id: '2', name: 'Dompet Cadangan', balance: -500.0);
    final dompetBaru =
        WalletModel(id: '3', name: 'Dompet Baru', balance: 200.0);

    setUp(() {
      mockDompetOpSqlite = MockDompetOpSqlite();
      container = ProviderContainer(
        overrides: [
          // Ganti dompetOpSqliteProvider dengan mock
          dompetOpSqliteProvider.overrideWithValue(mockDompetOpSqlite),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    // Helper untuk mock _loadData
    void mockLoadDataSuccess({
      List<WalletModel>? wallets,
      double? totalPositif,
      double? totalNegatif,
      double? totalSaldo,
    }) {
      when(() => mockDompetOpSqlite.ambilSemua(showArchived: false))
          .thenAnswer((_) async => wallets ?? [dompet1, dompet2]);
      when(() => mockDompetOpSqlite.ambilSaldoPositif())
          .thenAnswer((_) async => totalPositif ?? 1000.0);
      when(() => mockDompetOpSqlite.ambilSaldoNegatif())
          .thenAnswer((_) async => totalNegatif ?? -500.0);
      when(() => mockDompetOpSqlite.ambilTotalsaldo())
          .thenAnswer((_) async => totalSaldo ?? 500.0);
    }

    void mockLoadDataFailure(Exception exception) {
      when(() => mockDompetOpSqlite.ambilSemua(showArchived: false))
          .thenThrow(exception);
      when(() => mockDompetOpSqlite.ambilSaldoPositif()).thenThrow(exception);
      when(() => mockDompetOpSqlite.ambilSaldoNegatif()).thenThrow(exception);
      when(() => mockDompetOpSqlite.ambilTotalsaldo()).thenThrow(exception);
    }

    test(
        '01. harus memuat data dan mengembalikan DompetState dengan benar saat sukses',
        () async {
      // Arrange
      mockLoadDataSuccess();

      // Act
      final result = await container.read(dompetProvider.future);

      // Assert
      expect(result.wallets, [dompet1, dompet2]);
      expect(result.totalSaldoPositif, 1000.0);
      expect(result.totalSaldoNegatif, 500.0); // abs()
      expect(result.totalSaldo, 500.0);
    });

    test('02. harus mengembalikan AsyncError saat _loadData gagal', () async {
      // Arrange
      final exception = Exception('Gagal memuat data');
      mockLoadDataFailure(exception);

      // Act
      // Membaca provider akan memicu build dan _loadData
      await container.read(dompetProvider.future).catchError((_) => {});

      // Assert
      final state = container.read(dompetProvider);
      expect(state, isA<AsyncError>());
      expect((state as AsyncError).error, isA<Exception>());
      expect(
          (state.error as Exception).toString(), contains('Gagal memuat data'));
    });

    test(
        '03. harus memanggil tambahDompet pada repositori dan memuat ulang data saat sukses',
        () async {
      // Arrange
      mockLoadDataSuccess(); // Muat data awal
      await container.read(dompetProvider.future); // Tunggu build selesai

      when(() => mockDompetOpSqlite.tambahDompet(dompetBaru))
          .thenAnswer((_) async {});
      // Mock data setelah ditambah
      mockLoadDataSuccess(
        wallets: [dompet1, dompet2, dompetBaru],
        totalPositif: 1200.0,
        totalSaldo: 700.0,
      );

      // Act
      await container.read(dompetProvider.notifier).tambahDompet(dompetBaru);

      // Assert
      verify(() => mockDompetOpSqlite.tambahDompet(dompetBaru)).called(1);
      final state = container.read(dompetProvider);
      expect(state.value?.wallets.length, 3);
      expect(state.value?.totalSaldo, 700.0);
    });

    test(
        '04. harus mengembalikan AsyncError jika tambahDompet pada repositori gagal',
        () async {
      // Arrange
      final exception = Exception('Gagal menambah');
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.tambahDompet(dompetBaru))
          .thenThrow(exception);

      // Act
      await container.read(dompetProvider.notifier).tambahDompet(dompetBaru);

      // Assert
      final state = container.read(dompetProvider);
      expect(state, isA<AsyncError>());
      expect((state as AsyncError).error, isA<Exception>());
      expect((state.error as Exception).toString(), contains('Gagal menambah'));
    });

    test(
        '05. harus memanggil updateDompet pada repositori dan memuat ulang data saat sukses',
        () async {
      // Arrange
      final dompetUpdate = dompet1.copyWith(balance: 1500.0);
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.updateDompet(dompetUpdate))
          .thenAnswer((_) async {});
      // Mock data setelah diupdate
      mockLoadDataSuccess(
        wallets: [dompetUpdate, dompet2],
        totalPositif: 1500.0,
        totalSaldo: 1000.0,
      );

      // Act
      await container.read(dompetProvider.notifier).updateDompet(dompetUpdate);

      // Assert
      verify(() => mockDompetOpSqlite.updateDompet(dompetUpdate)).called(1);
      final state = container.read(dompetProvider);
      expect(state.value?.wallets.first.saldo, 1500.0);
      expect(state.value?.totalSaldo, 1000.0);
    });

    test(
        '06. harus mengembalikan AsyncError jika updateDompet pada repositori gagal',
        () async {
      // Arrange
      final exception = Exception('Gagal update');
      final dompetUpdate = dompet1.copyWith(balance: 1500.0);
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.updateDompet(dompetUpdate))
          .thenThrow(exception);

      // Act
      await container.read(dompetProvider.notifier).updateDompet(dompetUpdate);

      // Assert
      final state = container.read(dompetProvider);
      expect(state, isA<AsyncError>());
      expect((state as AsyncError).error, isA<Exception>());
      expect((state.error as Exception).toString(), contains('Gagal update'));
    });

    test(
        '07. harus memanggil softDelete pada repositori dan memuat ulang data saat sukses',
        () async {
      // Arrange
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.softDelete('1')).thenAnswer((_) async {});
      // Mock data setelah dihapus
      mockLoadDataSuccess(
        wallets: [dompet2],
        totalPositif: 0,
        totalSaldo: -500.0,
      );

      // Act
      await container.read(dompetProvider.notifier).softDelete('1');

      // Assert
      verify(() => mockDompetOpSqlite.softDelete('1')).called(1);
      final state = container.read(dompetProvider);
      expect(state.value?.wallets.length, 1);
      expect(state.value?.wallets.first.id, '2');
      expect(state.value?.totalSaldo, -500.0);
    });

    test(
        '08. harus mengembalikan AsyncError jika softDelete pada repositori gagal',
        () async {
      // Arrange
      final exception = Exception('Gagal hapus');
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.softDelete('1')).thenThrow(exception);

      // Act
      await container.read(dompetProvider.notifier).softDelete('1');

      // Assert
      final state = container.read(dompetProvider);
      expect(state, isA<AsyncError>());
      expect((state.error as Exception).toString(), contains('Gagal hapus'));
    });

    test(
        '09. harus memanggil softDeleteAll pada repositori dan memuat ulang data saat sukses',
        () async {
      // Arrange
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.softDeleteAll()).thenAnswer((_) async => 2);
      // Mock data setelah semua dihapus
      mockLoadDataSuccess(
        wallets: [],
        totalPositif: 0,
        totalNegatif: 0,
        totalSaldo: 0,
      );

      // Act
      await container.read(dompetProvider.notifier).softDeleteAll();

      // Assert
      verify(() => mockDompetOpSqlite.softDeleteAll()).called(1);
      final state = container.read(dompetProvider);
      expect(state.value?.wallets.isEmpty, isTrue);
      expect(state.value?.totalSaldo, 0.0);
    });

    test(
        '10. harus mengembalikan AsyncError jika softDeleteAll pada repositori gagal',
        () async {
      // Arrange
      final exception = Exception('Gagal hapus semua');
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      when(() => mockDompetOpSqlite.softDeleteAll()).thenThrow(exception);

      // Act
      await container.read(dompetProvider.notifier).softDeleteAll();

      // Assert
      final state = container.read(dompetProvider);
      expect(state, isA<AsyncError>());
      expect(
          (state.error as Exception).toString(), contains('Gagal hapus semua'));
    });

    test('11. harus memuat ulang data dengan sukses saat refresh dipanggil',
        () async {
      // Arrange
      mockLoadDataSuccess(); // Data awal
      await container.read(dompetProvider.future);

      // Data baru setelah refresh
      final dompetRefreshed =
          WalletModel(id: 'refreshed', name: 'Refreshed', balance: 999);
      mockLoadDataSuccess(
        wallets: [dompetRefreshed],
        totalPositif: 999,
        totalNegatif: 0,
        totalSaldo: 999,
      );

      // Act
      await container.read(dompetProvider.notifier).refresh();

      // Assert
      final state = container.read(dompetProvider);
      expect(state.value?.wallets.length, 1);
      expect(state.value?.wallets.first.id, 'refreshed');
      expect(state.value?.totalSaldo, 999);
    });

    test('12. harus mengembalikan AsyncError jika proses refresh gagal',
        () async {
      // Arrange
      mockLoadDataSuccess();
      await container.read(dompetProvider.future);

      final exception = Exception('Gagal refresh');
      mockLoadDataFailure(exception);

      // Act
      await container.read(dompetProvider.notifier).refresh();

      // Assert
      final state = container.read(dompetProvider);
      expect(state, isA<AsyncError>());
      expect((state.error as Exception).toString(), contains('Gagal refresh'));
    });
  });
}

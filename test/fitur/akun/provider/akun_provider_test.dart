// path: test/fitur/akun/provider/akun_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

import 'akun_provider_test.mocks.dart';

@GenerateMocks([LayananPenyimpananLokal])
void main() {
  group('PengelolaAkun Notifier', () {
    late MockLayananPenyimpananLokal mockLayananPenyimpananLokal;
    late ProviderContainer container;

    const pelanggan1 = PelangganModel(
      id: '1',
      nama: 'User Satu',
      alamat: 'Alamat 1',
      telepon: '123',
      macAddress: 'mac1',
      kataSandi: 'pass1',
    );
    const pelanggan2 = PelangganModel(
      id: '2',
      nama: 'User Dua',
      alamat: 'Alamat 2',
      telepon: '456',
      macAddress: 'mac2',
      kataSandi: 'pass2',
    );

    setUp(() {
      mockLayananPenyimpananLokal = MockLayananPenyimpananLokal();
      container = ProviderContainer(
        overrides: [
          layananPenyimpananLokalProvider.overrideWithValue(
            AsyncData(mockLayananPenyimpananLokal),
          ),
        ],
      );
    });

    test('01. build should initialize state from local storage', () async {
      when(
        mockLayananPenyimpananLokal.ambilAkunLogin(),
      ).thenAnswer((_) async => pelanggan1);
      when(
        mockLayananPenyimpananLokal.ambilDaftarAkun(),
      ).thenAnswer((_) async => [pelanggan1, pelanggan2]);

      final state = await container.read(pengelolaAkunProvider.future);

      expect(state.akunSaatIni, pelanggan1);
      expect(state.daftarAkunTersimpan.length, 2);
    });

    test('02. login should save account and update state', () async {
      // Initial setup
      when(
        mockLayananPenyimpananLokal.ambilAkunLogin(),
      ).thenAnswer((_) async => null);
      when(
        mockLayananPenyimpananLokal.ambilDaftarAkun(),
      ).thenAnswer((_) async => [pelanggan2]);

      // Trigger login
      await container.read(pengelolaAkunProvider.notifier).login(pelanggan1);

      // Verify storage was called
      verify(
        mockLayananPenyimpananLokal.simpanAkunSaatIni(pelanggan1),
      ).called(1);

      // Verify state is updated
      final state = container.read(pengelolaAkunProvider).value!;
      expect(state.akunSaatIni, pelanggan1);
      expect(state.daftarAkunTersimpan.length, 1);
    });

    test('03. logout should clear current account and update state', () async {
      // Initial setup with a logged-in user
      when(
        mockLayananPenyimpananLokal.ambilAkunLogin(),
      ).thenAnswer((_) async => pelanggan1);
      when(
        mockLayananPenyimpananLokal.ambilDaftarAkun(),
      ).thenAnswer((_) async => [pelanggan1, pelanggan2]);
      await container.read(pengelolaAkunProvider.future);

      // Prepare for logout
      when(
        mockLayananPenyimpananLokal.hapusAkunSaatIni(),
      ).thenAnswer((_) async => Future.value());
      when(
        mockLayananPenyimpananLokal.ambilAkunLogin(),
      ).thenAnswer((_) async => null);

      // Trigger logout
      await container.read(pengelolaAkunProvider.notifier).logout();

      // Verify storage was called
      verify(mockLayananPenyimpananLokal.hapusAkunSaatIni()).called(1);

      // Verify state is updated
      final state = container.read(pengelolaAkunProvider).value!;
      expect(state.akunSaatIni, isNull);
      expect(state.daftarAkunTersimpan.length, 2);
    });

    test(
      '04. hapusAkun should remove account from list and update state',
      () async {
        // Initial setup
        when(
          mockLayananPenyimpananLokal.ambilAkunLogin(),
        ).thenAnswer((_) async => pelanggan1);
        when(
          mockLayananPenyimpananLokal.ambilDaftarAkun(),
        ).thenAnswer((_) async => [pelanggan1, pelanggan2]);
        await container.read(pengelolaAkunProvider.future);

        // Prepare for deletion
        when(
          mockLayananPenyimpananLokal.hapusAkun('2'),
        ).thenAnswer((_) async => Future.value());

        // Trigger deletion
        await container.read(pengelolaAkunProvider.notifier).hapusAkun('2');

        // Verify storage was called
        verify(mockLayananPenyimpananLokal.hapusAkun('2')).called(1);

        // Verify state is updated
        final state = container.read(pengelolaAkunProvider).value!;
        expect(state.akunSaatIni, pelanggan1);
        expect(state.daftarAkunTersimpan.length, 1);
        expect(state.daftarAkunTersimpan.first.id, '1');
      },
    );

    test(
      '05. hapusAkun should also clear current account if it is deleted',
      () async {
        // Initial setup
        when(
          mockLayananPenyimpananLokal.ambilAkunLogin(),
        ).thenAnswer((_) async => pelanggan1);
        when(
          mockLayananPenyimpananLokal.ambilDaftarAkun(),
        ).thenAnswer((_) async => [pelanggan1, pelanggan2]);
        await container.read(pengelolaAkunProvider.future);

        // Prepare for deletion
        when(
          mockLayananPenyimpananLokal.hapusAkun('1'),
        ).thenAnswer((_) async => Future.value());

        // Trigger deletion
        await container.read(pengelolaAkunProvider.notifier).hapusAkun('1');

        // Verify state is updated
        final state = container.read(pengelolaAkunProvider).value!;
        expect(state.akunSaatIni, isNull);
        expect(state.daftarAkunTersimpan.length, 1);
        expect(state.daftarAkunTersimpan.first.id, '2');
      },
    );
  });
}

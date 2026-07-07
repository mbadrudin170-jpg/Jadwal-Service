// path: test/fitur/akun/provider/akun_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

import 'akun_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<LayananPenyimpananLokal>()])
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
          layananPenyimpananLokalProvider
              .overrideWithValue(AsyncValue.data(mockLayananPenyimpananLokal)),
        ],
      );
    });

    test('01. build should initialize state from local storage', () async {
      when(mockLayananPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => pelanggan1);
      when(mockLayananPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [pelanggan1, pelanggan2]);

      final notifier = container.read(pengelolaAkunProvider.notifier);
      final state = await notifier.build();

      expect(state.akunSaatIni, pelanggan1);
      expect(state.daftarAkunTersimpan.length, 2);
    });

    test('02. login should save account and update state', () async {
      when(mockLayananPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [pelanggan2]);

      final notifier = container.read(pengelolaAkunProvider.notifier);
      await notifier.build();
      await notifier.login(pelanggan1);

      verify(mockLayananPenyimpananLokal.simpanAkunSaatIni(pelanggan1))
          .called(1);
      final state = notifier.state.value!;
      expect(state.akunSaatIni, pelanggan1);
      // check if pelanggan1 is added and the list is unique
      expect(state.daftarAkunTersimpan.length, 2);
    });

    test('03. logout should clear current account and update state', () async {
      when(mockLayananPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => pelanggan1);
      when(mockLayananPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [pelanggan1, pelanggan2]);

      final notifier = container.read(pengelolaAkunProvider.notifier);
      await notifier.build();

      await notifier.logout();

      verify(mockLayananPenyimpananLokal.hapusAkunSaatIni()).called(1);

      final state = notifier.state.value!;
      expect(state.akunSaatIni, isNull);
      expect(state.daftarAkunTersimpan.length, 2);
    });

    test('04. hapusAkun should remove account from list and update state',
        () async {
      when(mockLayananPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [pelanggan1, pelanggan2]);

      final notifier = container.read(pengelolaAkunProvider.notifier);
      await notifier.build();
      await notifier.hapusAkun(pelanggan2.id!);

      verify(mockLayananPenyimpananLokal.hapusAkun(pelanggan2.id!)).called(1);

      final state = notifier.state.value!;
      expect(state.daftarAkunTersimpan.length, 1);
      expect(state.daftarAkunTersimpan.first, pelanggan1);
    });

    test(
        '05. hapusAkun should also clear current account if it is deleted',
        () async {
      when(mockLayananPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => pelanggan1);
      when(mockLayananPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [pelanggan1, pelanggan2]);

      final notifier = container.read(pengelolaAkunProvider.notifier);
      await notifier.build();

      await notifier.hapusAkun(pelanggan1.id!);

      final state = notifier.state.value!;
      expect(state.akunSaatIni, isNull);
      expect(state.daftarAkunTersimpan.length, 1);
    });
  });
}

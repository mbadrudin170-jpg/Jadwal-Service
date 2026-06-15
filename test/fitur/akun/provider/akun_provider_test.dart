
// path: test/fitur/akun/provider/akun_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/storage/layanan_penyimpanan_lokal.dart';
import 'package:wifi/shared/storage/penyimpanan_lokal_provider.dart';

// Mocks
class MockLayananPenyimpananLokal extends Mock
    implements LayananPenyimpananLokal {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockLayananPenyimpananLokal mockPenyimpananLokal;
  late ProviderContainer container;

  final tAkun1 = PelangganModel(
    id: '1',
    nama: 'Test User 1',
    email: 'test1@example.com',
    nomorTelepon: '123',
    alamat: 'Alamat 1',
  );
  final tAkun2 = PelangganModel(
    id: '2',
    nama: 'Test User 2',
    email: 'test2@example.com',
    nomorTelepon: '456',
    alamat: 'Alamat 2',
  );

  setUp(() {
    mockPenyimpananLokal = MockLayananPenyimpananLokal();
    container = ProviderContainer(
      overrides: [
        layananPenyimpananLokalProvider
            .overrideWithValue(mockPenyimpananLokal),
      ],
    );
    registerFallbackValue(tAkun1);
  });

  group('PengelolaAkun Provider', () {
    test('01. harus menginisialisasi dengan akun saat ini dan daftar akun',
        () async {
      when(() => mockPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => tAkun1);
      when(() => mockPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);

      final state = await container.read(pengelolaAkunProvider.future);

      expect(state.akunSaatIni, tAkun1);
      expect(state.daftarAkunTersimpan, [tAkun1, tAkun2]);
    });

    test('02. harus login dan menyimpan akun saat ini', () async {
      when(() => mockPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => null);
      when(() => mockPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun2]);
      when(() => mockPenyimpananLokal.simpanAkunSaatIni(any()))
          .thenAnswer((_) async {});

      await container.read(pengelolaAkunProvider.future);
      await container.read(pengelolaAkunProvider.notifier).login(tAkun1);

      final state = container.read(pengelolaAkunProvider).value;

      expect(state?.akunSaatIni, tAkun1);
      verify(() => mockPenyimpananLokal.simpanAkunSaatIni(tAkun1)).called(1);
    });

    test('03. harus logout dan menghapus akun saat ini', () async {
      when(() => mockPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => tAkun1);
      when(() => mockPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);
      when(() => mockPenyimpananLokal.hapusAkunSaatIni()).thenAnswer((_) async {});

      await container.read(pengelolaAkunProvider.future);
      await container.read(pengelolaAkunProvider.notifier).logout();

      final state = container.read(pengelolaAkunProvider).value;

      expect(state?.akunSaatIni, null);
      verify(() => mockPenyimpananLokal.hapusAkunSaatIni()).called(1);
    });

    test('04. harus menghapus akun dari daftar', () async {
      when(() => mockPenyimpananLokal.ambilAkunLogin())
          .thenAnswer((_) async => tAkun1);
      when(() => mockPenyimpananLokal.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);
      when(() => mockPenyimpananLokal.hapusAkun(any())).thenAnswer((_) async {});

      await container.read(pengelolaAkunProvider.future);
      await container.read(pengelolaAkunProvider.notifier).hapusAkun('2');

      final state = container.read(pengelolaAkunProvider).value;

      expect(state?.daftarAkunTersimpan.length, 1);
      expect(state?.daftarAkunTersimpan.first, tAkun1);
      verify(() => mockPenyimpananLokal.hapusAkun('2')).called(1);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

// Mocks
class MockLayananPenyimpananLokal extends Mock
    implements LayananPenyimpananLokal {}

void main() {
  late MockLayananPenyimpananLokal mockPenyimpananLokal;
  late ProviderContainer container;

  // Perbaiki parameter PelangganModel - gunakan parameter yang benar
  const tAkun1 = PelangganModel(
    id: '1',
    nama: 'Test User 1',
    telepon: '08123456789',      // ganti dari email/nomorTelepon
    alamat: 'Alamat 1',
    kataSandi: 'password123',    // wajib
    macAddress: 'AA:BB:CC:DD:EE:FF', // wajib
  );
  
  const tAkun2 = PelangganModel(
    id: '2',
    nama: 'Test User 2',
    telepon: '08987654321',      // ganti dari email/nomorTelepon
    alamat: 'Alamat 2',
    kataSandi: 'rahasia',        // wajib
    macAddress: '11:22:33:44:55:66', // wajib
  );

  setUp(() {
    mockPenyimpananLokal = MockLayananPenyimpananLokal();
    container = ProviderContainer(
      overrides: [
        // Perbaiki nama provider - sesuai dengan yang didefinisikan di akun_provider.dart
        // Asumsikan provider bernama layananPenyimpananLokalProvider
        layananPenyimpananLokalProvider.overrideWithValue(AsyncValue.data(mockPenyimpananLokal)),
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
      when(() => mockPenyimpananLokal.hapusAkunSaatIni())
          .thenAnswer((_) async {});

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
      when(() => mockPenyimpananLokal.hapusAkun(any()))
          .thenAnswer((_) async {});

      await container.read(pengelolaAkunProvider.future);
      await container.read(pengelolaAkunProvider.notifier).hapusAkun('2');

      final state = container.read(pengelolaAkunProvider).value;

      expect(state?.daftarAkunTersimpan.length, 1);
      expect(state?.daftarAkunTersimpan.first, tAkun1);
      verify(() => mockPenyimpananLokal.hapusAkun('2')).called(1);
    });
  });
}
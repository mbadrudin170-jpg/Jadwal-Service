// path: test/fitur/akun/provider/akun_provider_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

import 'akun_provider_test.mocks.dart';

// 1. Membuat mock untuk LayananPenyimpananLokal
@GenerateNiceMocks([MockSpec<LayananPenyimpananLokal>()])
void main() {
  late MockLayananPenyimpananLokal mockPenyimpanan;
  late ProviderContainer container;

  // 2. Data dummy untuk pengujian
  final tAkun1 = CustomerModel(
    id: 'cust1',
    name: 'Budi',
    address: 'Jl. Melati No. 1',
    phone: '08123456789',
    password: 'password123',
  );

  final tAkun2 = CustomerModel(
    id: 'cust2',
    name: 'Andi',
    address: 'Jl. Mawar No. 2',
    phone: '08987654321',
    password: 'password321',
  );

  setUp(() {
    mockPenyimpanan = MockLayananPenyimpananLokal();

    // 3. Inisialisasi ProviderContainer dengan override
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider
            .overrideWithValue(AsyncValue.data(mockPenyimpanan)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Pengujian PengelolaAkun Provider', () {
    test('1. build harus menginisialisasi state dengan data dari penyimpanan',
        () async {
      // Arrange
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);
      when(mockPenyimpanan.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);

      // Act
      final state = await container.read(pengelolaAkunProvider.future);

      // Assert
      expect(state.akunSaatIni, tAkun1);
      expect(state.daftarAkunTersimpan, [tAkun1, tAkun2]);
      verify(mockPenyimpanan.ambilAkunLogin()).called(1);
      verify(mockPenyimpanan.ambilDaftarAkun()).called(1);
    });

    test('2. login harus menyimpan akun dan memperbarui state', () async {
      // Arrange
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => null);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun2]);

      // Pastikan build awal selesai
      await container.read(pengelolaAkunProvider.future);

      when(mockPenyimpanan.simpanAkunSaatIni(tAkun1))
          .thenAnswer((_) => Future.value());
      when(mockPenyimpanan.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);

      // Act
      await container.read(pengelolaAkunProvider.notifier).login(tAkun1);
      final state = container.read(pengelolaAkunProvider).value;

      // Assert
      expect(state?.akunSaatIni, tAkun1);
      expect(state?.daftarAkunTersimpan.map((e) => e.id).toList(),
          containsAll(['cust1', 'cust2']));
      verify(mockPenyimpanan.simpanAkunSaatIni(tAkun1)).called(1);
    });

    test('3. logout harus menghapus akun saat ini dan memperbarui state',
        () async {
      // Arrange
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun1]);
      await container.read(pengelolaAkunProvider.future);

      when(mockPenyimpanan.hapusTokenLogin()).thenAnswer((_) => Future.value());
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => null);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun1]);

      // Act
      await container.read(pengelolaAkunProvider.notifier).logout();
      final state = container.read(pengelolaAkunProvider).value;

      // Assert
      expect(state?.akunSaatIni, isNull);
      verify(mockPenyimpanan.hapusTokenLogin()).called(1);
    });

    test('4. hapusAkun harus menghapus akun tertentu dari daftar', () async {
      // Arrange
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);
      when(mockPenyimpanan.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);
      await container.read(pengelolaAkunProvider.future);

      when(mockPenyimpanan.hapusAkun('cust2')).thenAnswer((_) => Future.value());
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun1]);

      // Act
      await container.read(pengelolaAkunProvider.notifier).hapusAkun('cust2');
      final state = container.read(pengelolaAkunProvider).value;

      // Assert
      expect(state?.daftarAkunTersimpan.length, 1);
      expect(state?.daftarAkunTersimpan.first.id, 'cust1');
      verify(mockPenyimpanan.hapusAkun('cust2')).called(1);
    });

    test(
        '5. hapusAkun harus mengosongkan akunSaatIni jika akun yang dihapus sedang login',
        () async {
      // Arrange
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);
      when(mockPenyimpanan.ambilDaftarAkun())
          .thenAnswer((_) async => [tAkun1, tAkun2]);
      await container.read(pengelolaAkunProvider.future);

      when(mockPenyimpanan.hapusAkun('cust1')).thenAnswer((_) => Future.value());
      when(mockPenyimpanan.hapusTokenLogin()).thenAnswer((_) => Future.value());
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => null);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun2]);

      // Act
      await container.read(pengelolaAkunProvider.notifier).hapusAkun('cust1');
      final state = container.read(pengelolaAkunProvider).value;

      // Assert
      expect(state?.akunSaatIni, isNull);
      expect(state?.daftarAkunTersimpan.length, 1);
      expect(state?.daftarAkunTersimpan.first.id, 'cust2');
    });

    test(
        '6. hapusTokenLogin harus memanggil fungsi hapus token dan menyegarkan akun login',
        () async {
      // Arrange
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun1]);
      await container.read(pengelolaAkunProvider.future);

      when(mockPenyimpanan.hapusTokenLogin()).thenAnswer((_) => Future.value());
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => null);

      // Act
      await container.read(pengelolaAkunProvider.notifier).hapusTokenLogin();
      final state = container.read(pengelolaAkunProvider).value;

      // Assert
      expect(state?.akunSaatIni, isNull);
      verify(mockPenyimpanan.hapusTokenLogin()).called(1);
    });

    test('7. refresh harus memuat ulang data dari penyimpanan', () async {
      // Arrange
      // Panggilan pertama (saat build)
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun1);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun1]);
      await container.read(pengelolaAkunProvider.future);

      // Pengaturan untuk refresh (data berubah)
      when(mockPenyimpanan.ambilAkunLogin()).thenAnswer((_) async => tAkun2);
      when(mockPenyimpanan.ambilDaftarAkun()).thenAnswer((_) async => [tAkun2]);

      // Act
      await container.read(pengelolaAkunProvider.notifier).refresh();
      final state = container.read(pengelolaAkunProvider).value;

      // Assert
      expect(state?.akunSaatIni, tAkun2);
      expect(state?.daftarAkunTersimpan, [tAkun2]);
    });

    test('8. build harus menangani error dari penyimpanan', () {
      // Arrange
      final exception = Exception('Gagal mengambil data');
      when(mockPenyimpanan.ambilAkunLogin()).thenThrow(exception);
      // Buat container baru khusus untuk test case ini agar bisa mengatur ulang override
      final errorContainer = ProviderContainer(
        overrides: [
          localStorageServiceProvider
              .overrideWithValue(AsyncValue.data(mockPenyimpanan)),
        ],
      );

      // Act & Assert
      expect(
        () => errorContainer.read(pengelolaAkunProvider.future),
        throwsA(isA<Exception>()),
      );
      errorContainer.dispose();
    });
  });
}

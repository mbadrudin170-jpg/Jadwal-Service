// path: test/shared/services/cek_koneksi_internet_test.dart
// Fitur: Pengujian Unit untuk KoneksiInternetService
// Tujuan: Memastikan logika pengecekan koneksi internet berfungsi dengan benar dalam berbagai skenario.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';

// Buat mock untuk Connectivity
@GenerateMocks([Connectivity])
import 'cek_koneksi_internet_test.mocks.dart';

void main() {
  // Gunakan late untuk memastikan mock diinisialisasi sebelum digunakan
  late MockConnectivity mockConnectivity;
  late KoneksiInternetService koneksiService;

  // Grup pengujian untuk KoneksiInternetService
  group('KoneksiInternetService', () {
    // Inisialisasi mock sebelum setiap tes
    setUp(() {
      mockConnectivity = MockConnectivity();
      // Buat instance KoneksiInternetService dengan mock
      koneksiService = KoneksiInternetService(connectivity: mockConnectivity);
    });

    // Test 1: Harus mengembalikan true ketika terhubung ke WiFi
    test('Harus mengembalikan true ketika terhubung ke WiFi', () async {
      // Atur mock untuk mengembalikan hasil WiFi
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Panggil metode yang akan diuji
      final hasil = await koneksiService.cekKoneksi();

      // Verifikasi bahwa hasilnya adalah true
      expect(hasil, isTrue);
      // Verifikasi bahwa checkConnectivity() pada mock dipanggil sekali
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    // Test 2: Harus mengembalikan true ketika terhubung ke data seluler
    test('Harus mengembalikan true ketika terhubung ke data seluler', () async {
      // Atur mock untuk mengembalikan hasil mobile
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Panggil metode yang akan diuji
      final hasil = await koneksiService.cekKoneksi();

      // Verifikasi bahwa hasilnya adalah true
      expect(hasil, isTrue);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    // Test 3: Harus mengembalikan false ketika tidak ada koneksi
    test('Harus mengembalikan false ketika tidak ada koneksi', () async {
      // Atur mock untuk mengembalikan hasil tidak ada koneksi
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Panggil metode yang akan diuji
      final hasil = await koneksiService.cekKoneksi();

      // Verifikasi bahwa hasilnya adalah false
      expect(hasil, isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    // Test 4: Harus mengembalikan false jika terjadi exception
    test('Harus mengembalikan false jika terjadi exception', () async {
      // Atur mock untuk melempar exception
      when(mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Gagal mendapatkan status koneksi'));

      // Panggil metode yang akan diuji
      final hasil = await koneksiService.cekKoneksi();

      // Verifikasi bahwa hasilnya adalah false
      expect(hasil, isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    // Test 5: Harus mengembalikan true ketika ada beberapa hasil tetapi salah satunya adalah wifi
    test('Harus mengembalikan true jika salah satu koneksi adalah WiFi',
        () async {
      when(mockConnectivity.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.bluetooth, ConnectivityResult.wifi],
      );
      final result = await koneksiService.cekKoneksi();
      expect(result, isTrue);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    // Test 6: Harus mengembalikan false untuk koneksi selain mobile dan wifi (misal: bluetooth)
    test('Harus mengembalikan false untuk koneksi bluetooth saja', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.bluetooth]);
      final result = await koneksiService.cekKoneksi();
      expect(result, isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });
  });
}

// path: test/shared/services/cek_koneksi_internet_test.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/services/cek_koneksi_internet.dart';

// --- Mock ---
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late KoneksiInternetService koneksiService;

  setUp(() {
    mockConnectivity = MockConnectivity();
    koneksiService = KoneksiInternetService(connectivity: mockConnectivity);
  });

  group('KoneksiInternetService.cekKoneksi', () {
    test('mengembalikan true jika terhubung ke mobile', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((final _) async => [ConnectivityResult.mobile]);

      final result = await koneksiService.cekKoneksi();
      expect(result, isTrue);
    });

    test('mengembalikan true jika terhubung ke wifi', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((final _) async => [ConnectivityResult.wifi]);

      final result = await koneksiService.cekKoneksi();
      expect(result, isTrue);
    });

    test('mengembalikan true jika terhubung ke mobile dan wifi sekaligus',
        () async {
      when(() => mockConnectivity.checkConnectivity()).thenAnswer(
          (final _) async => [ConnectivityResult.mobile, ConnectivityResult.wifi],);

      final result = await koneksiService.cekKoneksi();
      expect(result, isTrue);
    });

    test('mengembalikan false jika tidak ada koneksi (ConnectivityResult.none)',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((final _) async => [ConnectivityResult.none]);

      final result = await koneksiService.cekKoneksi();
      expect(result, isFalse);
    });

    test('mengembalikan false jika jenis koneksi lain (misal bluetooth)',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((final _) async => [ConnectivityResult.bluetooth]);

      final result = await koneksiService.cekKoneksi();
      expect(result, isFalse);
    });

    test('mengembalikan false jika plugin connectivity_plus melempar exception',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Plugin error'));

      final result = await koneksiService.cekKoneksi();
      expect(result, isFalse);
    });

    test('mengembalikan false jika connectivity_plus melempar error spesifik',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenThrow(MissingPluginException('No implementation'));

      final result = await koneksiService.cekKoneksi();
      expect(result, isFalse);
    });
  });
}

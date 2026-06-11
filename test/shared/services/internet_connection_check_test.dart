// path: test/shared/services/internet_connection_check_test.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

import 'internet_connection_check_test.mocks.dart';

// Buat mock untuk Connectivity dan http.Client
@GenerateMocks([Connectivity, http.Client])
void main() {
  late MockConnectivity mockConnectivity;
  late MockClient mockHttpClient;
  late KoneksiInternetService internetService;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockHttpClient = MockClient();
    internetService = KoneksiInternetService(
      connectivity: mockConnectivity,
      httpClient: mockHttpClient,
      lookupUrl:
          'example.com', // Gunakan URL yang tidak akan benar-benar di-resolve
    );
  });

  group('InternetConnectionService - checkLocalConnection (Koneksi Lokal)', () {
    test('1. harus mengembalikan true untuk wifi', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      expect(await internetService.cekKoneksiLokal(), isTrue);
    });

    test('2. harus mengembalikan true untuk mobile', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      expect(await internetService.cekKoneksiLokal(), isTrue);
    });

    test('3. harus mengembalikan false untuk none', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      expect(await internetService.cekKoneksiLokal(), isFalse);
    });
  });
}

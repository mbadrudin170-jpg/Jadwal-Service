// path: test/shared/services/internet_connection_check_test.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';

import 'internet_connection_check_test.mocks.dart';

// Buat mock untuk Connectivity dan http.Client
@GenerateMocks([Connectivity, http.Client])
void main() {
  late MockConnectivity mockConnectivity;
  late MockClient mockHttpClient;
  late InternetConnectionService internetService;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockHttpClient = MockClient();
    internetService = InternetConnectionService(
      connectivity: mockConnectivity,
      httpClient: mockHttpClient,
      lookupUrl: 'example.com', // Gunakan URL yang tidak akan benar-benar di-resolve
    );
  });

  group('InternetConnectionService - isInternetAvailable (Ketersediaan Internet)', () {
    test(
        '1. harus mengembalikan true saat ada koneksi lokal dan akses internet',
        () async {
      // Arrange
      // Simulasikan ada koneksi (WiFi)
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      
      // Simulasikan lookup ke internet berhasil
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response('OK', 200));

      // Act
      final result = await internetService.isInternetAvailable();

      // Assert
      expect(result, isTrue);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockHttpClient.get(Uri.https('example.com'))).called(1);
    });

    test(
        '2. harus mengembalikan false saat tidak ada koneksi lokal',
        () async {
      // Arrange
      // Simulasikan tidak ada koneksi sama sekali
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      final result = await internetService.isInternetAvailable();

      // Assert
      expect(result, isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
      // Pastikan http client tidak pernah dipanggil jika koneksi lokal tidak ada
      verifyNever(mockHttpClient.get(any));
    });

    test(
        '3. harus mengembalikan false saat ada koneksi lokal tetapi lookup internet gagal',
        () async {
      // Arrange
      // Simulasikan ada koneksi (Mobile)
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      
      // Simulasikan lookup ke internet gagal (misal, timeout)
      when(mockHttpClient.get(any)).thenThrow(TimeoutException('Timeout'));

      // Act
      final result = await internetService.isInternetAvailable();

      // Assert
      expect(result, isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockHttpClient.get(Uri.https('example.com'))).called(1);
    });

    test(
        '4. harus mengembalikan false saat pengecekan koneksi lokal melempar exception',
        () async {
      // Arrange
      // Simulasikan checkConnectivity gagal
      when(mockConnectivity.checkConnectivity()).thenThrow(Exception('Error'));

      // Act
      final result = await internetService.isInternetAvailable();

      // Assert
      expect(result, isFalse);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockHttpClient.get(any));
    });
  });

  group('InternetConnectionService - checkLocalConnection (Koneksi Lokal)', () {
      test('1. harus mengembalikan true untuk wifi', () async {
        when(mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
        expect(await internetService.checkLocalConnection(), isTrue);
      });
      
      test('2. harus mengembalikan true untuk mobile', () async {
        when(mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.mobile]);
        expect(await internetService.checkLocalConnection(), isTrue);
      });

      test('3. harus mengembalikan false untuk none', () async {
        when(mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
        expect(await internetService.checkLocalConnection(), isFalse);
      });
  });
}

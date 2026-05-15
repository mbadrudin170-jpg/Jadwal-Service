
// path: test/shared/services/info_perangkat_service_test.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/services/info_perangkat_service.dart';

import 'info_perangkat_service_test.mocks.dart';

// Generate mocks untuk DeviceInfoPlugin dan AndroidDeviceInfo
@GenerateMocks([DeviceInfoPlugin, AndroidDeviceInfo])
void main() {
  // Set platform target ke Android untuk pengujian ini
  debugDefaultTargetPlatformOverride = TargetPlatform.android;

  group('InfoPerangkatService', () {
    late MockDeviceInfoPlugin mockDeviceInfoPlugin;
    late InfoPerangkatService infoPerangkatService;

    setUp(() {
      mockDeviceInfoPlugin = MockDeviceInfoPlugin();
      infoPerangkatService = InfoPerangkatService(mockDeviceInfoPlugin);
    });

    test(
        'dapatkanArsitekturPerangkat mengembalikan info yang benar untuk Android', 
        () async {
      // Siapkan mock untuk AndroidDeviceInfo
      final mockAndroidInfo = MockAndroidDeviceInfo();
      when(mockAndroidInfo.supportedAbis).thenReturn(['arm64-v8a', 'armeabi-v7a']);
      when(mockAndroidInfo.isPhysicalDevice).thenReturn(true);

      // Atur agar mockDeviceInfoPlugin mengembalikan mockAndroidInfo
      when(mockDeviceInfoPlugin.androidInfo)
          .thenAnswer((final _) async => mockAndroidInfo);

      // Panggil metode yang akan diuji
      final result = await infoPerangkatService.dapatkanArsitekturPerangkat();

      // Verifikasi hasilnya
      expect(result['supportedAbis'], ['arm64-v8a', 'armeabi-v7a']);
      expect(result['isPhysicalDevice'], true);
      expect(result.containsKey('error'), isFalse);
    });

    test('dapatkanArsitekturPerangkat menangani Exception', () async {
      // Atur agar mock melempar Exception
      when(mockDeviceInfoPlugin.androidInfo)
          .thenThrow(Exception('Gagal membaca data'));

      // Panggil metode dan verifikasi hasilnya
      final result = await infoPerangkatService.dapatkanArsitekturPerangkat();

      expect(result.containsKey('error'), isTrue);
      expect(result['error'], contains('Gagal mendapatkan info perangkat'));
    });
  });

  // Reset platform target setelah selesai
  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });
}

// path: test/fitur/info_perangkat/service/layanan_info_perangkat_test.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/info_perangkat/service/layanan_info_perangkat.dart';

import 'layanan_info_perangkat_test.mocks.dart';

@GenerateMocks([DeviceInfoPlugin, AndroidDeviceInfo, IosDeviceInfo, IosUtsname])
void main() {
  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late LayananInfoPerangkat layananInfoPerangkat;

  setUp(() {
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    layananInfoPerangkat = LayananInfoPerangkat(mockDeviceInfoPlugin);
  });

  group('LayananInfoPerangkat', () {
    test('01. harus mengembalikan info perangkat untuk Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final mockAndroidInfo = MockAndroidDeviceInfo();
      when(mockAndroidInfo.supportedAbis).thenReturn(['x86_64']);
      when(mockAndroidInfo.isPhysicalDevice).thenReturn(true);
      when(
        mockDeviceInfoPlugin.androidInfo,
      ).thenAnswer((_) async => mockAndroidInfo);

      final hasil = await layananInfoPerangkat.ambilArsitekturPerangkat();

      expect(hasil, {
        'supportedAbis': ['x86_64'],
        'isPhysicalDevice': true,
      });
      verify(mockDeviceInfoPlugin.androidInfo).called(1);
      debugDefaultTargetPlatformOverride = null;
    });

    test('02. harus mengembalikan info perangkat untuk iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final mockIosInfo = MockIosDeviceInfo();
      final mockUtsname = MockIosUtsname();
      when(mockUtsname.machine).thenReturn('iPhone13,2');
      when(mockIosInfo.utsname).thenReturn(mockUtsname);
      when(mockIosInfo.isPhysicalDevice).thenReturn(true);
      when(mockDeviceInfoPlugin.iosInfo).thenAnswer((_) async => mockIosInfo);

      final hasil = await layananInfoPerangkat.ambilArsitekturPerangkat();

      expect(hasil, {
        'utsname.machine': 'iPhone13,2',
        'isPhysicalDevice': true,
      });
      verify(mockDeviceInfoPlugin.iosInfo).called(1);
      debugDefaultTargetPlatformOverride = null;
    });

    test('03. harus mengembalikan pesan error untuk web', () async {
      final hasil = await layananInfoPerangkat.ambilArsitekturPerangkat();

      expect(hasil, {'error': 'Tidak dapat mendeteksi arsitektur di web.'});
    });

    test(
      '04. harus mengembalikan pesan error ketika terjadi exception',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(
          mockDeviceInfoPlugin.androidInfo,
        ).thenThrow(Exception('Gagal mengambil info'));

        final hasil = await layananInfoPerangkat.ambilArsitekturPerangkat();

        expect(hasil, {
          'error':
              'Gagal mendapatkan info perangkat: Exception: Gagal mengambil info',
        });
        debugDefaultTargetPlatformOverride = null;
      },
    );

    test(
      '05. harus mengembalikan pesan error untuk platform yang tidak didukung',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

        final hasil = await layananInfoPerangkat.ambilArsitekturPerangkat();

        expect(hasil, {'error': 'Platform tidak didukung'});
        debugDefaultTargetPlatformOverride = null;
      },
    );
  });
}

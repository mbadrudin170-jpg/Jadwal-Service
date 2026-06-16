
// path: test/fitur/info_perangkat/service/device_info_service_test.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/info_perangkat/service/device_info_service.dart';

import 'device_info_service_test.mocks.dart';

class FakeIosUtsname extends Fake implements IosUtsname {
  @override
  final String machine;

  FakeIosUtsname({this.machine = 'iPhone13,2'});
}


@GenerateMocks([DeviceInfoPlugin, AndroidDeviceInfo, IosDeviceInfo])
void main() {
  late DeviceInfoService deviceInfoService;
  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late MockAndroidDeviceInfo mockAndroidDeviceInfo;
  late MockIosDeviceInfo mockIosDeviceInfo;

  setUp(() {
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    mockAndroidDeviceInfo = MockAndroidDeviceInfo();
    mockIosDeviceInfo = MockIosDeviceInfo();
    deviceInfoService = DeviceInfoService(mockDeviceInfoPlugin);
  });

  group('DeviceInfoService - Mockito', () {
    test(
        '01. harus mengembalikan informasi arsitektur untuk Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      
      when(mockDeviceInfoPlugin.androidInfo)
          .thenAnswer((_) async => mockAndroidDeviceInfo);
          
      when(mockAndroidDeviceInfo.supportedAbis)
          .thenReturn(['x86_64', 'arm64-v8a']);
      when(mockAndroidDeviceInfo.isPhysicalDevice).thenReturn(true);

      final result = await deviceInfoService.getDeviceArchitecture();

      expect(result['supportedAbis'], ['x86_64', 'arm64-v8a']);
      expect(result['isPhysicalDevice'], true);
      
      debugDefaultTargetPlatformOverride = null;
    });

    test('02. harus mengembalikan informasi arsitektur untuk iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      
      when(mockDeviceInfoPlugin.iosInfo)
          .thenAnswer((_) async => mockIosDeviceInfo);
          
      when(mockIosDeviceInfo.utsname).thenReturn(FakeIosUtsname(machine: 'iPhone13,2'));
      when(mockIosDeviceInfo.isPhysicalDevice).thenReturn(true);

      final result = await deviceInfoService.getDeviceArchitecture();

      expect(result['utsname.machine'], 'iPhone13,2');
      expect(result['isPhysicalDevice'], true);
      
      debugDefaultTargetPlatformOverride = null;
    });

    test('03. harus mengembalikan error untuk platform yang tidak didukung', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      
      final result = await deviceInfoService.getDeviceArchitecture();

      expect(result['error'], 'Platform tidak didukung');
      
      debugDefaultTargetPlatformOverride = null;
    });

    test('04. harus menangani exception dan mengembalikan error', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      
      when(mockDeviceInfoPlugin.androidInfo)
          .thenThrow(Exception('Gagal'));

      final result = await deviceInfoService.getDeviceArchitecture();

      expect(result['error'], 'Gagal mendapatkan info perangkat: Exception: Gagal');
      
      debugDefaultTargetPlatformOverride = null;
    });
  });
}

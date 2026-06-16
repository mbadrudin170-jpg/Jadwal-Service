// path: lib/shared/services/device_info_service.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas layanan untuk mendapatkan informasi tentang perangkat.
class DeviceInfoService {
  /// Instance dari [DeviceInfoPlugin] untuk mendapatkan informasi perangkat.
  final DeviceInfoPlugin deviceInfo;

  /// Konstruktor untuk DeviceInfoService.
  ///
  /// Membutuhkan instance [DeviceInfoPlugin] untuk diinjeksi,
  /// yang memungkinkan untuk pengujian dengan mock.
  DeviceInfoService(this.deviceInfo) {
    Log.info('DeviceInfoService diinisialisasi.');
  }

  /// Mendapatkan arsitektur perangkat.
  Future<Map<String, dynamic>> getDeviceArchitecture() async {
    Log.info('Memulai pengambilan informasi arsitektur perangkat.');
    if (kIsWeb) {
      Log.warning('Tidak dapat mendeteksi arsitektur di platform web.');
      return {
        'error': 'Tidak dapat mendeteksi arsitektur di web.',
      };
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        Log.info(
            'Platform terdeteksi: Android. Mengambil AndroidDeviceInfo...');
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        final result = {
          'supportedAbis': androidInfo.supportedAbis,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
        Log.info('Informasi Android berhasil didapatkan:', result);
        return result;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        Log.info('Platform terdeteksi: iOS. Mengambil IosDeviceInfo...');
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        final result = {
          'utsname.machine': iosInfo.utsname.machine,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
        Log.info('Informasi iOS berhasil didapatkan:', result);
        return result;
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mendapatkan info perangkat.',
        e: e,
        s: s,
      );
      return {
        'error': 'Gagal mendapatkan info perangkat: $e',
      };
    }
    Log.warning('Platform tidak didukung oleh DeviceInfoService.');
    return {
      'error': 'Platform tidak didukung',
    };
  }
}

// path: lib/shared/services/info_perangkat_service.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Kelas layanan untuk mendapatkan informasi tentang perangkat.
class InfoPerangkatService {
  /// Instance dari [DeviceInfoPlugin] untuk mendapatkan informasi perangkat.
  final DeviceInfoPlugin deviceInfo;

  /// Konstruktor untuk InfoPerangkatService.
  ///
  /// Membutuhkan instance [DeviceInfoPlugin] untuk diinjeksi,
  /// yang memungkinkan untuk pengujian dengan mock.
  InfoPerangkatService(this.deviceInfo);

  /// Mendapatkan arsitektur perangkat.
  Future<Map<String, dynamic>> dapatkanArsitekturPerangkat() async {
    if (kIsWeb) {
      return {'error': 'Tidak dapat mendeteksi arsitektur di web.'};
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'supportedAbis': androidInfo.supportedAbis,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {
          'utsname.machine': iosInfo.utsname.machine,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      }
    } on Exception catch (e) {
      return {'error': 'Gagal mendapatkan info perangkat: $e'};
    }
    return {'error': 'Platform tidak didukung'};
  }
}

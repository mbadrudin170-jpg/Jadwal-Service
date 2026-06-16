// path: lib/fitur/info_perangkat/service/layanan_info_perangkat.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananInfoPerangkat {
  final DeviceInfoPlugin infoPerangkat;

  LayananInfoPerangkat(this.infoPerangkat) {
    Log.info('DeviceInfoService diinisialisasi.');
  }

  Future<Map<String, dynamic>> ambilArsitekturPerangkat() async {
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
        final AndroidDeviceInfo infoAndroid = await infoPerangkat.androidInfo;
        final hasilArsitektur = {
          'supportedAbis': infoAndroid.supportedAbis,
          'isPhysicalDevice': infoAndroid.isPhysicalDevice,
        };
        Log.info('Informasi Android berhasil didapatkan:', hasilArsitektur);
        return hasilArsitektur;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        Log.info('Platform terdeteksi: iOS. Mengambil IosDeviceInfo...');
        final IosDeviceInfo infoIos = await infoPerangkat.iosInfo;
        final result = {
          'utsname.machine': infoIos.utsname.machine,
          'isPhysicalDevice': infoIos.isPhysicalDevice,
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

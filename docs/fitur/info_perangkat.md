# Dokumentasi Fitur: info_perangkat

## Daftar file

- [lib/fitur/info_perangkat/enum/arsitektur_apk.dart](../../lib/fitur/info_perangkat/enum/arsitektur_apk.dart)
- [lib/fitur/info_perangkat/model/info_perangkat_model.dart](../../lib/fitur/info_perangkat/model/info_perangkat_model.dart)
- [lib/fitur/info_perangkat/page/info_apk_page_user.dart](../../lib/fitur/info_perangkat/page/info_apk_page_user.dart)
- [lib/fitur/info_perangkat/page/tentang_aplikasi.dart](../../lib/fitur/info_perangkat/page/tentang_aplikasi.dart)
- [lib/fitur/info_perangkat/service/layanan_info_paket.dart](../../lib/fitur/info_perangkat/service/layanan_info_paket.dart)
- [lib/fitur/info_perangkat/service/layanan_info_perangkat.dart](../../lib/fitur/info_perangkat/service/layanan_info_perangkat.dart)

## Isi file

### File: `lib/fitur/info_perangkat/enum/arsitektur_apk.dart`
```dart
// path: lib/fitur/info_perangkat/enum/arsitektur_apk.dart

enum ArsitekturApk { bit32, bit64, universal, x86_64, arm64 }
```

### File: `lib/fitur/info_perangkat/model/info_perangkat_model.dart`
```dart
// path: lib/fitur/info_perangkat/model/info_perangkat_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'info_perangkat_model.freezed.dart';

@freezed
abstract class InfoPerangkatModel with _$InfoPerangkatModel {
  const InfoPerangkatModel._();
  const factory InfoPerangkatModel({
    required String namaApk,
    required String namaPaket,
    required String versi,
    required String nomorBuild,
  }) = _InfoPerangkatModel;

  factory InfoPerangkatModel.fromPackageInfo(PackageInfo info) {
    return InfoPerangkatModel(
      namaApk: info.appName,
      namaPaket: info.packageName,
      versi: info.version,
      nomorBuild: info.buildNumber,
    );
  }
}
```

### File: `lib/fitur/info_perangkat/page/info_apk_page_user.dart`
```dart
// path: lib/fitur/info_perangkat/page/info_apk_page_user.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class InfoApkPageUser extends StatefulWidget {
  const InfoApkPageUser({super.key});

  @override
  State<InfoApkPageUser> createState() => _InfoApkPageUserState();
}

class _InfoApkPageUserState extends State<InfoApkPageUser> {
  String _versi = '...';

  @override
  void initState() {
    super.initState();
    unawaited(_initPackageInfo());
  }

  Future<void> _initPackageInfo() async {
    try {
      final infoPerangkat = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _versi = infoPerangkat.version.split('-').first;
        });
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil info package', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat versi aplikasi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info Aplikasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  showLicensePage(context: context);
                },
                child: const Text('Lihat Lisensi'),
              ),
              const Text(
                'Aplikasi Pelanggan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              gapH8,
              Text(
                'Versi $_versi',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              gapH24,
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/image/ikon_apk.png'),
              ),
              gapH24,
              const Text(
                'Dibuat dengan Flutter',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### File: `lib/fitur/info_perangkat/page/tentang_aplikasi.dart`
```dart
// path lib/fitur/info_perangkat/page/tentang_aplikasi.dart

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

class TentangAplikasiPage extends StatefulWidget {
  const TentangAplikasiPage({super.key});

  @override
  State<TentangAplikasiPage> createState() => _TentangAplikasiPageState();
}

class _TentangAplikasiPageState extends State<TentangAplikasiPage> {
  PackageInfo _infoPerangkat = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  String _minSDK = 'Android 5.0 (Lollipop)';
  String _deviceArch = 'Unknown';

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Tentang Aplikasi');
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    Log.info('Memulai pengambilan informasi aplikasi dan perangkat');

    try {
      Log.info('Mengambil PackageInfo dari platform');
      final infoPerangkat = await PackageInfo.fromPlatform();

      Log.info(
        'PackageInfo berhasil diambil - Nama: ${infoPerangkat.appName}, Versi: ${infoPerangkat.version}, Build: ${infoPerangkat.buildNumber}, Package: ${infoPerangkat.packageName}',
      );

      var deviceArch = 'Unknown';

      if (Platform.isAndroid) {
        Log.info('Platform terdeteksi: Android, mengambil DeviceInfo');
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        deviceArch = androidInfo.supportedAbis.join(', ');
        Log.info(
          'Device info Android berhasil diambil - Arsitektur: $deviceArch, Android Version: ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), Pabrikan: ${androidInfo.manufacturer}, Model: ${androidInfo.model}',
        );
      } else if (Platform.isIOS) {
        Log.info('Platform terdeteksi: iOS');
        deviceArch = 'iOS (arm64)';
      } else {
        Log.info('Platform tidak dikenal: ${Platform.operatingSystem}');
        deviceArch = Platform.operatingSystem;
      }

      setState(() {
        _infoPerangkat = infoPerangkat;
        _deviceArch = deviceArch;
        _minSDK = 'Android 5.0 (Lollipop)';
        Log.info(
          'State diperbarui - MinSDK: $_minSDK, Arsitektur: $_deviceArch',
        );
      });

      Log.info('Proses inisialisasi informasi aplikasi selesai');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil informasi aplikasi atau perangkat',
        e: e,
        s: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman Tentang Aplikasi');
    Log.info(
      'Informasi yang ditampilkan - App: ${_infoPerangkat.appName}, Versi: ${_infoPerangkat.version}, Build: ${_infoPerangkat.buildNumber}',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Kembali ke halaman sebelumnya dari Tentang Aplikasi');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          gapH20,
          const Icon(Icons.wifi_tethering, size: 80, color: Colors.deepPurple),
          gapH20,
          Text(
            _infoPerangkat.appName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          gapH8,
          Text(
            'Versi ${_infoPerangkat.version}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          gapH24,
          const Text(
            'Aplikasi ini membantu Anda mengelola pelanggan dan layanan WiFi dengan lebih mudah. Lacak pembayaran, kelola paket, dan dapatkan notifikasi penting langsung di perangkat Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          gapH32,
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Teknis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow('Nomor Build', _infoPerangkat.buildNumber),
                  _buildInfoRow('Minimal OS', _minSDK),
                  _buildInfoRow('Arsitektur Perangkat', _deviceArch),
                ],
              ),
            ),
          ),
          gapH40,
          const Text(
            '© 2024 Dibuat dengan Penuh Semangat',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          gapH20,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    Log.info('Membangun baris info teknis - $label: $value');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/fitur/info_perangkat/service/layanan_info_paket.dart`
```dart
// path: lib/fitur/info_perangkat/service/layanan_info_paket.dart

import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananInfoPaket {
  LayananInfoPaket() {
    Log.info('LayananInfoPaket diinisialisasi.');
  }

  Future<InfoPerangkatModel?> ambilInfoPaket() async {
    Log.info('Mencoba mengambil info paket aplikasi.');
    try {
      final infoPaket = await PackageInfo.fromPlatform();
      final model = InfoPerangkatModel.fromPackageInfo(infoPaket);
      Log.info('Berhasil mengambil info paket.', {
        'namaAplikasi': model.namaApk,
        'namaPaket': model.namaPaket,
        'versi': model.versi,
        'nomorBuild': model.nomorBuild,
      });
      return model;
    } catch (e, st) {
      Log.error('Gagal mengambil info paket.', e: e, s: st);
      return null;
    }
  }
}
```

### File: `lib/fitur/info_perangkat/service/layanan_info_perangkat.dart`
```dart
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
      return {'error': 'Tidak dapat mendeteksi arsitektur di web.'};
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        Log.info(
          'Platform terdeteksi: Android. Mengambil AndroidDeviceInfo...',
        );
        final infoAndroid = await infoPerangkat.androidInfo;
        final hasilArsitektur = {
          'supportedAbis': infoAndroid.supportedAbis,
          'isPhysicalDevice': infoAndroid.isPhysicalDevice,
        };
        Log.info('Informasi Android berhasil didapatkan:', hasilArsitektur);
        return hasilArsitektur;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        Log.info('Platform terdeteksi: iOS. Mengambil IosDeviceInfo...');
        final infoIos = await infoPerangkat.iosInfo;
        final result = {
          'utsname.machine': infoIos.utsname.machine,
          'isPhysicalDevice': infoIos.isPhysicalDevice,
        };
        Log.info('Informasi iOS berhasil didapatkan:', result);
        return result;
      }
    } catch (e, s) {
      Log.error('Gagal mendapatkan info perangkat.', e: e, s: s);
      return {'error': 'Gagal mendapatkan info perangkat: $e'};
    }
    Log.warning('Platform tidak didukung oleh DeviceInfoService.');
    return {'error': 'Platform tidak didukung'};
  }
}
```


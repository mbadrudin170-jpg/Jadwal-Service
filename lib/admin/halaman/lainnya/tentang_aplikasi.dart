// path: lib/halaman/lainnya/tentang_aplikasi.dart

// File ini bertanggung jawab untuk menampilkan informasi tentang aplikasi,
// seperti versi, nama, dan deskripsi singkat.

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wifi/shared/debug/log.dart';

/// Halaman yang menampilkan detail tentang aplikasi, seperti versi, build, dan informasi teknis lainnya.
class TentangAplikasiPage extends StatefulWidget {
  /// Membuat instance dari [TentangAplikasiPage].
  const TentangAplikasiPage({super.key});

  @override
  State<TentangAplikasiPage> createState() => _TentangAplikasiPageState();
}

class _TentangAplikasiPageState extends State<TentangAplikasiPage> {
  // Informasi paket aplikasi akan disimpan di sini.
  PackageInfo _packageInfo = PackageInfo(
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
    unawaited(_initInfo());
  }

  Future<void> _initInfo() async {
    Log.info('Memulai pengambilan informasi aplikasi dan perangkat');

    try {
      Log.info('Mengambil PackageInfo dari platform');
      final packageInfo = await PackageInfo.fromPlatform();

      Log.info(
        'PackageInfo berhasil diambil - Nama: ${packageInfo.appName}, Versi: ${packageInfo.version}, Build: ${packageInfo.buildNumber}, Package: ${packageInfo.packageName}',
      );

      String deviceArch = 'Unknown';

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
        _packageInfo = packageInfo;
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
        st: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI halaman Tentang Aplikasi');
    Log.info(
      'Informasi yang ditampilkan - App: ${_packageInfo.appName}, Versi: ${_packageInfo.version}, Build: ${_packageInfo.buildNumber}',
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
          const SizedBox(height: 20),
          const Icon(Icons.wifi_tethering, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          Text(
            _packageInfo.appName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Versi ${_packageInfo.version}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Aplikasi ini membantu Anda mengelola pelanggan dan layanan WiFi dengan lebih mudah. Lacak pembayaran, kelola paket, dan dapatkan notifikasi penting langsung di perangkat Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
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
                  _buildInfoRow('Nomor Build', _packageInfo.buildNumber),
                  _buildInfoRow('Minimal OS', _minSDK),
                  _buildInfoRow('Arsitektur Perangkat', _deviceArch),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            '© 2024 Dibuat dengan Penuh Semangat',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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

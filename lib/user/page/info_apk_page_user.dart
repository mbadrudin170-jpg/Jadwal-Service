// path: lib/user/page/info_apk_page_user.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Halaman yang menampilkan informasi tentang aplikasi.
///
/// Menampilkan nama aplikasi, versi, dan deskripsi singkat.
class InfoApkPage extends StatefulWidget {
  /// Membuat instance dari [InfoApkPage].
  const InfoApkPage({super.key});

  @override
  State<InfoApkPage> createState() => _InfoApkPageState();
}

class _InfoApkPageState extends State<InfoApkPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    // diubah: Menggunakan unawaited untuk menangani future di initState.
    unawaited(_getVersion());
  }

  Future<void> _getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    // ditambah: Memeriksa apakah widget masih terpasang sebelum memanggil setState.
    if (mounted) {
      setState(() {
        _version = packageInfo.version.split('-').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Aplikasi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aplikasi Pelanggan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Versi $_version', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi ini dibuat untuk memudahkan pelanggan dalam mengelola langganan dan mendapatkan informasi terbaru.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

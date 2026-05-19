// path: lib/user/maintenance_page.dart
// diubah: Mengubah menjadi StatefulWidget untuk menangani state loading pada tombol refresh.
// diubah: Menggunakan ikon terpusat dari AppIcons.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman yang ditampilkan saat aplikasi dalam mode pemeliharaan (maintenance).
///
/// Menampilkan informasi pemeliharaan, tombol untuk mencoba lagi (refresh),
/// dan tombol untuk keluar dari aplikasi.
class MaintenancePage extends StatefulWidget {
  /// Informasi teks yang menjelaskan status pemeliharaan.
  final String maintenanceInfo;

  /// Callback asinkron yang dipanggil saat pengguna menekan tombol "Coba Lagi".
  /// Diharapkan mengembalikan Future agar state loading bisa dikelola.
  final FutureOr<void> Function() onRefresh;

  /// Callback yang dipanggil saat pengguna menekan tombol "Keluar".
  final VoidCallback onExit;

  /// Membuat instance dari [MaintenancePage].
  const MaintenancePage({
    super.key,
    required this.maintenanceInfo,
    required this.onRefresh,
    required this.onExit,
  });

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  bool _isLoading = false;

  /// Menangani aksi refresh saat tombol "Coba Lagi" ditekan.
  Future<void> _handleRefresh() async {
    if (_isLoading) return;

    Log.info('[Aksi Pengguna] Tombol "Coba Lagi" ditekan.');
    setState(() {
      _isLoading = true;
    });

    try {
      // Menjalankan fungsi refresh dari parent widget.
      await widget.onRefresh();
      Log.info('[Aksi Pengguna] Proses onRefresh selesai.');
    } on Exception catch (e, st) {
      Log.error('Error selama callback onRefresh', e: e, st: st);
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal menyegarkan data: $e');
      }
    } finally {
      // Pastikan widget masih ada di tree sebelum memanggil setState.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      '[Build UI] Membangun MaintenancePage dengan info: "${widget.maintenanceInfo}"',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi dalam Perbaikan'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                AppIcons.warningAmber, // Menggunakan AppIcons
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Pemberitahuan Pemeliharaan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.maintenanceInfo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleRefresh,
                icon: _isLoading
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(AppIcons.refresh), // Menggunakan AppIcons
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Log.info('[Aksi Pengguna] Tombol "Keluar" ditekan.');
                  widget.onExit();
                },
                icon: const Icon(AppIcons.logout), // Menggunakan AppIcons
                label: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

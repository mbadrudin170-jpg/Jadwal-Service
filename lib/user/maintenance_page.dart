// path: lib/user/maintenance_page.dart
// ditambah: Menambahkan tombol Coba Lagi (refresh) dan Keluar.
// ditambah: Menambahkan Log untuk interaksi pengguna dan event build.
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart'; // ditambah: Impor Log

/// Halaman yang ditampilkan saat aplikasi dalam mode pemeliharaan (maintenance).
///
/// Menampilkan informasi pemeliharaan, tombol untuk mencoba lagi (refresh),
/// dan tombol untuk keluar dari aplikasi.
class MaintenancePage extends StatelessWidget {
  /// Informasi teks yang menjelaskan status pemeliharaan.
  final String maintenanceInfo;

  /// Callback yang dipanggil saat pengguna menekan tombol "Coba Lagi".
  final VoidCallback onRefresh;

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
  Widget build(BuildContext context) {
    // ditambah: Log saat halaman ini dibangun.
    Log.info(
      '[Build UI]  membangun MaintenancePage dengan info: "$maintenanceInfo"',
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
                Icons.warning_amber_rounded,
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
                maintenanceInfo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                // ditambah: Menambahkan log pada saat tombol ditekan.
                onPressed: () {
                  Log.info('[Aksi Pengguna] Tombol "Coba Lagi" ditekan.');
                  onRefresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                // ditambah: Menambahkan log pada saat tombol ditekan.
                onPressed: () {
                  Log.info('[Aksi Pengguna] Tombol "Keluar" ditekan.');
                  onExit();
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

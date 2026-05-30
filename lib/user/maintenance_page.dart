// path: lib/user/maintenance_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart'; // Impor AppSizes
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman yang ditampilkan saat aplikasi dalam mode pemeliharaan (maintenance).
class MaintenancePage extends StatefulWidget {
  final String maintenanceInfo;
  final FutureOr<void> Function() onRefresh;
  final VoidCallback onExit;

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

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    Log.info('[Init] MaintenancePage diinisialisasi.');
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;

    Log.info('[Aksi Pengguna] Tombol "Coba Lagi" ditekan.');
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onRefresh();
      Log.info('[Aksi Pengguna] Proses onRefresh selesai.');
    } on Exception catch (e, st) {
      Log.error('Error selama callback onRefresh', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyegarkan data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      '[Build UI] Membangun MaintenancePage dengan info: "${widget.maintenanceInfo}"',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi dalam Perbaikan'),
        automaticallyImplyLeading: false,
      ),
      body: _MaintenanceContent(
        maintenanceInfo: widget.maintenanceInfo,
        isLoading: _isLoading,
        onRefresh: _handleRefresh,
        onExit: widget.onExit,
      ),
    );
  }
}

/// Widget private yang bertanggung jawab untuk menampilkan konten UI halaman maintenance.
class _MaintenanceContent extends StatelessWidget {
  final String maintenanceInfo;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onExit;

  const _MaintenanceContent({
    required this.maintenanceInfo,
    required this.isLoading,
    required this.onRefresh,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Widget refreshButtonIcon = isLoading
        ? Container(
            width: 24, // Nilai ini spesifik untuk ukuran ikon, jadi tetap
            height: 24,
            padding: const EdgeInsets.all(
                2.0), // Padding kecil untuk alignment indicator
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
        : const Icon(TIcons.refresh);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.p20), // Menggunakan TSizes
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              TIcons.warningAmber,
              size: 80,
              color: Colors.orange,
            ),
            gapH24, // Menggunakan gapH
            Text(
              'Pemberitahuan Pemeliharaan',
              style: textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            gapH16, // Menggunakan gapH
            Text(
              maintenanceInfo,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            gapH32, // Menggunakan gapH
            ElevatedButton.icon(
              onPressed: isLoading ? null : onRefresh,
              icon: refreshButtonIcon,
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.p32, // Menggunakan TSizes
                  vertical: TSizes.p16, // Menggunakan TSizes
                ),
                textStyle: textTheme.titleMedium,
              ),
            ),
            gapH12, // Menggunakan gapH
            TextButton.icon(
              onPressed: () {
                Log.info('[Aksi Pengguna] Tombol "Keluar" ditekan.');
                onExit();
              },
              icon: const Icon(TIcons.logout),
              label: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}

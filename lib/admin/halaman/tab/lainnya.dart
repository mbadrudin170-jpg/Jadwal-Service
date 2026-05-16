// path: lib/admin/halaman/tab/lainnya.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai tab "Lainnya" di navigasi admin.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/lainnya/admin_settings.dart (SettingsAdminPage)
//   - lib/admin/halaman/lainnya/apk_version_page.dart (ApkVersionPage)
//   - lib/admin/halaman/lainnya/category.dart (CategoryPage)
//   - lib/admin/halaman/lainnya/customer.dart (CustomerPage)
//   - lib/admin/halaman/lainnya/feedback.dart (FeedbackPage)
//   - lib/admin/halaman/lainnya/halaman_migrasi.dart (HalamanMigrasi)
//   - lib/admin/halaman/lainnya/package.dart (PackagePage)
//   - lib/admin/halaman/lainnya/package_activation_history.dart (PackageActivationHistoryPage)
//   - lib/admin/halaman/lainnya/tentang_aplikasi.dart (TentangAplikasiPage)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/admin/halaman/lainnya/admin_settings.dart';
import 'package:wifi/admin/halaman/lainnya/apk_version_page.dart';
import 'package:wifi/admin/halaman/lainnya/category.dart';
import 'package:wifi/admin/halaman/lainnya/customer.dart';
import 'package:wifi/admin/halaman/lainnya/feedback.dart';
import 'package:wifi/admin/halaman/lainnya/halaman_migrasi.dart';
import 'package:wifi/admin/halaman/lainnya/package.dart';
import 'package:wifi/admin/halaman/lainnya/package_activation_history.dart';
import 'package:wifi/admin/halaman/lainnya/tentang_aplikasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman untuk menampilkan menu-menu lain yang tersedia untuk admin.
class LainnyaPage extends StatefulWidget {
  /// Konstruktor untuk LainnyaPage.
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
  /// Menampilkan dialog konfirmasi sebelum keluar dari aplikasi.
  Future<void> _showLogoutConfirmationDialog() async {
    Log.info('Menampilkan dialog konfirmasi keluar.');
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Log.info('Pengguna membatalkan aksi keluar.');
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Keluar'),
              onPressed: () {
                Log.info('Pengguna mengkonfirmasi aksi keluar.');
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldLogout ?? false) {
      Log.info('Keluar dari aplikasi.');
      await SystemNavigator.pop();
    }
  }

  Future<void> _navigateTo(final Widget page, final String pageName) async {
    Log.info('Navigasi ke halaman $pageName.');
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (final context) => page),
      );
      Log.info('Kembali dari halaman $pageName.');
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke halaman $pageName.', e: e, st: st);
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal membuka halaman $pageName.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun halaman Lainnya untuk admin.');
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Lainnya')),
      body: ListView(
        children: [
          _buildMenuItem(
            context: context,
            icon: Icons.people,
            title: 'Data Pelanggan',
            onTap: () => _navigateTo(const CustomerPage(), 'Data Pelanggan'),
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.wifi,
            title: 'Data Paket',
            onTap: () => _navigateTo(const PackagePage(), 'Data Paket'),
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.category,
            title: 'Data Kategori',
            onTap: () => _navigateTo(const CategoryPage(), 'Data Kategori'),
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.history,
            title: 'Riwayat Langganan',
            onTap: () => _navigateTo(
                const PackageActivationHistoryPage(), 'Riwayat Langganan'),
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.cloud_upload,
            title: 'Versi APK User',
            onTap: () => _navigateTo(const ApkVersionPage(), 'Versi APK User'),
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.feedback,
            title: 'Kritik dan Saran',
            onTap: () => _navigateTo(const FeedbackPage(), 'Kritik dan Saran'),
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.storage,
            title: 'Migrasi Database',
            onTap: () =>
                _navigateTo(const HalamanMigrasi(), 'Migrasi Database'),
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () => _navigateTo(const SettingsAdminPage(), 'Pengaturan'),
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            onTap: () =>
                _navigateTo(const TentangAplikasiPage(), 'Tentang Aplikasi'),
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.exit_to_app,
            title: 'Keluar',
            onTap: () async {
              Log.info('Tombol Keluar ditekan.');
              await _showLogoutConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required final BuildContext context,
    required final IconData icon,
    required final String title,
    required final VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

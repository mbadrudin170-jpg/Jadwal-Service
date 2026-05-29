// path: lib/admin/halaman/tab/lainnya.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/admin/halaman/lainnya/apk_version_page.dart';
import 'package:wifi/admin/halaman/lainnya/category.dart';
import 'package:wifi/admin/halaman/lainnya/customer.dart';
import 'package:wifi/admin/halaman/lainnya/feedback.dart';
import 'package:wifi/admin/halaman/lainnya/package.dart';
import 'package:wifi/admin/halaman/lainnya/package_activation_history.dart';
import 'package:wifi/admin/halaman/lainnya/settings_page_a.dart';
import 'package:wifi/admin/halaman/lainnya/tentang_aplikasi.dart';
import 'package:wifi/screens/update_check_screen.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';

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
    Log.info('Tombol $pageName ditekan');
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (final context) => page),
      );
      Log.info('Kembali dari halaman $pageName.');
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke halaman $pageName.', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal membuka halaman $pageName.');
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
            icon: AppIcons.customers,
            title: 'Data Pelanggan',
            onTap: () => _navigateTo(const CustomerPage(), 'Data Pelanggan'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.filter,
            title: 'Kategori',
            onTap: () => _navigateTo(const CategoryPage(), 'Kategori'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.packages,
            title: 'Paket',
            onTap: () => _navigateTo(const PackagePage(), 'Paket'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.clock,
            title: 'Riwayat Aktivasi Paket',
            onTap: () => _navigateTo(
                const PackageActivationHistoryPage(), 'Riwayat Aktivasi Paket'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.help,
            title: 'Kritik dan Saran',
            onTap: () => _navigateTo(const FeedbackPage(), 'Kritik dan Saran'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.report,
            title: 'Versi Aplikasi',
            onTap: () => _navigateTo(const ApkVersionPage(), 'Versi Aplikasi'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.settings,
            title: 'Pengaturan',
            onTap: () => _navigateTo(const SettingsAdminPage(), 'Pengaturan'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.info,
            title: 'Tentang Aplikasi',
            onTap: () =>
                _navigateTo(const TentangAplikasiPage(), 'Tentang Aplikasi'),
          ),
          _buildMenuItem(
            context: context,
            icon: AppIcons.logout,
            title: 'Keluar',
            onTap: _showLogoutConfirmationDialog,
          ),
          if (kDebugMode)
            _buildMenuItem(
              context: context,
              icon: AppIcons.info,
              title: 'Halaman Tes',
              onTap: () =>
                  _navigateTo(const UpdateCheckScreen(), 'Halaman Tes'),
            ),
        ],
      ),
    );
  }

  /// Membangun satu item menu dalam daftar.
  Widget _buildMenuItem({
    required final BuildContext context,
    required final IconData icon,
    required final String title,
    required final VoidCallback onTap,
  }) {
    // Ambil textTheme dari context.
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon),
      // Terapkan gaya teks dari tema untuk konsistensi.
      title: Text(title, style: textTheme.titleMedium),
      onTap: onTap,
    );
  }
}

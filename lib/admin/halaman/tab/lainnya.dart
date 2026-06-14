// path: lib/admin/halaman/tab/lainnya.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/admin/halaman/lainnya/apk_version_page.dart';
import 'package:wifi/admin/halaman/lainnya/kategori.dart';
import 'package:wifi/admin/halaman/lainnya/event_page_a.dart';
import 'package:wifi/admin/halaman/lainnya/paket.dart';
import 'package:wifi/admin/halaman/lainnya/riwayat_aktivasi_paket.dart';
import 'package:wifi/admin/halaman/lainnya/settings_page_a.dart';
import 'package:wifi/admin/halaman/lainnya/tentang_aplikasi.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/data_dummy/halaman_data_dummy.dart';
import 'package:wifi/fitur/feedback/page/feedback_page_a.dart';
import 'package:wifi/fitur/pelanggan/ui/admin/pelanggan.dart';
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
      Log.error('Gagal navigasi ke halaman $pageName.', e: e, s: st);
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
            icon: TIcons.customers,
            title: 'Data Pelanggan',
            onTap: () => _navigateTo(const Pelanggan(), 'Data Pelanggan'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.filter,
            title: 'Kategori',
            onTap: () => _navigateTo(const CategoryPage(), 'Kategori'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.packages,
            title: 'Paket',
            onTap: () => _navigateTo(const PackagePage(), 'Paket'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.clock,
            title: 'Riwayat Aktivasi Paket',
            onTap: () => _navigateTo(
                const RiwayatAktivasiPaket(), 'Riwayat Aktivasi Paket'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.help,
            title: 'Kritik dan Saran',
            onTap: () => _navigateTo(const FeedbackPage(), 'Kritik dan Saran'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.report,
            title: 'Versi Aplikasi',
            onTap: () => _navigateTo(const ApkVersionPage(), 'Versi Aplikasi'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.settings,
            title: 'Pengaturan',
            onTap: () => _navigateTo(const SettingsAdminPage(), 'Pengaturan'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.info,
            title: 'Tentang Aplikasi',
            onTap: () =>
                _navigateTo(const TentangAplikasiPage(), 'Tentang Aplikasi'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.event,
            title: 'Halaman Pengumuman',
            onTap: () => _navigateTo(const EventPageA(), 'Halaman Pengumuman'),
          ),
          _buildMenuItem(
            context: context,
            icon: TIcons.logout,
            title: 'Keluar',
            onTap: _showLogoutConfirmationDialog,
          ),
          if (kDebugMode)
            _buildMenuItem(
              context: context,
              icon: TIcons.science,
              title: 'Halaman Tes',
              onTap: () => _navigateTo(const HalamanTes(), 'Halaman Tes'),
            ),
          if (kDebugMode)
            _buildMenuItem(
              context: context,
              icon: TIcons.activeCustomer,
              title: 'halamana tambah data dummy',
              onTap: () => _navigateTo(const HalamanDataDummy(), 'Halaman Tes'),
            )
        ],
      ),
    );
  }

  /// Membangun satu item menu dalam daftar.
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    IconData? rightIcons,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: textTheme.titleMedium),
      trailing: Icon(rightIcons ?? TIcons.chevronRight),
      onTap: onTap,
    );
  }
}

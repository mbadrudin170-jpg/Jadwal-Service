// path: lib/admin/halaman/tab/lainnya.dart
// Fitur: Lainnya (Admin)
// Tujuan: Menampilkan menu-menu lain yang tersedia untuk admin.
// diubah: Menambahkan menu Keluar dan dialog konfirmasi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/admin/halaman/lainnya/halaman_migrasi.dart';
import 'package:wifi/admin/halaman/lainnya/kategori.dart';
import 'package:wifi/admin/halaman/lainnya/kritik_saran.dart';
import 'package:wifi/admin/halaman/lainnya/paket.dart';
import 'package:wifi/admin/halaman/lainnya/pelanggan.dart';
import 'package:wifi/admin/halaman/lainnya/pengaturan_admin.dart';
import 'package:wifi/admin/halaman/lainnya/riwayat_aktivasi_paket.dart';
import 'package:wifi/admin/halaman/lainnya/tentang_aplikasi.dart';
import 'package:wifi/admin/halaman/lainnya/apk_version_page.dart';
import 'package:wifi/shared/debug/log.dart';

/// Halaman untuk menampilkan menu-menu lain yang tersedia untuk admin.
class LainnyaPage extends StatefulWidget {
  /// Membuat instance dari [LainnyaPage].
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
  // ditambah: Method untuk menampilkan dialog konfirmasi keluar.
  Future<void> _showLogoutConfirmationDialog() async {
    Log.info('Menampilkan dialog konfirmasi keluar.');
    // ditambah: Menggunakan await untuk menunggu hasil dari dialog.
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

    // ditambah: Memeriksa hasil dialog sebelum keluar dari aplikasi.
    if (shouldLogout ?? false) {
      Log.info('Keluar dari aplikasi.');
      // Keluar dari aplikasi.
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun halaman Lainnya untuk admin.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Lainnya'),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context: context,
            icon: Icons.people,
            title: 'Data Pelanggan',
            onTap: () async {
              Log.info('Navigasi ke halaman Data Pelanggan.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const PelangganPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.wifi,
            title: 'Data Paket',
            onTap: () async {
              Log.info('Navigasi ke halaman Data Paket.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const PaketPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.category,
            title: 'Data Kategori',
            onTap: () async {
              Log.info('Navigasi ke halaman Data Kategori.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const KategoriPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.history,
            title: 'Riwayat Langganan',
            onTap: () async {
              Log.info('Navigasi ke halaman Riwayat Aktivasi Paket.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const RiwayatAktivasiPaketPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.cloud_upload,
            title: 'Versi APK User',
            onTap: () async {
              Log.info('Navigasi ke halaman Versi APK User.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const VersiApkUserPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.feedback,
            title: 'Kritik dan Saran',
            onTap: () async {
              Log.info('Navigasi ke halaman Kritik dan Saran.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const KritikSaranPage(),
                ),
              );
            },
          ),
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.storage,
            title: 'Migrasi Database',
            onTap: () async {
              Log.info('Navigasi ke halaman Migrasi Database.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const HalamanMigrasi(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.settings,
            title: 'Pengaturan',
            onTap: () async {
              Log.info('Navigasi ke halaman Pengaturan Admin.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const PengaturanAdmin(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            onTap: () async {
              Log.info('Navigasi ke halaman Tentang Aplikasi.');
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const TentangAplikasiPage(),
                ),
              );
            },
          ),
          // ditambah: Menu untuk keluar dari aplikasi
          const Divider(),
          _buildMenuItem(
            context: context,
            icon: Icons.exit_to_app,
            title: 'Keluar',
            onTap: () async => await _showLogoutConfirmationDialog(), // diubah: Memanggil dialog konfirmasi
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

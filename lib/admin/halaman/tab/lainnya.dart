// path: lib/admin/halaman/tab/lainnya.dart
// diubah: Memperbaiki impor agar mengarah ke halaman pengaturan admin yang benar.
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/lainnya/kategori.dart';
import 'package:wifi/admin/halaman/lainnya/kritik_saran.dart';
import 'package:wifi/admin/halaman/lainnya/paket.dart';
import 'package:wifi/admin/halaman/lainnya/pelanggan.dart';
import 'package:wifi/admin/halaman/lainnya/riwayat_aktivasi_paket.dart';
import 'package:wifi/admin/halaman/lainnya/tentang_aplikasi.dart';
import 'package:wifi/admin/halaman/lainnya/versi_apk_user.dart';
import 'package:wifi/admin/halaman/tab/pesanan.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/admin/halaman/lainnya/pengaturan_admin.dart'; // diubah: Path impor diperbaiki
import 'package:wifi/admin/halaman/lainnya/halaman_migrasi.dart';

class LainnyaPage extends StatefulWidget {
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaTabState();
}

class _LainnyaTabState extends State<LainnyaPage> {
  // Fungsi bantuan untuk membuat tombol navigasi
  Widget _buildNavigationButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _handleNavigation(String pageName, Widget page) {
    Log.info('Navigasi ke halaman: $pageName');
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk Halaman Lainnya.');
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan & Lainnya')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavigationButton(
            title: 'Daftar Pesanan',
            icon: Icons.shopping_cart,
            onTap: () =>
                _handleNavigation('Daftar Pesanan', const HalamanPesan()),
          ),
          _buildNavigationButton(
            title: 'Kelola Kategori',
            icon: Icons.category,
            onTap: () =>
                _handleNavigation('Kelola Kategori', const KategoriPage()),
          ),
          _buildNavigationButton(
            title: 'Kritik & Saran',
            icon: Icons.feedback,
            onTap: () async {
              Log.info('Memulai proses untuk membuka halaman Kritik & Saran.');
              final navigator = Navigator.of(context);

              Log.info('Mengunduh data Kritik & Saran dari Firebase.');
              final dataFromFirebase =
                  await KritikSaranOperasi.unduhDataDariFirebase();
              Log.info('Berhasil mengunduh ${dataFromFirebase.length} data.');

              if (dataFromFirebase.isNotEmpty) {
                final operasi = KritikSaranOperasi();
                Log.info('Menyimpan/Memperbarui data ke database lokal.');
                await operasi.sisipkanAtauPerbaruiBatch(dataFromFirebase);
                Log.info('Data berhasil disimpan/diperbarui.');
              }

              if (!mounted) return;
              await navigator.push(
                MaterialPageRoute(
                  builder: (context) => const KritikSaranPage(),
                ),
              );
            },
          ),
          _buildNavigationButton(
            title: 'Kelola Paket WiFi',
            icon: Icons.wifi,
            onTap: () =>
                _handleNavigation('Kelola Paket WiFi', const PaketPage()),
          ),
          _buildNavigationButton(
            title: 'Daftar Pelanggan',
            icon: Icons.people,
            onTap: () =>
                _handleNavigation('Daftar Pelanggan', const PelangganPage()),
          ),
          _buildNavigationButton(
            title: 'Riwayat Aktivasi Paket',
            icon: Icons.history,
            onTap: () => _handleNavigation(
              'Riwayat Aktivasi Paket',
              const RiwayatAktivasiPaketPage(),
            ),
          ),
          _buildNavigationButton(
            title: 'Versi Aplikasi Pengguna',
            icon: Icons.system_update,
            onTap: () => _handleNavigation(
              'Versi Aplikasi Pengguna',
              const VersiApkUserPage(),
            ),
          ),
          _buildNavigationButton(
            title: 'Pengaturan Aplikasi',
            icon: Icons.settings,
            onTap: () => _handleNavigation(
              'Pengaturan Aplikasi',
              const PengaturanPage(),
            ),
          ),
          _buildNavigationButton(
            title: 'Tentang Aplikasi',
            icon: Icons.info,
            onTap: () => _handleNavigation(
              'Tentang Aplikasi',
              const TentangAplikasiPage(),
            ),
          ),
          // ditambahkan: Navigasi ke halaman migrasi
          const Divider(height: 32),
          _buildNavigationButton(
            title: '[DEBUG] Alat Migrasi Data',
            icon: Icons.construction,
            onTap: () =>
                _handleNavigation('Alat Migrasi Data', const HalamanMigrasi()),
          ),
        ],
      ),
    );
  }
}

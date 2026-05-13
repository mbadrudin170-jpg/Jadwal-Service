// path: lib/user/page/pengaturan_user.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/page/daftar_akun_page.dart';
import 'package:wifi/user/page/info_apk_page_user.dart';
import 'package:wifi/user/page/kritik_dan_saran_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

class PengaturanPageUser extends StatelessWidget {
  final String userId;
  final LocalStorageService localStorageService;

  const PengaturanPageUser(
      {super.key, required this.userId, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    Log.info('[Build UI] ✅ Membangun halaman PengaturanPage.');
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
        ),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          // FIX: Membungkus ThemeMenuWidget dengan Row(mainAxisSize: MainAxisSize.min)
          // untuk mengatasi error RenderBox.
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema Aplikasi'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeMenuWidget(),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Kritik dan Saran'),
            onTap: () {
              Log.info(
                  '[Navigasi] 🚀 Menavigasi ke halaman RiwayatKritikDanSaranPage.');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RiwayatKritikDanSaranPage(userId: userId),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Info Aplikasi & Perangkat'),
            onTap: () {
              Log.info('[Navigasi] 🚀 Menavigasi ke halaman InfoApkPage.');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InfoApkPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: colorScheme.error,
            ),
            title: Text(
              'Ganti Akun/Keluar',
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Log.info(
                  '[Navigasi] 🚀 Menavigasi ke halaman DaftarAkunPage (untuk ganti akun).');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DaftarAkunPage(
                        localStorageService: localStorageService)),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

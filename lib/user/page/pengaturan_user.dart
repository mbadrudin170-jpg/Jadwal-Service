// path: lib/user/page/pengaturan_user.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/user/page/daftar_akun_page.dart';
import 'package:wifi/user/page/info_apk_page.dart';
import 'package:wifi/user/page/kritik_dan_saran.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

class PengaturanPage extends StatelessWidget {
  final String userId;
  final LocalStorageService localStorageService;

  const PengaturanPage(
      {super.key, required this.userId, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    log('[Build UI] ✅ Membangun halaman PengaturanPage.',
        name: 'pengaturan_page.dart');
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white),
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
              log('[Navigasi] 🚀 Menavigasi ke halaman RiwayatKritikDanSaranPage.',
                  name: 'pengaturan_page.dart');
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
              log('[Navigasi] 🚀 Menavigasi ke halaman InfoApkPage.',
                  name: 'pengaturan_page.dart');
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
              log('[Navigasi] 🚀 Menavigasi ke halaman DaftarAkunPage (untuk ganti akun).',
                  name: 'pengaturan_page.dart');
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

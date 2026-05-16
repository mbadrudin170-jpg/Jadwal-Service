// path: lib/user/page/settings_page_user.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/user/page/main_page.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/user/page/account_list_page.dart (AccountListPage)
//   - lib/user/page/feedback_history_user.dart (FeedbackHistoryPage)
//   - lib/user/page/info_apk_page_user.dart (InfoApkPage)
//   - lib/user/widget/theme_menu_widget.dart (ThemeMenuWidget)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/page/account_list_page.dart';
import 'package:wifi/user/page/feedback_history_user.dart';
import 'package:wifi/user/page/info_apk_page_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

/// Halaman pengaturan untuk pengguna.
///
/// Menyediakan akses ke berbagai fitur pengaturan seperti tema, masukan,
/// dan informasi aplikasi.
class SettingsPageUser extends StatelessWidget {
  /// ID unik pengguna yang sedang login.
  final String userId;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Konstruktor untuk [SettingsPageUser].
  const SettingsPageUser({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun halaman pengaturan untuk pengguna: $userId');
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          const ListTile(
            leading: Icon(Icons.brightness_6_outlined),
            title: Text('Tema Aplikasi'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [ThemeMenuWidget()],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Kritik dan Saran'),
            onTap: () async {
              Log.info('Navigasi ke halaman riwayat masukan.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) =>
                      FeedbackHistoryPage(userId: userId),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Info Aplikasi & Perangkat'),
            onTap: () async {
              Log.info('Navigasi ke halaman info aplikasi.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const InfoApkPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text('Ganti Akun/Keluar',
                style: TextStyle(color: colorScheme.error)),
            onTap: () async {
              Log.info('Navigasi ke halaman daftar akun untuk ganti akun.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => AccountListPage(
                    localStorageService: localStorageService,
                  ),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

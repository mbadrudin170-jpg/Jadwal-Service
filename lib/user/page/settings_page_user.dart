// path: lib/user/page/settings_page_user.dart
// diubah: Menambahkan tombol navigasi ke Halaman Tes hanya dalam mode debug.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/page/account_list_page.dart';
import 'package:wifi/user/page/feedback_history_user.dart';
import 'package:wifi/user/page/info_apk_page_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';
import 'package:flutter/foundation.dart';

/// Halaman pengaturan untuk pengguna.
class SettingsPageUser extends StatelessWidget {
  final String userId;
  final LocalStorageService localStorageService;

  const SettingsPageUser({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun halaman pengaturan untuk pengguna: $userId');

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          _SettingsMenuItem(
            icon: AppIcons.theme,
            title: 'Tema Aplikasi',
            trailing: Consumer<ThemeProvider>(
              builder: (final context, final themeProvider, final child) {
                return ThemeMenuWidget(
                  currentThemeMode: themeProvider.themeMode,
                  onThemeSelected: (final mode) {
                    unawaited(themeProvider.setTheme(mode));
                  },
                );
              },
            ),
          ),
          _SettingsMenuItem(
            icon: AppIcons.feedback,
            title: 'Kritik dan Saran',
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
          _SettingsMenuItem(
            icon: AppIcons.infoOutlined,
            title: 'Info Aplikasi & Perangkat',
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
          // Hanya tampilkan tombol ini dalam mode debug
          if (kDebugMode)
            _SettingsMenuItem(
              icon: AppIcons.science,
              title: 'Halaman Uji Fitur',
              onTap: () async {
                Log.info('Navigasi ke halaman tes fitur.');
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (final context) => const HalamanTes(),
                  ),
                );
              },
            ),
          _SettingsMenuItem(
            icon: AppIcons.logout,
            title: 'Ganti Akun/Keluar',
            isDestructive: true,
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
        ],
      ),
    );
  }
}

/// Widget kustom untuk item menu di halaman pengaturan.
class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : null;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color)),
          trailing: trailing,
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}

// path: lib/user/page/settings_page_user.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/feedback/page/feedback_page_u.dart';
import 'package:wifi/fitur/info_perangkat/page/info_apk_page_user.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

/// Halaman pengaturan untuk pengguna.
class SettingsPageU extends ConsumerWidget {
  const SettingsPageU({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
        children: <Widget>[
          _SettingsMenuItem(
            icon: TIcons.theme,
            title: 'Tema Aplikasi',
            trailing: Consumer(
              builder: (context, ref, child) {
                final themeAsync = ref.watch(temaProvider);
                return themeAsync.when(
                  data: (themeMode) => ThemeMenuWidget(
                    currentThemeMode: themeMode,
                    onThemeSelected: (mode) {
                      unawaited(
                        ref.read(temaProvider.notifier).simpanModeTema(mode),
                      );
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const Icon(TIcons.error),
                );
              },
            ),
          ),
          _SettingsMenuItem(
            icon: TIcons.feedback,
            title: 'Kritik dan Saran',
            onTap: () async {
              Log.info('Navigasi ke halaman riwayat masukan.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const FeedbackPageU(),
                ),
              );
            },
          ),
          _SettingsMenuItem(
            icon: TIcons.infoOutlined,
            title: 'Info Aplikasi & Perangkat',
            onTap: () async {
              Log.info('Navigasi ke halaman info aplikasi.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const InfoApkPageUser(),
                ),
              );
            },
          ),
          // Hanya tampilkan tombol ini dalam mode debug
          if (kDebugMode)
            _SettingsMenuItem(
              icon: TIcons.science,
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
            icon: TIcons.logout,
            title: 'Ganti Akun/Keluar',
            isDestructive: true,
            onTap: () async {
              Log.info('Navigasi ke halaman daftar akun untuk ganti akun.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const DaftarAkunPage(),
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
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : null;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color)),
          trailing: trailing,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 4,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}

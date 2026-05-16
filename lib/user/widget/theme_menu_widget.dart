// path: lib/user/widget/theme_menu_widget.dart
// diubah: Import langsung ke shared/theme/theme_provider.dart (global),
//         gunakan Provider.of, pindahkan getCurrentIcon ke method.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/theme_provider.dart';

/// Widget untuk menampilkan menu pilihan tema.
///
/// Menampilkan PopupMenuButton yang memungkinkan pengguna memilih
/// antara tema terang, gelap, atau otomatis (mengikuti sistem).
///
/// Digunakan oleh: Layar pengaturan atau app bar di sisi user.
class ThemeMenuWidget extends StatelessWidget {
  /// Membuat instance dari [ThemeMenuWidget].
  const ThemeMenuWidget({super.key});

  /// Mengembalikan ikon yang sesuai dengan [mode] tema.
  IconData _getCurrentIcon(final ThemeMode mode) {
    Log.info(
      '[Eksekusi Fungsi] ✅ Menjalankan _getCurrentIcon untuk tema: $mode.',
    );
    switch (mode) {
      case ThemeMode.light:
        Log.info(
          '[Pilihan Tema] ✅ Tema Terang, mengembalikan ikon light_mode.',
        );
        return Icons.light_mode;
      case ThemeMode.dark:
        Log.info(
          '[Pilihan Tema] ✅ Tema Gelap, mengembalikan ikon dark_mode.',
        );
        return Icons.dark_mode;
      case ThemeMode.system:
        Log.info(
          '[Pilihan Tema] ✅ Tema Otomatis, mengembalikan ikon brightness_auto.',
        );
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('[Build UI] ✅ Membangun widget ThemeMenuWidget.');

    final themeProvider = Provider.of<ThemeProvider>(context);

    Log.info(
      '[Build UI] ✅ Mengembalikan widget PopupMenuButton untuk pilihan tema.',
    );
    return PopupMenuButton<ThemeMode>(
      icon: Icon(_getCurrentIcon(themeProvider.themeMode)),
      onSelected: (final ThemeMode mode) {
        Log.info(
          '[Aksi Pengguna] ✅ Pengguna memilih tema baru: $mode.',
        );
        try {
          unawaited(themeProvider.setTheme(mode));
          Log.info(
            '[State Management] ✅ Berhasil menerapkan tema: $mode.',
          );
        } on Exception catch (e, st) {
          Log.error(
            '[State Management] ❌ Gagal menerapkan tema: $mode.',
            e: e,
            st: st,
          );
        }
      },
      itemBuilder: (final BuildContext context) {
        Log.info('[Build UI] ✅ Membangun item-item untuk PopupMenuButton.');
        return <PopupMenuEntry<ThemeMode>>[
          const PopupMenuItem<ThemeMode>(
            value: ThemeMode.system,
            child: Row(
              children: [
                Icon(Icons.settings_brightness_outlined),
                SizedBox(width: 10),
                Text('Otomatis'),
              ],
            ),
          ),
          const PopupMenuItem<ThemeMode>(
            value: ThemeMode.light,
            child: Row(
              children: [
                Icon(Icons.light_mode_outlined),
                SizedBox(width: 10),
                Text('Terang'),
              ],
            ),
          ),
          const PopupMenuItem<ThemeMode>(
            value: ThemeMode.dark,
            child: Row(
              children: [
                Icon(Icons.dark_mode_outlined),
                SizedBox(width: 10),
                Text('Gelap'),
              ],
            ),
          ),
        ];
      },
    );
  }
}

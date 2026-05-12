// path: lib/widget/theme_menu_widget.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/user/provider/theme_provider.dart';

class ThemeMenuWidget extends StatelessWidget {
  const ThemeMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    log('[Build UI] ✅ Membangun widget ThemeMenuWidget.', name: 'theme_menu_widget.dart');
    
    log('[State Management] ✅ Mendapatkan instance dari ThemeProvider.', name: 'theme_menu_widget.dart');
    final themeProvider = Provider.of<ThemeProvider>(context);

    log('[Fungsi Lokal] ✅ Mendefinisikan fungsi lokal getCurrentIcon untuk mendapatkan ikon tema saat ini.', name: 'theme_menu_widget.dart');
    IconData getCurrentIcon() {
      log('[Eksekusi Fungsi] ✅ Menjalankan getCurrentIcon untuk menentukan ikon berdasarkan tema: ${themeProvider.tema}.', name: 'theme_menu_widget.dart');
      switch (themeProvider.tema) {
        case ThemeMode.light:
          log('[Pilihan Tema] ✅ Tema saat ini adalah Terang (light), mengembalikan ikon light_mode.', name: 'theme_menu_widget.dart');
          return Icons.light_mode;
        case ThemeMode.dark:
          log('[Pilihan Tema] ✅ Tema saat ini adalah Gelap (dark), mengembalikan ikon dark_mode.', name: 'theme_menu_widget.dart');
          return Icons.dark_mode;
        case ThemeMode.system:
          log('[Pilihan Tema] ✅ Tema saat ini adalah Otomatis (system), mengembalikan ikon brightness_auto.', name: 'theme_menu_widget.dart');
          return Icons.brightness_auto;
      }
    }

    log('[Build UI] ✅ Mengembalikan widget PopupMenuButton untuk pilihan tema.', name: 'theme_menu_widget.dart');
    return PopupMenuButton<ThemeMode>(
      icon: Icon(getCurrentIcon()),
      onSelected: (ThemeMode mode) async {
        log(
          '[Aksi Pengguna] ✅ Pengguna memilih tema baru: $mode.',
          name: 'theme_menu_widget.dart',
        );
        try {
          await themeProvider.aturTema(mode);
          log(
            '[State Management] ✅ Berhasil menerapkan tema: $mode.',
            name: 'theme_menu_widget.dart',
          );
        } catch (e, st) {
          log(
            '[State Management] ❌ Gagal menerapkan tema: $mode.',
            name: 'theme_menu_widget.dart',
            error: e,
            stackTrace: st,
          );
        }
      },
      itemBuilder: (BuildContext context) {
        log('[Build UI] ✅ Membangun item-item untuk PopupMenuButton.', name: 'theme_menu_widget.dart');
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

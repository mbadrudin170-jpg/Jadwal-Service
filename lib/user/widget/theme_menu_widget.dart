// path: lib/user/widget/theme_menu_widget.dart
// diubah: Menghapus blok default yang tidak perlu pada switch.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/provider/theme_provider.dart';

class ThemeMenuWidget extends StatelessWidget {
  const ThemeMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Log.info('[Build UI] ✅ Membangun widget ThemeMenuWidget.');

    final themeProvider = Provider.of<ThemeProvider>(context);

    IconData getCurrentIcon() {
      Log.info(
          '[Eksekusi Fungsi] ✅ Menjalankan getCurrentIcon untuk menentukan ikon berdasarkan tema: ${themeProvider.themeMode}.');
      // diubah: Switch sekarang sudah mencakup semua kasus, jadi tidak perlu default.
      switch (themeProvider.themeMode) {
        case ThemeMode.light:
          Log.info(
              '[Pilihan Tema] ✅ Tema saat ini adalah Terang (light), mengembalikan ikon light_mode.');
          return Icons.light_mode;
        case ThemeMode.dark:
          Log.info(
              '[Pilihan Tema] ✅ Tema saat ini adalah Gelap (dark), mengembalikan ikon dark_mode.');
          return Icons.dark_mode;
        case ThemeMode.system:
          Log.info(
              '[Pilihan Tema] ✅ Tema saat ini adalah Otomatis (system), mengembalikan ikon brightness_auto.');
          return Icons.brightness_auto;
      }
    }

    Log.info(
        '[Build UI] ✅ Mengembalikan widget PopupMenuButton untuk pilihan tema.');
    return PopupMenuButton<ThemeMode>(
      icon: Icon(getCurrentIcon()),
      onSelected: (ThemeMode mode) async {
        Log.info(
          '[Aksi Pengguna] ✅ Pengguna memilih tema baru: $mode.',
        );
        try {
          await themeProvider.aturTema(mode);
          Log.info(
            '[State Management] ✅ Berhasil menerapkan tema: $mode.',
          );
        } catch (e, st) {
          Log.error(
            '[State Management] ❌ Gagal menerapkan tema: $mode.',
            e: e,
            st: st,
          );
        }
      },
      itemBuilder: (BuildContext context) {
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

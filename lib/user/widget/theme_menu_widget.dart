// path: lib/user/widget/theme_menu_widget.dart
// diubah: Dibuat menjadi widget presentasional murni.
//         Kini menerima `currentThemeMode` dan `onThemeSelected` dari parent,
//         sehingga tidak lagi bergantung pada Provider secara internal.
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Widget untuk menampilkan menu pilihan tema (UI Murni).
///
/// Menampilkan PopupMenuButton yang memungkinkan pengguna memilih
/// antara tema terang, gelap, atau otomatis (mengikuti sistem).
///
/// Widget ini bersifat presentasional dan memerlukan [currentThemeMode] dan
/// [onThemeSelected] dari parent widget.
class ThemeMenuWidget extends StatelessWidget {
  /// Mode tema yang sedang aktif.
  final ThemeMode currentThemeMode;

  /// Callback yang dipanggil saat tema baru dipilih.
  final ValueChanged<ThemeMode> onThemeSelected;

  /// Membuat instance dari [ThemeMenuWidget].
  const ThemeMenuWidget({
    super.key,
    required this.currentThemeMode,
    required this.onThemeSelected,
  });

  /// Mengembalikan ikon yang sesuai dengan [mode] tema.
  IconData _getCurrentIcon(final ThemeMode mode) {
    Log.info(
      '[Eksekusi Fungsi] Menjalankan _getCurrentIcon untuk tema: $mode.',
    );
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('[Build UI] Membangun widget ThemeMenuWidget.');

    return PopupMenuButton<ThemeMode>(
      icon: Icon(_getCurrentIcon(currentThemeMode)),
      onSelected: onThemeSelected, // Langsung gunakan callback dari props
      itemBuilder: (final BuildContext context) {
        Log.info('[Build UI] Membangun item-item untuk PopupMenuButton.');
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

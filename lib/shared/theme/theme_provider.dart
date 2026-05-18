// path: lib/shared/theme/theme_provider.dart
// Fitur: Manajemen Tema Aplikasi (GLOBAL)
// Tujuan: Menyediakan, mengubah, dan menyimpan preferensi tema pengguna
//          untuk digunakan oleh sisi admin maupun user.
//
// diubah: Menjadikan file ini sebagai satu-satunya provider tema global.
//         Sekarang mendukung persistensi via LocalStorageService dan
//         memiliki method setTheme untuk kontrol tema spesifik.
// diubah: Menghapus duplikasi kode manajemen tema yang sebelumnya terpisah
//         antara shared/theme/theme_provider.dart (lama) dan
//         user/provider/user_theme_provider.dart.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/user/app_user.dart (AppUser)
//   - lib/admin/app_admin.dart (AppAdmin)
//   - lib/user/widget/theme_menu_widget.dart (ThemeMenuWidget)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/user/services/storage/local_storage_service.dart (LocalStorageService)
//   - lib/shared/debug/log.dart (Log)

/// Kontrak untuk provider tema global, mendefinisikan properti dan metode
/// yang harus dimiliki oleh implementasi provider tema.
abstract class ThemeProvider extends ChangeNotifier {
  /// Mengambil mode tema saat ini (`system`, `light`, atau `dark`).
  ThemeMode get themeMode;

  /// Memeriksa apakah mode gelap sedang aktif.
  bool get isDarkMode;

  /// Mengatur mode tema aplikasi dan menyimpannya ke penyimpanan lokal.
  Future<void> setTheme(final ThemeMode mode);

  /// Memuat mode tema yang tersimpan dari penyimpanan lokal.
  Future<void> loadTheme();
}

/// Implementasi konkret dari [ThemeProvider].
///
/// Menyimpan preferensi tema ke [LocalStorageService] agar persisten
/// setelah aplikasi ditutup.
class ThemeProviderImpl extends ChangeNotifier implements ThemeProvider {
  /// Service untuk berinteraksi dengan penyimpanan lokal.
  final LocalStorageService localStorageService;

  ThemeMode _themeMode = ThemeMode.system;

  /// Membuat instance dari [ThemeProviderImpl].
  ///
  /// Akan memuat tema dari [localStorageService] saat inisialisasi.
  ThemeProviderImpl({required this.localStorageService}) {
    Log.info(
      '[ThemeProvider] Inisialisasi, memuat tema dari LocalStorageService.',
    );
    unawaited(loadTheme());
  }

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  @override
  Future<void> loadTheme() async {
    Log.info('[ThemeProvider] Sedang memuat preferensi tema pengguna...');
    try {
      final themeFromStorage = await localStorageService.getThemeMode();
      Log.info(
        '[ThemeProvider] Tema berhasil dimuat dari penyimpanan: $themeFromStorage',
      );

      if (_themeMode != themeFromStorage) {
        _themeMode = themeFromStorage;
        notifyListeners();
      }
    } on Exception catch (e, st) {
      Log.error(
        '[ThemeProvider] Gagal memuat preferensi tema',
        e: e,
        st: st,
      );
    }
  }

  @override
  Future<void> setTheme(final ThemeMode mode) async {
    if (mode == _themeMode) return;

    Log.info('[ThemeProvider] Mengatur tema baru: $mode');
    _themeMode = mode;
    notifyListeners();

    try {
      await localStorageService.saveThemeMode(mode);
      Log.info(
        '[ThemeProvider] Preferensi tema berhasil dikirim ke service untuk disimpan.',
      );
    } on Exception catch (e, st) {
      Log.error(
        '[ThemeProvider] Gagal menyimpan preferensi tema melalui service',
        e: e,
        st: st,
      );
    }
  }
}

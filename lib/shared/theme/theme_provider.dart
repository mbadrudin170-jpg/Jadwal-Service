// path: lib/shared/theme/theme_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return ThemeNotifier(localStorageService);
});

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

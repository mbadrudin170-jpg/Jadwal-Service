// path: lib/shared/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Provider tema menggunakan AsyncNotifier (modern Riverpod)
final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(() => ThemeNotifier());

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  late LocalStorageService _storage;

  @override
  Future<ThemeMode> build() async {
    // Ambil instance LocalStorageService dari provider (async)
    _storage = await ref.watch(localStorageServiceProvider.future);

    // Muat tema yang tersimpan
    final savedTheme = await _storage.getThemeMode();
    Log.info('[ThemeNotifier] Tema awal dimuat: $savedTheme');
    return savedTheme;
  }

  /// Mengganti mode tema aplikasi
  Future<void> setThemeMode(ThemeMode mode) async {
    final currentState = state;
    if (currentState is AsyncData && currentState.value == mode) return;

    Log.info('[ThemeNotifier] Mengatur tema: $mode');
    state = AsyncData(mode); // update state
    await _storage.saveThemeMode(mode);
  }

  /// Helper untuk mengecek apakah mode gelap aktif (opsional)
  bool isDarkMode(BuildContext context) {
    final current = state.value ?? ThemeMode.system;
    if (current == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark;
    }
    return current == ThemeMode.dark;
  }
}

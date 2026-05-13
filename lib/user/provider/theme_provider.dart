// path: lib/user/provider/theme_provider.dart
// Fitur: Manajemen Tema Aplikasi
// Tujuan: Menyediakan, mengubah, dan menyimpan preferensi tema pengguna.
//
// diubah: Menghapus semua logika konversi tipe manual (toString/fromString).
// ThemeProvider sekarang berinteraksi langsung dengan LocalStorageService
// menggunakan tipe data ThemeMode, karena service tersebut sudah menangani
// konversi internal ke/dari String.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

abstract class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode;
  bool get isDarkMode;
  Future<void> aturTema(ThemeMode mode);
  Future<void> muatTema();
}

class ThemeProviderImpl extends ChangeNotifier implements ThemeProvider {
  final LocalStorageService localStorageService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProviderImpl({required this.localStorageService}) {
    Log.info(
        '[ThemeProvider] Inisialisasi, memuat tema dari LocalStorageService.');
    muatTema();
  }

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return _themeMode == ThemeMode.dark;
    }
  }

  // diubah: Menggunakan tipe ThemeMode secara langsung dari service.
  @override
  Future<void> muatTema() async {
    Log.info('[ThemeProvider] Sedang memuat preferensi tema pengguna...');
    try {
      final modeDariPenyimpanan = await localStorageService.ambilModeTema();
      Log.info(
          '[ThemeProvider] Tema berhasil dimuat dari penyimpanan: $modeDariPenyimpanan');

      if (_themeMode != modeDariPenyimpanan) {
        _themeMode = modeDariPenyimpanan;
        notifyListeners();
      }
    } catch (e, st) {
      Log.error(
        '[ThemeProvider] Gagal memuat preferensi tema',
        e: e,
        st: st,
      );
    }
  }

  // diubah: Mengirim tipe ThemeMode secara langsung ke service.
  @override
  Future<void> aturTema(ThemeMode mode) async {
    if (mode == _themeMode) return;

    Log.info('[ThemeProvider] Mengatur tema baru: $mode');
    _themeMode = mode;
    notifyListeners();

    try {
      await localStorageService.simpanModeTema(mode);
      Log.info(
          '[ThemeProvider] Preferensi tema berhasil dikirim ke service untuk disimpan.');
    } catch (e, st) {
      Log.error(
        '[ThemeProvider] Gagal menyimpan preferensi tema melalui service',
        e: e,
        st: st,
      );
    }
  }
}

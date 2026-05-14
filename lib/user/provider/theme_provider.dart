// path: lib/user/provider/theme_provider.dart
// Fitur: Manajemen Tema Aplikasi
// Tujuan: Menyediakan, mengubah, dan menyimpan preferensi tema pengguna.
//
// diubah: Menghapus semua logika konversi tipe manual (toString/fromString).
// ThemeProvider sekarang berinteraksi langsung dengan LocalStorageService
// menggunakan tipe data ThemeMode, karena service tersebut sudah menangani
// konversi internal ke/dari String.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Kontrak untuk provider tema, mendefinisikan properti dan metode
/// yang harus dimiliki oleh implementasi provider tema.
abstract class ThemeProvider extends ChangeNotifier {
  /// Mengambil mode tema saat ini (`system`, `light`, atau `dark`).
  ThemeMode get themeMode;

  /// Memeriksa apakah mode gelap sedang aktif.
  bool get isDarkMode;

  /// Mengatur mode tema aplikasi dan menyimpannya ke penyimpanan lokal.
  Future<void> aturTema(final ThemeMode mode);

  /// Memuat mode tema yang tersimpan dari penyimpanan lokal.
  Future<void> muatTema();
}

/// Implementasi konkret dari [ThemeProvider].
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
    unawaited(muatTema());
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
        '[ThemeProvider] Tema berhasil dimuat dari penyimpanan: $modeDariPenyimpanan',
      );

      if (_themeMode != modeDariPenyimpanan) {
        _themeMode = modeDariPenyimpanan;
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

  // diubah: Mengirim tipe ThemeMode secara langsung ke service.
  @override
  Future<void> aturTema(final ThemeMode mode) async {
    if (mode == _themeMode) return;

    Log.info('[ThemeProvider] Mengatur tema baru: $mode');
    _themeMode = mode;
    notifyListeners();

    try {
      await localStorageService.simpanModeTema(mode);
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

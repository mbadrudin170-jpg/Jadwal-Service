// path: lib/shared/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Mengelola status tema aplikasi (terang, gelap, atau sistem).
///
/// Menggunakan `ChangeNotifier` untuk memberi tahu pendengar (listener) ketika
/// tema berubah, memungkinkan UI untuk membangun kembali dengan tema yang benar.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default ke mode terang

  /// Mengembalikan `ThemeMode` saat ini.
  ThemeMode get themeMode => _themeMode;

  /// Mengganti antara mode terang dan gelap.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    Log.info('Tema diubah menjadi: ${_themeMode.toString()}');
    notifyListeners(); // Memberi tahu semua pendengar tentang perubahan
  }

  /// Mengatur tema untuk mengikuti pengaturan sistem.
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    Log.info('Tema diatur ke mode sistem.');
    notifyListeners();
  }
}

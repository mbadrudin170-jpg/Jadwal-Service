// path: lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';

// Kelas abstrak untuk ThemeProvider agar bisa di-mock dalam pengujian
abstract class ThemeProvider extends ChangeNotifier {
  ThemeMode get tema;
  Future<void> aturTema(ThemeMode mode);
  Future<void> muatTema(); // Tambah method untuk load tema
}

class ThemeProviderImpl extends ChangeNotifier implements ThemeProvider {
  ThemeMode _tema = ThemeMode.system;
  static const String _keyTema = 'theme_mode'; // Key untuk SharedPreferences

  ThemeProviderImpl() {
    Log.info('[Inisialisasi Provider] ✅ ThemeProviderImpl dibuat.');
    // muatTema() akan dipanggil secara eksplisit dari luar setelah inisialisasi
  }

  @override
  ThemeMode get tema => _tema;

  @override
  Future<void> muatTema() async {
    log(
      '[Muat Tema] ✅ Memulai memuat tema dari SharedPreferences.',
      name: 'theme_provider.dart',
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final temaString = prefs.getString(_keyTema) ?? 'system';
      log(
        '[Muat Tema] ✅ Tema yang tersimpan adalah: `$temaString`.',
        name: 'theme_provider.dart',
      );

      ThemeMode mode;
      switch (temaString) {
        case 'light':
          mode = ThemeMode.light;
          break;
        case 'dark':
          mode = ThemeMode.dark;
          break;
        default:
          mode = ThemeMode.system;
      }

      if (_tema != mode) {
        _tema = mode;
        log(
          '[Pembaruan State] ✅ Tema berhasil dimuat dan diatur ke: $mode.',
          name: 'theme_provider.dart',
        );
        notifyListeners();
      } else {
        log(
          '[Muat Tema] ✅ Tema yang dimuat sama dengan state saat ini, tidak ada perubahan.',
          name: 'theme_provider.dart',
        );
      }
    } catch (e, st) {
      log(
        '[Muat Tema] ❌ Gagal memuat tema dari SharedPreferences.',
        name: 'theme_provider.dart',
        error: e,
        st: st,
      );
    }
  }

  @override
  Future<void> aturTema(ThemeMode mode) async {
    if (_tema == mode) {
      log(
        '[Atur Tema] ✅ Mode tema sudah sama ($mode), tidak ada aksi.',
        name: 'theme_provider.dart',
      );
      return;
    }

    _tema = mode;
    log(
      '[Pembaruan State] ✅ Mengatur tema baru ke: $mode dan memberitahu listener.',
      name: 'theme_provider.dart',
    );
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String value;
      switch (mode) {
        case ThemeMode.light:
          value = 'light';
          break;
        case ThemeMode.dark:
          value = 'dark';
          break;
        default:
          value = 'system';
      }
      await prefs.setString(_keyTema, value);
      log(
        '[Simpan Tema] ✅ Tema ($value) berhasil disimpan ke SharedPreferences.',
        name: 'theme_provider.dart',
      );
    } catch (e, st) {
      log(
        '[Simpan Tema] ❌ Gagal menyimpan tema ke SharedPreferences.',
        name: 'theme_provider.dart',
        error: e,
        st: st,
      );
    }
  }
}

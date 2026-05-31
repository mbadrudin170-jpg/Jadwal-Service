// path: lib/shared/providers/shared_providers.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

part 'shared_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<LocalStorageService> localStorageService(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalStorageService(prefs: prefs);
}

@Riverpod(keepAlive: true)
ActiveCustomerOperation activeCustomerOperation(Ref ref) {
  return ActiveCustomerOperation();
}

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  // Tidak lagi 'late', akan diinisialisasi di 'build'
  late LocalStorageService _localStorageService;

  @override
  Future<ThemeMode> build() async {
    // 1. Dapatkan instance LocalStorageService
    _localStorageService = await ref.watch(localStorageServiceProvider.future);

    // 2. Baca tema yang tersimpan dan kembalikan sebagai state awal
    return await _localStorageService.getThemeMode();
  }

  // Method untuk mengubah dan menyimpan tema baru
  Future<void> setThemeMode(ThemeMode themeMode) async {
    // Langsung gunakan _localStorageService yang sudah diinisialisasi di build
    await _localStorageService.saveThemeMode(themeMode);
    // Perbarui state provider agar UI ikut berubah
    state = AsyncValue.data(themeMode);
  }
}

// path: lib/shared/providers/shared_providers.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

part 'shared_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  // DIHAPUS: SharedPreferencesRef
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<LocalStorageService> localStorageService(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalStorageService(prefs: prefs);
}

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  late LocalStorageService _localStorageService;
  @override
  Future<ThemeMode> build() async {
    final localStorage = await ref.watch(localStorageServiceProvider.future);
    _localStorageService = localStorage;
    return await _localStorageService.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = const AsyncValue.loading();
    try {
      await _localStorageService.saveThemeMode(themeMode);
      state = AsyncValue.data(themeMode);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// path: test/user/provider/theme_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

// Mocks
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  group('ThemeProviderImpl', () {
    late ThemeProviderImpl themeProvider;
    late MockLocalStorageService mockLocalStorageService;

    setUp(() {
      mockLocalStorageService = MockLocalStorageService();
      themeProvider =
          ThemeProviderImpl(localStorageService: mockLocalStorageService);
    });

    test('Initial theme mode is system', () {
      expect(themeProvider.themeMode, ThemeMode.system);
    });

    test('muatTema should load theme from local storage', () async {
      when(mockLocalStorageService.ambilModeTema())
          .thenAnswer((final _) async => ThemeMode.dark);

      await themeProvider.muatTema();

      expect(themeProvider.themeMode, ThemeMode.dark);
      verify(mockLocalStorageService.ambilModeTema());
    });

    test('aturTema should set new theme and save to local storage', () async {
      const newThemeMode = ThemeMode.light;

      await themeProvider.aturTema(newThemeMode);

      expect(themeProvider.themeMode, newThemeMode);
      verify(mockLocalStorageService.simpanModeTema(newThemeMode));
    });

    test('isDarkMode returns true when themeMode is dark', () async {
      await themeProvider.aturTema(ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);
    });

    test('isDarkMode returns false when themeMode is light', () async {
      await themeProvider.aturTema(ThemeMode.light);
      expect(themeProvider.isDarkMode, isFalse);
    });
  });
}

// path: lib/user/app_user.dart
// diubah: Menyederhanakan AppUser menjadi StatelessWidget.
// diubah: Menghapus semua logika pengecekan mode pemeliharaan yang sudah dipindah ke main_user.dart.
// refactor: Menghapus Provider FirestoreService yang tidak lagi digunakan.
// fix: Menggunakan import dengan alias untuk mengatasi konflik nama ThemeProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/shared/theme/theme_provider.dart' as user_theme;
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama untuk aplikasi sisi pengguna (user).
///
/// Bertanggung jawab untuk inisialisasi provider, tema, dan routing.
class AppUser extends StatelessWidget {
  /// Instance dari SharedPreferences untuk penyimpanan lokal.
  final SharedPreferences prefs;

  /// Membuat instance [AppUser].
  const AppUser({super.key, required this.prefs});

  @override
  Widget build(final BuildContext context) {
    Log.info('[AppUser] build: Membangun UI utama aplikasi.');
    final localStorageService = LocalStorageService(prefs: prefs);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<user_theme.ThemeProvider>(
          create: (final context) =>
              user_theme.ThemeProviderImpl(localStorageService: localStorageService),
        ),
      ],
      child: Consumer<user_theme.ThemeProvider>(
        builder: (final context, final themeProvider, final child) {
          Log.info(
            '[Consumer<ThemeProvider>] Membangun MaterialApp dengan tema: ${themeProvider.themeMode}',
          );
          return MaterialApp(
            title: 'Aplikasi User',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreenUser(),
            routes: {
              '/login': (final context) => const LoginPage(),
            },
          );
        },
      ),
    );
  }
}

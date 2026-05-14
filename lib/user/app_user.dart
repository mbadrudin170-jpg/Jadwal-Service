// path: lib/user/app_user.dart
// diubah: Menyederhanakan AppUser menjadi StatelessWidget.
// diubah: Menghapus semua logika pengecekan mode pemeliharaan yang sudah dipindah ke main_user.dart.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/provider/theme_provider.dart';
import 'package:wifi/user/services/firestore_service.dart';
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
  Widget build(BuildContext context) {
    Log.info('[AppUser] build: Membangun UI utama aplikasi.');
    final localStorageService = LocalStorageService(prefs: prefs);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) =>
              ThemeProviderImpl(localStorageService: localStorageService),
        ),
        Provider<FirestoreService>(
          create: (context) => FirestoreService(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
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
              '/login': (context) => const LoginPage(),
            },
          );
        },
      ),
    );
  }
}

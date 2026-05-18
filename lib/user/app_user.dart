// path: lib/user/app_user.dart
// diubah: Menerima NotifikasiServis dan menyediakannya melalui Provider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama untuk aplikasi sisi pengguna (user).
///
/// Bertanggung jawab untuk inisialisasi provider, tema, dan routing.
class AppUser extends StatelessWidget {
  /// Instance dari SharedPreferences untuk penyimpanan lokal.
  final SharedPreferences prefs;

  /// Instance dari NotifikasiServis yang sudah diinisialisasi.
  final NotifikasiServis notifikasiServis;

  /// Membuat instance [AppUser].
  const AppUser({
    super.key,
    required this.prefs,
    required this.notifikasiServis,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info('[AppUser] build: Membangun UI utama aplikasi.');
    final localStorageService = LocalStorageService(prefs: prefs);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (final _) =>
              ThemeProviderImpl(localStorageService: localStorageService),
        ),
        // Daftarkan instance NotifikasiServis yang sudah ada.
        Provider<NotifikasiServis>.value(value: notifikasiServis),
      ],
      child: Consumer<ThemeProvider>(
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

// path: lib/user/app_user.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama aplikasi user.
class AppUser extends StatelessWidget {
  /// Konstruktor untuk [AppUser].
  const AppUser({super.key});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder digunakan untuk memastikan SharedPreferences siap sebelum
    // aplikasi dimulai.
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        // Selama SharedPreferences dimuat, tampilkan loading indicator.
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final localStorageService = LocalStorageService(prefs: prefs);

        // MultiProvider untuk menyediakan semua service dan state management
        // yang dibutuhkan oleh aplikasi.
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) =>
                  ThemeProviderImpl(localStorageService: localStorageService),
            ),
            Provider<NotifikasiServis>(
              create: (_) => NotifikasiServis(),
            ),
            // Tambahkan provider lain di sini jika dibutuhkan.
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ToastificationWrapper(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                  // Halaman pertama yang ditampilkan adalah SplashScreenUser.
                  home: SplashScreenUser(
                    prefs: prefs,
                    localStorageService: localStorageService,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

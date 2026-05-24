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
import 'package:wifi/user/widget/ads/app_open_ad_service.dart';

/// Widget utama aplikasi user.
class AppUser extends StatefulWidget {
  /// Konstruktor untuk [AppUser].
  const AppUser({super.key});

  @override
  State<AppUser> createState() => _AppUserState();
}

class _AppUserState extends State<AppUser> with WidgetsBindingObserver {
  late final AppOpenAdService _appOpenAdService;

  @override
  void initState() {
    super.initState();
    // 1. Mendaftarkan observer untuk mendengarkan siklus hidup aplikasi.
    WidgetsBinding.instance.addObserver(this);

    // 2. Membuat instance dan memuat iklan pembuka aplikasi pertama kali.
    _appOpenAdService = AppOpenAdService();
    _appOpenAdService.loadAd();
  }

  @override
  void dispose() {
    // 3. Melepaskan observer untuk mencegah memory leak.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 4. Dipanggil setiap kali status aplikasi berubah (resume, inactive, paused).
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Saat pengguna kembali ke aplikasi, coba tampilkan iklan.
      _appOpenAdService.showAdIfReady();
    }
  }

  @override
  Widget build(final BuildContext context) {
    // FutureBuilder digunakan untuk memastikan SharedPreferences siap sebelum
    // aplikasi dimulai.
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
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
              create: (final _) =>
                  ThemeProviderImpl(localStorageService: localStorageService),
            ),
            Provider<NotifikasiServis>(
              create: (final _) => NotifikasiServis(),
            ),
            // Tambahkan provider lain di sini jika dibutuhkan.
          ],
          child: Consumer<ThemeProvider>(
            builder: (final context, final themeProvider, final child) {
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

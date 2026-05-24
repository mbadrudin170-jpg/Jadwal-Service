// path: lib/user/app_user.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/providers/app_readiness_provider.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/app_open/app_open_ad_service.dart';

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
    WidgetsBinding.instance.addObserver(this);
    _appOpenAdService = AppOpenAdService();
    _appOpenAdService.loadAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Dapatkan status kesiapan dari provider.
      // `listen: false` penting di sini karena kita tidak sedang dalam `build` method.
      final bool isAppReady = context.read<AppReadinessProvider>().isReady;

      // Iklan hanya boleh tampil jika aplikasi sudah melewati splash screen.
      if (isAppReady) {
        _appOpenAdService.showAdIfAvailable();
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (final context, final snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final localStorageService = LocalStorageService(prefs: prefs);

        return MultiProvider(
          providers: [
            // DAFTARKAN PROVIDER BARU DI SINI
            ChangeNotifierProvider<AppReadinessProvider>(
              create: (final _) => AppReadinessProvider(),
            ),
            ChangeNotifierProvider<ThemeProvider>(
              create: (final _) =>
                  ThemeProviderImpl(localStorageService: localStorageService),
            ),
            Provider<NotifikasiServis>(
              create: (final _) => NotifikasiServis(),
            ),
          ],
          child: Consumer<ThemeProvider>(
            builder: (final context, final themeProvider, final child) {
              return ToastificationWrapper(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
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

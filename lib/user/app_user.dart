// path: lib/user/app_user.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/debug/global_key.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/page/splash_screen_user.dart';
import 'package:wifi/user/providers/app_readiness_provider.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Widget utama aplikasi user.
class AppUser extends StatefulWidget {
  /// Konstruktor untuk [AppUser].
  const AppUser({super.key});

  @override
  State<AppUser> createState() => _AppUserState();
}

class _AppUserState extends State<AppUser> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {}
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
                  scaffoldMessengerKey: scaffoldMessengerKey, // DITAMBAHKAN
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

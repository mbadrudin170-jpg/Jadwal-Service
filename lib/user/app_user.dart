import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/debug/global_key.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/user/page/splash_screen_user.dart';

class AppUser extends ConsumerWidget {
  const AppUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    final localStorageAsync = ref.watch(localStorageServiceProvider);

    // Gabungkan ketiga async state
    return themeAsync.when(
      data: (themeMode) {
        return prefsAsync.when(
          data: (prefs) {
            return localStorageAsync.when(
              data: (localStorage) {
                return ToastificationWrapper(
                  child: MaterialApp(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeMode,
                    home: SplashScreenUser(
                      prefs: prefs,
                      localStorageService: localStorage,
                    ),
                  ),
                );
              },
              loading: () => const MaterialApp(
                home: Scaffold(body: Center(child: CircularProgressIndicator())),
              ),
              error: (err, stack) => MaterialApp(
                home: Scaffold(body: Center(child: Text('Error localStorage: $err'))),
              ),
            );
          },
          loading: () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
          error: (err, stack) => MaterialApp(
            home: Scaffold(body: Center(child: Text('Error SharedPreferences: $err'))),
          ),
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error tema: $err'))),
      ),
    );
  }
}
// path: lib/user/app_user.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/debug/global_key.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/tema_provider.dart';
import 'package:wifi/user/page/splash_screen_user.dart';

class AppUser extends ConsumerWidget {
  const AppUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(layananNotifikasiProvider);

    final themeAsync = ref.watch(temaProvider);
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    final localStorageAsync = ref.watch(layananPenyimpananLokalProvider);

    // 1. Gabungkan semua state provider ke dalam satu list.
    final allProviders = [themeAsync, prefsAsync, localStorageAsync];

    final firstError = allProviders.firstWhere(
      (provider) => provider.hasError && provider.error != null,
      orElse: () => const AsyncValue.data(true),
    );

    if (firstError.hasError) {
      // Perbaikan 2: Gunakan properti `stackTrace` yang benar.
      return _ErrorApp(
          error: firstError.error, stackTrace: firstError.stackTrace);
    }

    // 3. Cek apakah ada provider yang masih loading.
    final isLoading = allProviders.any((provider) => provider.isLoading);
    if (isLoading) {
      return const _LoadingApp();
    }

    // 4. Jika semua provider berhasil mendapatkan data, bangun UI utama.
    return ToastificationWrapper(
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.modeTerang,
        darkTheme: AppTheme.modeGelap,
        themeMode: themeAsync.asData!.value,
        home: SplashScreenUser(
          prefs: prefsAsync.asData!.value,
          localStorageService: localStorageAsync.asData!.value,
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan state loading aplikasi.
class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan state error aplikasi.
class _ErrorApp extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;

  const _ErrorApp({this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Terjadi kesalahan saat memuat aplikasi: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

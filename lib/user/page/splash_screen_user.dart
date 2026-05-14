// path: lib/user/page/splash_screen_user.dart
// diubah: Memperbaiki kesalahan sintaks pada pemanggilan initializeDateFormatting.
// ditambah: Menambahkan dokumentasi untuk public members.
// diubah: Menangani discarded_futures di initState.
// diubah: Menambahkan trailing comma.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman splash screen untuk pengguna.
class SplashScreenUser extends StatefulWidget {
  /// Konstruktor untuk SplashScreenUser.
  const SplashScreenUser({super.key});

  @override
  State<SplashScreenUser> createState() => _SplashScreenUserState();
}

class _SplashScreenUserState extends State<SplashScreenUser> {
  @override
  void initState() {
    super.initState();
    Log.info('SplashScreen: initState dipanggil.');
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      unawaited(_checkSession());
    });
  }

  Future<void> _checkSession() async {
    Log.info('SplashScreen: Memeriksa sesi pengguna...');

    try {
      // diubah: Membungkus 'id_ID' dengan tanda kutip.
      await initializeDateFormatting('id_ID');
      Log.info("Inisialisasi format tanggal 'id_ID' berhasil.");

      await Future<void>.delayed(
        const Duration(seconds: 1),
      ); // Mengurangi delay

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final isLoggedIn = userId != null;

      if (!mounted) return;

      if (isLoggedIn) {
        Log.info(
          'Pengguna sudah login. Navigasi ke MainPage.',
          {'userId': userId},
        );
        final localStorageService = LocalStorageService(prefs: prefs);
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (final context) => MainPage(
              userId: userId,
              localStorageService: localStorageService,
            ),
          ),
        );
      } else {
        Log.warning('Pengguna belum login. Navigasi ke LoginPage.');
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (final context) => const LoginPage()),
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal memeriksa sesi pengguna atau inisialisasi.',
        e: e,
        st: s,
      );
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (final context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    Log.info('SplashScreen: dispose dipanggil.');
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('SplashScreen: Membangun UI.');
    const message = 'Memeriksa sesi pengguna...';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/ikon_apk.png',
              width: 150,
            ),
            const SizedBox(height: 24),
            Text(
              'WiFi Client',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

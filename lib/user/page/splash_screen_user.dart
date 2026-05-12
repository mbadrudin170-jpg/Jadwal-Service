
// path: lib/user/page/splash_screen_user.dart
// diubah: Menerjemahkan semua pesan log ke dalam Bahasa Indonesia.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_text_style.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

class SplashScreenUser extends StatefulWidget {
  const SplashScreenUser({super.key});

  @override
  State<SplashScreenUser> createState() => _SplashScreenUserState();
}

class _SplashScreenUserState extends State<SplashScreenUser> {
  @override
  void initState() {
    super.initState();
    Log.info('SplashScreen: initState dipanggil.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    Log.info('SplashScreen: Memeriksa sesi pengguna...');
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final isLoggedIn = userId != null;

      if (!mounted) return;

      if (isLoggedIn) {
        Log.info('Pengguna sudah login. Navigasi ke MainPage.', {'userId': userId});
        final localStorageService = LocalStorageService(prefs: prefs);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainPage(
                  userId: userId,
                  localStorageService: localStorageService)),
        );
      } else {
        Log.warning('Pengguna belum login. Navigasi ke LoginPage.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e, s) {
      Log.error(
        'Gagal memeriksa sesi pengguna.',
        e: e,
        st: s,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    Log.info('SplashScreen: dispose dipanggil.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.info('SplashScreen: Membangun UI.');
    const message = 'Memeriksa sesi pengguna...';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
              style: appTextTheme.headlineMedium
                  ?.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              message,
              style:
                  appTextTheme.bodyLarge?.copyWith(color: AppColors.textColor),
            ),
          ],
        ),
      ),
    );
  }
}

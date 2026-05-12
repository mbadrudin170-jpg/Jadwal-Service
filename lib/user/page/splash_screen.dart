// path: lib/user/page/splash_screen.dart
// diubah: Dibuat lebih fleksibel untuk menerima pesan loading eksternal.

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  // ditambah: Parameter opsional untuk menampilkan pesan dari luar.
  final String? loadingMessage;

  const SplashScreen({super.key, this.loadingMessage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    log('[State] 🚀 Inisialisasi SplashScreen.', name: 'splash_screen.dart');

    // ditambah: Hanya jalankan navigasi otomatis jika tidak ada pesan eksternal.
    if (widget.loadingMessage == null) {
      _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    log('[Navigasi] ⚙️ Memulai proses navigasi otomatis.',
        name: 'splash_screen.dart');
    try {
      log('[Navigasi] ⚙️ Inisialisasi SharedPreferences.',
          name: 'splash_screen.dart');
      final prefs = await SharedPreferences.getInstance();
      final localStorageService = LocalStorageService(prefs: prefs);

      // Mengambil ID pengguna dari penyimpanan lokal untuk memeriksa status login
      final userId = prefs.getString('userId');
      log('[Navigasi] 🕵️‍♂️ Memeriksa status login pengguna...',
          name: 'splash_screen.dart');

      log('[Navigasi] ⏳ Penundaan tampilan selama 3 detik.',
          name: 'splash_screen.dart');
      await Future.delayed(const Duration(seconds: 3));
      log('[Navigasi] ✅ Penundaan selesai.', name: 'splash_screen.dart');

      if (!mounted) {
        log('[Navigasi] ⚠️ Widget tidak terpasang, navigasi dibatalkan.',
            name: 'splash_screen.dart');
        return;
      }

      log('[Navigasi] ✅ Widget terpasang, melanjutkan navigasi.',
          name: 'splash_screen.dart');

      // Memutuskan halaman tujuan berdasarkan status login
      if (userId != null && userId.isNotEmpty) {
        log('[Navigasi] ✅ Pengguna sudah login (ID: $userId). Mengarahkan ke MainPage.',
            name: 'splash_screen.dart');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return MainPage(
              userId: userId,
              localStorageService: localStorageService,
            );
          }),
        );
      } else {
        log('[Navigasi] 🤷‍♀️ Pengguna belum login. Mengarahkan ke LoginPage.',
            name: 'splash_screen.dart');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      log('[Navigasi] ✅ Proses navigasi selesai.', name: 'splash_screen.dart');
    } catch (e, st) {
      log('[Navigasi] ❌ Gagal melakukan navigasi otomatis.',
          name: 'splash_screen.dart', error: e, stackTrace: st);
      if (!mounted) return;
      // Jika terjadi error, fallback ke halaman login untuk keamanan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[UI] 🎨 Membangun UI SplashScreen.', name: 'splash_screen.dart');
    // diubah: Gunakan pesan eksternal jika ada, jika tidak, gunakan default.
    final message = widget.loadingMessage ?? 'Memeriksa sesi...';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    log('[State] 🗑️ Membersihkan state SplashScreen (dispose).',
        name: 'splash_screen.dart');
    super.dispose();
  }
}

// path: lib/admin/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

class SplashScreen extends StatelessWidget {
  // ditambah: Menerima pesan loading dari parent widget (app.dart)
  final String loadingMessage;

  const SplashScreen({super.key, this.loadingMessage = "Memuat..."});

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk SplashScreen dengan pesan: "$loadingMessage"');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                final isDarkMode = MediaQuery.of(context).platformBrightness ==
                    Brightness.dark;
                final logoAsset = isDarkMode
                    ? 'assets/logo/ikon/ikon_apk.png'
                    : 'assets/logo/ikon/ikon_apk.png';
                return Image.asset(logoAsset, width: 150);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Admin WiFi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              loadingMessage, // diubah: Menampilkan pesan yang diterima
              style: const TextStyle(fontSize: 14, fontFamily: 'Open Sans'),
            ),
          ],
        ),
      ),
    );
  }
}

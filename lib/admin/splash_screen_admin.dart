// path: lib/admin/splash_screen_admin.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_text_style.dart';

class SplashScreen extends StatelessWidget {
  // ditambah: Menerima pesan loading dari parent widget (app.dart)
  final String loadingMessage;

  const SplashScreen({super.key, this.loadingMessage = "Memuat..."});

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk SplashScreen dengan pesan: "$loadingMessage"');
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
              'Admin WiFi',
              style: appTextTheme.headlineMedium
                  ?.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              loadingMessage, // diubah: Menampilkan pesan yang diterima
              style: appTextTheme.bodyMedium
                  ?.copyWith(color: AppColors.textColor),
            ),
          ],
        ),
      ),
    );
  }
}

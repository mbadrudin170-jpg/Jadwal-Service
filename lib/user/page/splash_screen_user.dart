// path: lib/user/page/splash_screen_user.dart
// diubah: Diubah menjadi StatelessWidget yang hanya menampilkan UI.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// Halaman splash screen untuk pengguna, hanya bertanggung jawab untuk UI.
class SplashScreenUser extends StatelessWidget {
  /// Pesan yang ditampilkan selama proses pemuatan.
  final String loadingMessage;

  /// Konstruktor untuk [SplashScreenUser].
  const SplashScreenUser({super.key, this.loadingMessage = 'Memuat...'});

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun SplashScreenUser dengan pesan: "$loadingMessage"');
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
              loadingMessage,
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

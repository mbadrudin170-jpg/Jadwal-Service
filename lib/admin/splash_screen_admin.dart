// path: lib/admin/splash_screen_admin.dart
// diubah: Mengganti onBackground yang usang dengan onSurface yang benar.
// diubah: Menambahkan dokumentasi untuk mengatasi error public_member_api_docs.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';

/// A stateless widget that displays a splash screen.
class SplashScreen extends StatelessWidget {
  /// The message to display while loading.
  final String loadingMessage;

  /// Creates a [SplashScreen].
  const SplashScreen({super.key, this.loadingMessage = 'Memuat...'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Log.info('Membangun UI untuk SplashScreen dengan pesan: "$loadingMessage"');

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // diubah: Menggunakan warna dari tema
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
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme
                    .colorScheme.onSurface, // diubah: Menggunakan onSurface
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              loadingMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme
                    .colorScheme.onSurface, // diubah: Menggunakan onSurface
              ),
            ),
          ],
        ),
      ),
    );
  }
}

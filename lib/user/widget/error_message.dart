// path: lib/user/widget/error_message.dart
import 'package:flutter/material.dart';

/// Widget untuk menampilkan pesan error dengan tombol retry.
///
/// Menampilkan ikon error, judul, pesan error, dan tombol "Coba Lagi"
/// yang bisa digunakan untuk mengulangi operasi yang gagal.
class ErrorMessage extends StatelessWidget {
  /// Pesan error yang akan ditampilkan.
  final String message;

  /// Callback yang dipanggil saat tombol "Coba Lagi" ditekan.
  final VoidCallback onRetry;

  /// Membuat instance dari [ErrorMessage].
  ///
  /// [message] adalah pesan error yang akan ditampilkan ke pengguna.
  /// [onRetry] adalah fungsi yang dipanggil saat pengguna menekan tombol retry.
  const ErrorMessage({super.key, required this.message, required this.onRetry});

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

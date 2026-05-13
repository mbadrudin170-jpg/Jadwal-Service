import 'package:flutter/material.dart';

/// Widget untuk menampilkan indikator loading dengan pesan opsional.
class LoadingWidget extends StatelessWidget {
  /// Pesan yang ditampilkan di bawah indikator loading.
  final String message;

  /// Membuat widget [LoadingWidget] dengan [message] opsional.
  ///
  /// Default [message] adalah 'Memuat...'.
  const LoadingWidget({super.key, this.message = 'Memuat...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

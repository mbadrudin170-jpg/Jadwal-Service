// path: lib/user/widget/data_not_found.dart
import 'package:flutter/material.dart';

/// Widget untuk menampilkan pesan data tidak ditemukan.
///
/// Menampilkan ikon warning, judul "Whoops!", dan pesan bahwa data
/// tidak ditemukan.
class DataNotFound extends StatelessWidget {
  /// Pesan yang akan ditampilkan kepada pengguna.
  final String message;

  /// Membuat instance dari [DataNotFound].
  ///
  /// [message] adalah pesan yang menjelaskan mengapa data tidak ditemukan.
  const DataNotFound({super.key, required this.message});

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning,
            size: 60,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Whoops!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

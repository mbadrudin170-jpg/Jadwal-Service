// path: lib/admin/halaman/widget/info_tambahan.dart
import 'package:flutter/material.dart';

/// Sebuah widget untuk menampilkan informasi tambahan dengan label dan nilai.
class InfoTambahan extends StatelessWidget {
  /// Label dari informasi.
  final String label;
  /// Nilai dari informasi.
  final String value;

  /// Membuat sebuah widget [InfoTambahan].
  const InfoTambahan({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

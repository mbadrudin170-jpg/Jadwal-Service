// path: lib/admin/halaman/widget/box_info.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';

/// Sebuah widget untuk menampilkan informasi dalam sebuah kotak.
class BoxInfo extends StatelessWidget {
  /// Membuat sebuah widget [BoxInfo].
  const BoxInfo({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  /// Judul dari kotak informasi.
  final String title;

  /// Nilai yang akan ditampilkan.
  final String value;

  /// Ikon yang akan ditampilkan.
  final IconData icon;

  /// Warna dari kotak dan ikon.
  final Color color;

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          gapH16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

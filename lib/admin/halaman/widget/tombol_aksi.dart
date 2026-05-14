// path: lib/admin/halaman/widget/tombol_aksi.dart
import 'package:flutter/material.dart';

/// Sebuah widget tombol dengan ikon dan label.
class TombolAksi extends StatelessWidget {
  /// Label dari tombol.
  final String label;
  /// Ikon yang akan ditampilkan di tombol.
  final IconData icon;
  /// Fungsi yang akan dipanggil saat tombol ditekan.
  final VoidCallback onPressed;

  /// Membuat sebuah widget [TombolAksi].
  const TombolAksi({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}

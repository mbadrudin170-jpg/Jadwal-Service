// path: lib/shared/widget/info_ringkasan_widget.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Membangun widget ringkasan informasi dengan label dan jumlah yang diformat.
///
/// Menampilkan [label] di atas dan [jumlah] di bawah dengan [warna] tertentu.
/// [alignment] mengatur perataan kolom (default: center).
/// [textKey] dapat digunakan untuk memberikan key khusus pada teks jumlah.
Widget bangunInfoRingkasan({
  required final BuildContext context,
  required final String label,
  required final double jumlah,
  required final Color warna,
  final CrossAxisAlignment alignment = CrossAxisAlignment.center,
  final Key? textKey,
}) {
  return Column(
    crossAxisAlignment: alignment,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(
        FormatUang.formatMataUang(jumlah),
        // diubah: Menggunakan `textKey` jika tersedia.
        key: textKey ?? ValueKey(label),
        style: TextStyle(
          color: warna,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}

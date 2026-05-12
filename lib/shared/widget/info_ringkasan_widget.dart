// path: lib/widget/info_ringkasan_widget.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/utils/format_util.dart';

// diubah: Menambahkan parameter `textKey` opsional.
Widget bangunInfoRingkasan({
  required BuildContext context,
  required String label,
  required double jumlah,
  required Color warna,
  CrossAxisAlignment alignment = CrossAxisAlignment.center,
  Key? textKey, // ditambahkan: Parameter `textKey` opsional.
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

// path lib/shared/widget/summary_info_widget.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Membangun widget ringkasan informasi dengan label dan jumlah yang diformat.
///
/// Menampilkan [label] di atas dan [amount] di bawah dengan [color] tertentu.
/// [alignment] mengatur perataan kolom (default: center).
/// [textKey] dapat digunakan untuk memberikan key khusus pada teks jumlah.
Widget buildSummaryInfo({
  required final BuildContext context,
  required final String label,
  required final double amount,
  required final Color color,
  final CrossAxisAlignment alignment = CrossAxisAlignment.center,
  final Key? textKey,
}) {
  return Column(
    crossAxisAlignment: alignment,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      gapH4,
      Text(
        FormatUang.formatMataUang(amount),
        key: textKey ?? ValueKey(label),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}

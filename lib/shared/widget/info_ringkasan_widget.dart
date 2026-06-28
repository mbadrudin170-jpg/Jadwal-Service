// path lib/shared/widget/info_ringkasan_widget.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class InfoRingkasanWidget extends StatelessWidget {
  final String label;
  final double jumlah;
  final Color color;
  final CrossAxisAlignment crossAxisAlignment;
  final Key? kunciTeks;

  const InfoRingkasanWidget({
    super.key,
    required this.label,
    required this.jumlah,
    required this.color,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.kunciTeks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        gapH4,
        Text(
          FormatUang.formatMataUang(jumlah),
          key: kunciTeks ?? ValueKey(label),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

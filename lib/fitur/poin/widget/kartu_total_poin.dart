// path lib/fitur/poin/widget/kartu_total_poin.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class KartuTotalPoin extends StatelessWidget {
  final int poin;
  final IconData icon;
  final Color warna;
  final VoidCallback? onTap;

  const KartuTotalPoin({
    super.key,
    required this.poin,
    this.icon = TIcons.points,
    this.warna = TColors.pointColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [warna, Color.lerp(warna, Colors.black, 0.25)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: warna.withAlpha(77),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withAlpha(26),
            highlightColor: Colors.white.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(26),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  gapW20,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Poin',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white.withAlpha(204),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      gapH4,
                      Text(
                        FormatNomor.formatRibuan(poin),
                        style: textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

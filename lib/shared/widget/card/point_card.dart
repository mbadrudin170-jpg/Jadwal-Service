// path: lib/shared/widget/card/point_card.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Kartu yang menampilkan total poin pengguna.
///
/// Menampilkan ikon, label "Total Poin", dan jumlah poin.
/// Mendukung [onTap] opsional untuk aksi saat kartu ditekan.
class TotalPointCard extends StatelessWidget {
  /// Jumlah poin yang ditampilkan.
  final int points;

  /// Ikon yang ditampilkan di depan kartu.
  final IconData icon;

  /// Warna tema untuk ikon dan efek bayangan.
  final Color themeColor;

  /// Callback opsional saat kartu ditekan.
  final VoidCallback? onTap;

  /// Membuat kartu total poin.
  /// [points] wajib diisi. [icon], [themeColor], dan [onTap] bersifat opsional.
  const TotalPointCard({
    super.key,
    required this.points,
    this.icon = AppIcons.points,
    this.themeColor = AppColors.pointColor,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    final formattedPoints = NumberFormatter.formatWithSeparator(points);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          splashColor: themeColor.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Poin', // ✅ Petik satu
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formattedPoints,
                      style: const TextStyle(
                        fontSize: 22,
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
    );
  }
}

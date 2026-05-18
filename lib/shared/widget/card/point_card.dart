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
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        // Latar belakang gradien untuk nuansa modern.
        gradient: LinearGradient(
          colors: [
            themeColor,
            Color.lerp(themeColor, Colors.black, 0.25)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        // Bayangan berlapis untuk efek kedalaman yang lebih halus.
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(77), // Menggunakan withAlpha
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(38), // Menggunakan withAlpha
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      // Menggunakan ClipRRect agar efek splash InkWell mengikuti border radius.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withAlpha(26), // Menggunakan withAlpha
            highlightColor: Colors.white.withAlpha(13), // Menggunakan withAlpha
            child: Padding(
              // Padding yang lebih luas untuk ruang napas.
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon dengan efek 'glow' ringan.
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26), // Menggunakan withAlpha
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(26), // Menggunakan withAlpha
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white, // Ikon putih agar kontras.
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Poin',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white.withAlpha(204), // Menggunakan withAlpha
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedPoints,
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

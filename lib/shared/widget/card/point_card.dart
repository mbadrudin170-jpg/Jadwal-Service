// path: lib/shared/widget/card/point_card.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_colors.dart';

class TotalPointCard extends StatelessWidget {
  final int points;
  final IconData icon;
  final Color themeColor;
  final VoidCallback? onTap; // Fungsi yang akan dijalankan saat diklik

  const TotalPointCard({
    super.key,
    required this.points,
    this.icon = Icons.stars_rounded,
    this.themeColor = AppColors.pointColor,
    this.onTap, // Dibuat opsional agar fleksibel
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Bungkus dengan Material agar efek InkWell terlihat
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // ClipRRect memastikan efek ripple tidak keluar dari border radius kartu
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap, // Menghubungkan parameter onTap
          splashColor: themeColor.withAlpha(20), // Warna saat ditekan
          highlightColor: Colors.transparent,
          child: Padding(
            // Pindahkan padding dari Container ke sini agar seluruh area padding bisa diklik
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Biasanya lebih rapi rata kiri
                  children: [
                    const Text(
                      "Total Poin",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      points.toString(),
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

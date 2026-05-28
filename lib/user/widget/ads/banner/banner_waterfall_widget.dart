// path: lib/user/widget/ads/banner/banner_waterfall_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// Widget yang memuat satu unit iklan banner berdasarkan ID yang diberikan.
/// Jika gagal memuat, widget akan mencoba memuat ulang ID yang sama
/// setelah jeda waktu tertentu.
class BannerWaterfallWidget extends StatefulWidget {
  /// ID unit iklan banner yang akan dimuat.
  final String adUnitId;

  const BannerWaterfallWidget({
    super.key,
    required this.adUnitId,
  });
  @override
  State<BannerWaterfallWidget> createState() => _BannerWaterfallWidgetState();
}

class _BannerWaterfallWidgetState extends State<BannerWaterfallWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    unawaited(_bannerAd?.dispose());
    super.dispose();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (final ad) {
          Log.info('Banner Ad berhasil dimuat', {'ad': ad.toString()});
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (final ad, final error) {
          Log.error(
            'Gagal memuat Banner Ad',
            e: error,
            data: {'adUnitId': widget.adUnitId, 'ad': ad.toString()},
          );
          unawaited(ad.dispose());
        },
      ),
    );
    unawaited(_bannerAd!.load());
  }

  @override
  Widget build(final BuildContext context) {
    if (_bannerAd != null && _isAdLoaded) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

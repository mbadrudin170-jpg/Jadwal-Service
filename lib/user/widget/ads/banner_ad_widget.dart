// path: lib/user/widget/ads/banner_ad_widget.dart
// diubah: Menghilangkan placeholder SizedBox saat iklan tidak ada.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// Widget untuk menampilkan banner iklan Google Mobile Ads.
///
/// Widget ini mengelola siklus hidup banner ad, termasuk loading,
/// error handling, dan retry otomatis jika gagal load.
class BannerAdWidget extends StatefulWidget {
  /// Unit ID iklan yang akan ditampilkan.
  final String adUnitId;

  /// Membuat instance dari [BannerAdWidget].
  ///
  /// [adUnitId] adalah ID unit iklan dari Google AdMob.
  const BannerAdWidget({
    super.key,
    required this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadBanner());
  }

  @override
  void didUpdateWidget(covariant final BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.adUnitId != widget.adUnitId) {
      Log.info('Ad unit ID changed. Reloading banner.');
      unawaited(_disposeBanner());
      unawaited(_loadBanner());
    }
  }

  Future<void> _loadBanner() async {
    Log.api('/banner_ad', {'adUnitId': widget.adUnitId}, method: 'LOAD');
    _isLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (final ad) {
          if (!mounted) return;
          Log.info('Banner ad loaded successfully.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (final ad, final error) async {
          Log.error(
            'Banner ad failed to load',
            e: error,
            data: {
              'adUnitId': widget.adUnitId,
              'errorCode': error.code,
              'errorMessage': error.message,
            },
          );
          await ad.dispose();
          _bannerAd = null;

          // optional: retry ringan
          unawaited(
            Future.delayed(const Duration(seconds: 3), () async {
              if (mounted) await _loadBanner();
            }),
          );
        },
      ),
    );

    await _bannerAd!.load();
  }

  Future<void> _disposeBanner() async {
    Log.info('Disposing banner ad.');
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  Widget build(final BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    unawaited(_disposeBanner());
    super.dispose();
  }
}

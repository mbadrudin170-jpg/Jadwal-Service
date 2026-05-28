// path: lib/user/widget/ads/banner/banner_ads_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/banner/id_banner_ads.dart';

/// Widget yang memuat satu unit iklan banner berdasarkan ID yang diberikan.
class BannerAdsWidget extends StatefulWidget {
  const BannerAdsWidget({
    super.key,
  });
  @override
  State<BannerAdsWidget> createState() => _BannerAdsWidgetState();
}

class _BannerAdsWidgetState extends State<BannerAdsWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final String adUnitId = IdBannerAds.prodBannerAdMediasi1;

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
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (final ad) {
          Log.info('''Banner Ad berhasil dimuat''', {'''ad''': ad.toString()});
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (final ad, final error) {
          Log.error(
            '''Gagal memuat Banner Ad''',
            e: error,
            data: {'''adUnitId''': adUnitId, '''ad''': ad.toString()},
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
      return SafeArea(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

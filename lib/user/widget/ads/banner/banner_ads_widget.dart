// path: lib/user/widget/ads/banner/banner_ads_widget.dart

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
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    Log.info('Memulai memuat Banner Ad...', {'adUnitId': adUnitId});
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Log.info('Banner Ad berhasil dimuat', {'ad': ad.toString()});
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          Log.error(
            'Gagal memuat Banner Ad',
            e: error,
            data: {'adUnitId': adUnitId, 'ad': ad.toString()},
          );
          ad.dispose();
        },
      ),
    )..load();
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
      // Mengembalikan container kosong jika iklan belum siap
      return const SizedBox.shrink();
    }
  }
}

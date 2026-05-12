// path: lib/widget/ads/banner_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;

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
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.adUnitId != widget.adUnitId) {
      Log.info('Ad unit ID changed. Reloading banner.');
      _disposeBanner();
      _loadBanner();
    }
  }

  void _loadBanner() {
    Log.api('/banner_ad', {'adUnitId': widget.adUnitId}, method: 'LOAD');
    _isLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          Log.info('Banner ad loaded successfully.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          Log.error(
            'Banner ad failed to load',
            e: error,
            data: {
              'adUnitId': widget.adUnitId,
              'errorCode': error.code,
              'errorMessage': error.message,
            },
          );
          ad.dispose();
          _bannerAd = null;

          // optional: retry ringan
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _loadBanner();
          });
        },
      ),
    );

    _bannerAd!.load();
  }

  void _disposeBanner() {
    Log.info('Disposing banner ad.');
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 50, // stabil biar UI gak loncat
      );
    }

    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }
}

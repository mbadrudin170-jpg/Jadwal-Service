// path: lib/widget/ads/banner_ad_widget.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
      developer.log(
        '[ banner_ad_widget.dart ] [didUpdateWidget] : Ad unit ID changed. Reloading banner.',
        name: 'BannerAd',
      );
      _disposeBanner();
      _loadBanner();
    }
  }

  void _loadBanner() {
    developer.log(
      '[ banner_ad_widget.dart ] [_loadBanner] : Loading banner ad with ID: ${widget.adUnitId}',
      name: 'BannerAd',
    );
    _isLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          developer.log(
            '[ banner_ad_widget.dart ] [onAdLoaded] : Banner ad loaded successfully.',
            name: 'BannerAd',
          );
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          developer.log(
            '[ banner_ad_widget.dart ] [onAdFailedToLoad] : Banner ad failed to load: $error',
            name: 'BannerAd',
            error: error,
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
    developer.log(
      '[ banner_ad_widget.dart ] [_disposeBanner] : Disposing banner ad.',
      name: 'BannerAd',
    );
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

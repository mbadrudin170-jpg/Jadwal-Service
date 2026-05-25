// path: lib/user/widget/ads/banner/banner_waterfall_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/banner/id_banner_ads.dart'; // Diperbarui

/// Sebuah widget yang mencoba memuat beberapa unit iklan banner secara siklus dan berurutan.
class BannerWaterfallWidget extends StatefulWidget {
  /// Jeda waktu sebelum mencoba memuat unit iklan berikutnya setelah kegagalan.
  final Duration retryDelay;

  const BannerWaterfallWidget({
    super.key,
    this.retryDelay = const Duration(seconds: 30),
  });

  @override
  State<BannerWaterfallWidget> createState() => _BannerWaterfallWidgetState();
}

class _BannerWaterfallWidgetState extends State<BannerWaterfallWidget> {
  // Mengambil daftar ID langsung dari class IdBannerAds
  final List<String> _adUnitIds = IdBannerAds.bannerAdUnitIds;

  BannerAd? _bannerAd;
  int _currentAdIndex = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadAd();
      }
    });
  }

  void _loadAd() {
    if (_bannerAd != null || _adUnitIds.isEmpty) return;

    final adUnitId = _adUnitIds[_currentAdIndex];
    Log.info(
        '[Waterfall] Mencoba memuat banner #${_currentAdIndex}: $adUnitId');

    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Log.info('[Waterfall] Banner #${_currentAdIndex} BERHASIL dimuat.');
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          Log.error(
            '[Waterfall] Banner #${_currentAdIndex} GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          ad.dispose();

          _currentAdIndex = (_currentAdIndex + 1) % _adUnitIds.length;

          _retryTimer?.cancel();
          _retryTimer = Timer(widget.retryDelay, () {
            if (mounted) {
              _loadAd();
            }
          });
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null) {
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

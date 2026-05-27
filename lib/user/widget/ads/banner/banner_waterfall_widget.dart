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

  /// Jeda waktu sebelum mencoba memuat ulang iklan yang sama setelah gagal.
  final Duration retryDelay;

  const BannerWaterfallWidget({
    super.key,
    required this.adUnitId,
    this.retryDelay = const Duration(seconds: 30),
  });

  @override
  State<BannerWaterfallWidget> createState() => _BannerWaterfallWidgetState();
}

class _BannerWaterfallWidgetState extends State<BannerWaterfallWidget> {
  BannerAd? _bannerAd;
  Timer? _retryTimer;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(final BannerWaterfallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adUnitId != oldWidget.adUnitId) {
      Log.info('ID Iklan berubah, memuat ulang iklan baru.',
          {'oldId': oldWidget.adUnitId, 'newId': widget.adUnitId});

      unawaited(_bannerAd?.dispose());
      _bannerAd = null;
      _isAdLoaded = false;
      _retryTimer?.cancel();
      _loadAd();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    unawaited(_bannerAd?.dispose());
    super.dispose();
  }

  void _loadAd() {
    if (widget.adUnitId.isEmpty) {
      Log.warning('adUnitId kosong, proses pemuatan iklan dibatalkan.');
      return;
    }

    Log.info('Memulai memuat Banner Ad', {'adUnitId': widget.adUnitId});

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (final Ad ad) {
          Log.info('Banner Ad berhasil dimuat', {'ad': ad.toString()});
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (final Ad ad, final LoadAdError error) {
          Log.error(
            'Gagal memuat Banner Ad',
            e: error,
            data: {'adUnitId': widget.adUnitId, 'ad': ad.toString()},
          );
          unawaited(ad.dispose());
          _scheduleRetry();
        },
      ),
    );
    unawaited(_bannerAd?.load());
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(widget.retryDelay, () {
      Log.info('Mencoba memuat ulang Banner Ad setelah jeda.',
          {'adUnitId': widget.adUnitId});
      if (mounted) {
        _loadAd();
      }
    });
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

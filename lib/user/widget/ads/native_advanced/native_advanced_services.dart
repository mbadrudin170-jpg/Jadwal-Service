// path: lib/user/widget/ads/ native_advanced/native_advanced_services.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/native_advanced/id_%20native_advanced_ads.dart';

/// Sebuah widget yang mencoba memuat beberapa unit iklan Native Advanced secara siklus dan berurutan.
class NativeAdvancedWaterfallWidget extends StatefulWidget {
  /// Jeda waktu sebelum mencoba memuat unit iklan berikutnya setelah kegagalan.
  final Duration retryDelay;

  const NativeAdvancedWaterfallWidget({
    super.key,
    this.retryDelay = const Duration(seconds: 30),
  });

  @override
  State<NativeAdvancedWaterfallWidget> createState() =>
      _NativeAdvancedWaterfallWidgetState();
}

class _NativeAdvancedWaterfallWidgetState
    extends State<NativeAdvancedWaterfallWidget> {
  final List<String> _adUnitIds = IdNativeAdvancedAds.nativeAdvancedAdUnitIds;

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  int _currentAdIndex = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadAd();
      }
    });
  }

  void _loadAd() {
    if (_isAdLoaded || _adUnitIds.isEmpty) return;

    final adUnitId = _adUnitIds[_currentAdIndex];
    Log.info(
        '[Waterfall] Mencoba memuat Native Ad #${_currentAdIndex}: $adUnitId');

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      // Gunakan factoryId default atau custom. 'listTile' adalah contoh umum.
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          Log.info(
              '[Waterfall] Native Ad #${_currentAdIndex} BERHASIL dimuat.');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          Log.error(
            '[Waterfall] Native Ad #${_currentAdIndex} GAGAL dimuat.',
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
    )..load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _nativeAd != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320, // Lebar minimal
          minHeight: 100, // Tinggi minimal
          maxWidth: 400,
          maxHeight: 120,
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

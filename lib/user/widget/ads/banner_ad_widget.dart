// path: lib/user/widget/ads/banner_ad_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// Widget untuk menampilkan banner iklan Google Mobile Ads (dengan mediasi).
class BannerAdWidget extends StatefulWidget {
  /// Unit ID iklan yang akan ditampilkan.
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
  Timer? _retryTimer; // Solusi Kebocoran Memori: Untuk membatalkan auto-retry jika widget di-dispose

  @override
  void initState() {
    super.initState();
    unawaited(_loadBanner());
  }

  @override
  void didUpdateWidget(covariant final BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.adUnitId != widget.adUnitId) {
      Log.info('Ad unit ID changed. Re-initializing banner.');
      // Batalkan timer retry lama jika ada
      _retryTimer?.cancel();
      
      // Jalankan fungsi dispose secara sekuensial sebelum memuat yang baru
      _disposeBanner().then((_) {
        if (mounted) unawaited(_loadBanner());
      });
    }
  }

  Future<void> _loadBanner() async {
    // Pastikan timer retry sebelumnya dibersihkan sebelum memuat ulang
    _retryTimer?.cancel();

    if (widget.adUnitId.isEmpty) {
      Log.error('Banner ad failed to load: adUnitId is empty');
      return;
    }

    Log.api('/banner_ad', {'adUnitId': widget.adUnitId}, method: 'LOAD');
    _isLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (final ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          Log.info('Banner ad loaded successfully via Mediation.');
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
          
          if (!mounted) return;
          
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });

          // Menggunakan Timer yang bisa dibatalkan jika widget dihancurkan
          _retryTimer = Timer(const Duration(seconds: 30), () {
            if (mounted) unawaited(_loadBanner());
          });
        },
      ),
    );

    await _bannerAd!.load();
  }

  Future<void> _disposeBanner() async {
    Log.info('Disposing banner ad resource.');
    _retryTimer?.cancel();
    await _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) {
      setState(() {
        _isLoaded = false;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    // Memastikan objek iklan dan status sinkron sebelum merender UI
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _retryTimer?.cancel(); // Pastikan timer dibatalkan saat berpindah halaman
    unawaited(_disposeBanner());
    super.dispose();
  }
}

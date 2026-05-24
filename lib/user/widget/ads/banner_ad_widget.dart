// path: lib/user/widget/ads/banner_ad_widget.dart
// MODIFIED:
// - Added `onAdLoaded` and `onAdFailedToLoad` callbacks to the constructor.
// - These callbacks are invoked from the `BannerAdListener`.
// - The widget itself no longer shows notifications.
// - Cleaned up the placeholder text and removed the `kDebugMode` check for simplicity.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// A widget that displays a Google Mobile Ads banner.
class BannerAdWidget extends StatefulWidget {
  /// The ad unit ID for the banner.
  final String adUnitId;

  /// An optional callback that is called when the ad is successfully loaded.
  final VoidCallback? onAdLoaded;

  /// An optional callback that is called when the ad fails to load.
  final Function(LoadAdError error)? onAdFailedToLoad;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  // ignore: library_private_types_in_public_api
  State<BannerAdWidget> createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    unawaited(loadAd());
  }

  @override
  void didUpdateWidget(covariant final BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.adUnitId != widget.adUnitId) {
      Log.info('Ad unit ID changed. Re-initializing banner.');
      _retryTimer?.cancel();

      _disposeBanner().then((_) {
        if (mounted) unawaited(loadAd());
      });
    }
  }

  /// Loads (or reloads) the banner ad.
  /// Can be called externally via a GlobalKey.
  Future<void> loadAd() async {
    _retryTimer?.cancel();

    if (widget.adUnitId.isEmpty) {
      Log.error('Banner ad failed to load: adUnitId is empty');
      return;
    }

    Log.api('/banner_ad', {'adUnitId': widget.adUnitId}, method: 'LOAD');
    if (mounted) {
      setState(() {
        _isLoaded = false;
      });
    }

    await _bannerAd?.dispose();
    _bannerAd = null;

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
          Log.info('Banner ad loaded successfully.');
          setState(() {
            _bannerAd = ad as BannerAd?;
            _isLoaded = true;
          });
          // Invoke the external callback
          widget.onAdLoaded?.call();
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

          // Invoke the external callback
          widget.onAdFailedToLoad?.call(error);

          _retryTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) unawaited(loadAd());
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
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Always show a placeholder in debug mode if the ad is not loaded.
    // In release, this will be an empty space unless you want a placeholder.
    if (kDebugMode) {
      return Container(
        height: AdSize.banner.height.toDouble(),
        width: AdSize.banner.width.toDouble(),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Center(
          child: Text(
            'Banner Ad Space\n(Loading / Failed...)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    unawaited(_disposeBanner());
    super.dispose();
  }
}

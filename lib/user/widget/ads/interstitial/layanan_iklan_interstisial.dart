import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

class LayananIklanInterstisial {
  InterstitialAd? _interstitialAd;
  bool _isPreloading = false;
  bool _isAdLoaded = false;
  final _idIklan = IdInterstitialAds.interstitialAdUnitIdMediasi;

  Future<void> preloadAd() async {
    if (kDebugMode) {
      Log.info('[InterstitialAd] Debug mode: Melewati preload iklan.');
      return;
    }
    if (_isAdLoaded || _isPreloading) {
      Log.info(
        '[InterstitialAd] Pemuatan dibatalkan (iklan sudah siap atau sedang dimuat).',
      );
      return;
    }

    _isPreloading = true;
    Log.info('[InterstitialAd] Memulai memuat iklan...');

    await InterstitialAd.load(
      adUnitId: _idIklan,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info('[InterstitialAd] Iklan BERHASIL dimuat.');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isPreloading = false;
        },
        onAdFailedToLoad: (e) {
          Log.error(
            '[InterstitialAd] Iklan GAGAL dimuat.',
            e: e,
            data: {'adUnitId': _idIklan},
          );
          _interstitialAd = null;
          _isAdLoaded = false;
          _isPreloading = false;
        },
      ),
    );
  }

  Future<void> show() async {
    if (kDebugMode) {
      Log.info('[InterstitialAd] Debug mode: Melewati menampilkan iklan.');
      return;
    }
    if (_interstitialAd != null && _isAdLoaded) {
      Log.info('[InterstitialAd] Iklan sudah siap, mencoba menampilkan...');

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          Log.info('[InterstitialAd] Iklan berhasil ditampilkan.');
        },
        onAdDismissedFullScreenContent: (ad) {
          Log.info('[InterstitialAd] Iklan ditutup, memuat yang baru.');
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          unawaited(preloadAd());
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          Log.error('[InterstitialAd] Gagal menampilkan iklan.', e: error);
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          unawaited(preloadAd());
        },
      );
      await _interstitialAd!.show();
    } else {
      Log.warning('[InterstitialAd] Gagal menampilkan: Iklan belum siap.');
      unawaited(preloadAd());
    }
  }

  void dispose() {
    Log.info('[InterstitialAd] Service di-dispose, membuang iklan.');
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

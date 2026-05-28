// path: lib/user/widget/ads/interstitial/interstitial_ad_service.dart
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Service singleton untuk mengelola dan menampilkan iklan Interstitial.
class InterstitialAdService {
  // --- State Iklan ---
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  final _adUnitId = IdInterstitialAds.interstitialAdUnitIdMediasi;

  /// Memulai proses pemuatan iklan di latar belakang.
  /// Metode ini aman untuk dipanggil beberapa kali; ia akan mencegah pemuatan ganda.
  Future<void> preloadAd() async {
    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final ad) {
          Log.info('[InterstitialAd] Iklan BERHASIL dimuat.');
          _interstitialAd = ad;
          _isAdLoading = true;
        },
        onAdFailedToLoad: (final error) {
          Log.error(
            '[InterstitialAd] Iklan GAGAL dimuat.',
            e: error,
            data: {'adUnitId': _adUnitId},
          );
          _isAdLoading = false; // Hentikan proses jika gagal
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap. Setelah ditampilkan, iklan akan dibuang
  /// dan iklan baru akan dimuat secara otomatis di latar belakang.
  ///
  Future<void> showAdIfReady() async {
    if (_interstitialAd != null && _isAdLoading) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (final ad) {
          Log.info('[InterstitialAd] Iklan ditampilkan.');
        },
        onAdDismissedFullScreenContent: (final ad) {
          Log.info('[InterstitialAd] Iklan ditutup, memuat yang baru.');
          // [WAJIB] Buang iklan yang sudah ditampilkan.
          unawaited(ad.dispose());
          _isAdLoading = false;
          unawaited(preloadAd());
        },
        onAdFailedToShowFullScreenContent: (final ad, final error) {
          Log.error('[InterstitialAd] Gagal menampilkan iklan.', e: error);
          unawaited(ad.dispose());
          _isAdLoading = false;
          unawaited(preloadAd());
        },
      );
    }
    await _interstitialAd!.show();
  }

  /// Membuang sumber daya iklan saat tidak lagi diperlukan.
  void dispose() {
    unawaited(_interstitialAd?.dispose());
  }
}

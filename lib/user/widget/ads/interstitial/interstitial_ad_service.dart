// path: lib/user/widget/ads/interstitial/interstitial_ad_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart'; // Ditambahkan
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Service singleton untuk mengelola dan menampilkan iklan Interstitial dengan logika waterfall.
class InterstitialAdService {
  // --- Singleton Pattern ---
  static final InterstitialAdService _instance =
      InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  // --- State Iklan ---
  InterstitialAd? _interstitialAd;
  int _currentAdIndex = 0;
  bool _isReloading = false;
  Timer? _retryTimer;

  final List<String> _adUnitIds = IdInterstitialAds.interstitialAdUnitIds;

  /// Apakah iklan sedang dimuat (atau dalam proses coba ulang)?
  bool get isAdLoading => _isReloading;

  /// Apakah iklan sudah berhasil dimuat dan siap ditampilkan?
  bool get isAdReady => _interstitialAd != null;

  /// Memulai proses pemuatan iklan pertama di latar belakang.
  /// Panggil ini sekali saat aplikasi dimulai, misalnya di main().
  void preloadAd() {
    if (isAdReady || _isReloading) return;
    _loadNextAd();
  }

  void _loadNextAd() {
    if (_adUnitIds.isEmpty) {
      Log.warning(
          '[InterstitialWaterfall] Tidak ada Ad Unit ID yang tersedia.');
      return;
    }

    _isReloading = true;
    final adUnitId = _adUnitIds[_currentAdIndex];
    Log.info(
        '[InterstitialWaterfall] Mencoba memuat iklan #${_currentAdIndex}: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info(
              '[InterstitialWaterfall] Iklan #${_currentAdIndex} BERHASIL dimuat.');
          _interstitialAd = ad;
          _isReloading = false;
          _retryTimer?.cancel();
          _currentAdIndex = 0; // Reset index setelah berhasil
        },
        onAdFailedToLoad: (error) {
          Log.error(
            '[InterstitialWaterfall] Iklan #${_currentAdIndex} GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          _isReloading = false;
          _interstitialAd = null;

          // Coba ad unit ID berikutnya dalam daftar
          _currentAdIndex = (_currentAdIndex + 1) % _adUnitIds.length;

          // Jadwalkan coba ulang setelah jeda untuk menghindari spam request
          _retryTimer?.cancel();
          _retryTimer = Timer(const Duration(seconds: 30), () {
            preloadAd();
          });
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap, lalu memuat ulang untuk berikutnya.
  /// [onAdDismissed] adalah callback opsional yang dijalankan setelah iklan ditutup.
  void showAdIfReady({VoidCallback? onAdDismissed}) {
    if (!isAdReady) {
      Log.warning(
          '[InterstitialWaterfall] Gagal menampilkan iklan karena belum siap.');
      onAdDismissed?.call(); // Langsung jalankan callback agar alur tidak macet
      if (!_isReloading) {
        preloadAd(); // Coba muat lagi jika tidak sedang dalam proses
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        Log.info('[InterstitialWaterfall] Iklan ditutup.');
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed?.call();
        preloadAd(); // Otomatis muat ulang iklan berikutnya
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error('[InterstitialWaterfall] Gagal menampilkan iklan.',
            data: {'error': error.message});
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed?.call();
        preloadAd(); // Coba muat ulang
      },
    );

    _interstitialAd!.show();
  }

  void dispose() {
    _retryTimer?.cancel();
    _interstitialAd?.dispose();
  }
}

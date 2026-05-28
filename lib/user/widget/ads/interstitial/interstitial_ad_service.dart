// path: lib/user/widget/ads/interstitial/interstitial_ad_service.dart
// DIUBAH: Logika dan state management dirombak total untuk keandalan.

import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Service singleton untuk mengelola dan menampilkan iklan Interstitial secara andal.
class InterstitialAdService {
  // --- State Iklan ---
  InterstitialAd? _interstitialAd;

  // PENJELASAN: _isPreloading digunakan untuk mencegah beberapa panggilan `preloadAd` berjalan bersamaan.
  bool _isPreloading = false;

  // PENJELASAN: _isAdLoaded adalah state yang menandakan apakah iklan sudah dimuat dan siap ditampilkan.
  bool _isAdLoaded = false;

  final _adUnitId = IdInterstitialAds.interstitialAdUnitIdMediasi;

  /// Memulai proses pemuatan iklan di latar belakang.
  /// Metode ini aman untuk dipanggil beberapa kali; ia akan mencegah pemuatan ganda.
  Future<void> preloadAd() async {
    // PENJELASAN: Mencegah pemuatan baru jika sudah ada iklan yang siap atau sedang dalam proses loading.
    if (_isAdLoaded || _isPreloading) {
      Log.info(
          '[InterstitialAd] Pemuatan dibatalkan (iklan sudah siap atau sedang dimuat).');
      return;
    }

    _isPreloading = true;
    Log.info('[InterstitialAd] Memulai memuat iklan...');

    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info('[InterstitialAd] Iklan BERHASIL dimuat.');
          _interstitialAd = ad;
          _isAdLoaded = true; // State diubah menjadi 'siap'
          _isPreloading = false;
        },
        onAdFailedToLoad: (error) {
          Log.error(
            '[InterstitialAd] Iklan GAGAL dimuat.',
            e: error,
            data: {'adUnitId': _adUnitId},
          );
          _interstitialAd = null;
          _isAdLoaded = false;
          _isPreloading = false;
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap. Setelah ditampilkan, iklan akan dibuang
  /// dan iklan baru akan dimuat secara otomatis di latar belakang.
  Future<void> show() async {
    // PENJELASAN: Pemeriksaan utama. Hanya jika _interstitialAd tidak null DAN _isAdLoaded true.
    if (_interstitialAd != null && _isAdLoaded) {
      Log.info('[InterstitialAd] Iklan sudah siap, mencoba menampilkan...');

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          Log.info('[InterstitialAd] Iklan berhasil ditampilkan.');
        },
        onAdDismissedFullScreenContent: (ad) {
          Log.info('[InterstitialAd] Iklan ditutup, memuat yang baru.');
          // [WAJIB] Buang iklan yang sudah ditampilkan dan reset state.
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          // Langsung muat iklan baru untuk permintaan selanjutnya.
          unawaited(preloadAd());
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          Log.error('[InterstitialAd] Gagal menampilkan iklan.', e: error);
          // Buang iklan yang gagal tampil dan reset state.
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          unawaited(preloadAd());
        },
      );

      // PENJELASAN: Pemanggilan .show() sekarang aman karena berada di dalam blok `if`.
      await _interstitialAd!.show();
    } else {
      Log.warning('[InterstitialAd] Gagal menampilkan: Iklan belum siap.');
      // Jika tidak siap, coba muat lagi untuk kesempatan berikutnya. Tidak perlu menunggu (no await).
      unawaited(preloadAd());
    }
  }

  /// Membuang sumber daya iklan saat tidak lagi diperlukan.
  void dispose() {
    Log.info('[InterstitialAd] Service di-dispose, membuang iklan.');
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

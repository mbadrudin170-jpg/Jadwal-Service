// path: lib/user/widget/ads/interstitial/interstitial_ad_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// Service singleton untuk mengelola dan menampilkan iklan Interstitial.
class InterstitialAdService {
  // --- Singleton Pattern ---
  static final InterstitialAdService _instance = InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  // --- State Iklan ---
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  /// Apakah iklan sudah berhasil dimuat dan siap ditampilkan?
  bool get isAdReady => _interstitialAd != null;

  /// Apakah iklan sedang dalam proses pengunduhan?
  bool get isAdLoading => _isAdLoading;

  /// Memulai proses pemuatan iklan di latar belakang.
  /// Metode ini aman untuk dipanggil beberapa kali; ia akan mencegah pemuatan ganda.
  Future<void> preloadAd({required final String adUnitId}) async {
    // Jangan memuat jika iklan sudah siap, sedang dimuat, atau ID kosong.
    if (adUnitId.isEmpty) {
      Log.warning('[InterstitialAd] Ad Unit ID tidak boleh kosong.');
      return;
    }
    if (isAdReady || _isAdLoading) {
      return;
    }

    _isAdLoading = true;

    Log.info('[InterstitialAd] Mencoba memuat iklan dengan ID: $adUnitId');

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final ad) {
          Log.info('[InterstitialAd] Iklan BERHASIL dimuat.');
          _interstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (final error) {
          Log.error(
            '[InterstitialAd] Iklan GAGAL dimuat.',
            e: error,
            data: {'adUnitId': adUnitId},
          );
          _isAdLoading = false; // Hentikan proses jika gagal
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap. Setelah ditampilkan, iklan akan dibuang
  /// dan iklan baru akan dimuat secara otomatis di latar belakang.
  ///
  /// [onAdDismissed] adalah callback yang dijalankan setelah iklan ditutup.
  Future<void> showAdIfReady({
    required final String adUnitId,
    final VoidCallback? onAdDismissed,
  }) async {
    if (!isAdReady) {
      Log.warning(
          '[InterstitialAd] Gagal menampilkan iklan karena belum siap.');
      // Jika tidak siap, coba muat lagi di latar belakang untuk kesempatan berikutnya.
      unawaited(preloadAd(adUnitId: adUnitId));
      // Langsung jalankan callback agar alur aplikasi tidak terhenti.
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (final ad) {
        Log.info('[InterstitialAd] Iklan ditampilkan.');
      },
      onAdDismissedFullScreenContent: (final ad) {
        Log.info('[InterstitialAd] Iklan ditutup, memuat yang baru.');
        // [WAJIB] Buang iklan yang sudah ditampilkan.
        unawaited(ad.dispose());
        _interstitialAd = null;
        // Panggil callback setelah semua proses internal selesai.
        onAdDismissed?.call();
        // [WAJIB] Muat iklan baru untuk permintaan berikutnya.
        unawaited(preloadAd(adUnitId: adUnitId));
      },
      onAdFailedToShowFullScreenContent: (final ad, final error) {
        Log.error('[InterstitialAd] Gagal menampilkan iklan.', e: error);
        // Buang iklan yang gagal tampil.
        unawaited(ad.dispose());
        _interstitialAd = null;
        onAdDismissed?.call();
        // Coba muat ulang karena yang sebelumnya gagal.
        unawaited(preloadAd(adUnitId: adUnitId));
      },
    );

    await _interstitialAd!.show();
  }

  /// Membuang sumber daya iklan saat tidak lagi diperlukan.
  void dispose() {
    unawaited(_interstitialAd?.dispose());
    _interstitialAd = null;
  }
}

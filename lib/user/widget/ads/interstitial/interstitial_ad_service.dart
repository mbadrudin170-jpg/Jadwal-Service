// path: lib/user/widget/ads/interstitial/interstitial_ad_service.dart
// DIUBAH: Menghapus ConsentManager dan semua logika terkait GDPR.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Service singleton untuk mengelola dan menampilkan iklan Interstitial.
/// Menggunakan strategi waterfall untuk memaksimalkan ketersediaan iklan.
class InterstitialAdService {
  // --- Singleton Pattern ---
  static final InterstitialAdService _instance =
      InterstitialAdService._internal();
  factory InterstitialAdService() => _instance;
  InterstitialAdService._internal();

  // --- State Iklan ---
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  final List<String> _adUnitIds = IdInterstitialAds.interstitialAdUnitIds;

  /// Apakah iklan sudah berhasil dimuat dan siap ditampilkan?
  bool get isAdReady => _interstitialAd != null;

  /// Memulai proses pemuatan iklan di latar belakang.
  /// Metode ini aman untuk dipanggil beberapa kali; ia akan mencegah pemuatan ganda.
  void preloadAd() {
    // Jangan memuat jika iklan sudah siap, sedang dimuat, atau daftar ID kosong.
    if (isAdReady || _isAdLoading || _adUnitIds.isEmpty) {
      return;
    }

    _isAdLoading = true;
    _loadWithWaterfall(0); // Mulai proses waterfall dari indeks pertama
  }

  Future<void> _loadWithWaterfall(int adIndex) async {
    // Jika sudah mencoba semua ID, tunggu sebelum memulai ulang siklus.
    if (adIndex >= _adUnitIds.length) {
      Log.warning(
          '[InterstitialWaterfall] Semua unit iklan gagal. Mencoba lagi dalam 30 detik.');
      _isAdLoading = false;
      // Tidak perlu timer di sini, cukup panggil preloadAd() lagi nanti saat diperlukan
      return;
    }

    final adUnitId = _adUnitIds[adIndex];
    Log.info(
        '[InterstitialWaterfall] Mencoba memuat iklan #${adIndex}: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info(
              '[InterstitialWaterfall] Iklan #${adIndex} BERHASIL dimuat.');
          _interstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          Log.error(
            '[InterstitialWaterfall] Iklan #${adIndex} GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          // Langsung coba unit iklan berikutnya tanpa jeda.
          _loadWithWaterfall(adIndex + 1);
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap. Setelah ditampilkan, iklan akan dibuang
  /// dan iklan baru akan dimuat secara otomatis di latar belakang.
  ///
  /// [onAdDismissed] adalah callback yang dijalankan setelah iklan ditutup.
  void showAdIfReady({VoidCallback? onAdDismissed}) {
    if (!isAdReady) {
      Log.warning(
          '[InterstitialWaterfall] Gagal menampilkan iklan karena belum siap.');
      // Jika tidak siap, coba muat lagi di latar belakang untuk kesempatan berikutnya.
      preloadAd();
      // Langsung jalankan callback agar alur aplikasi tidak terhenti.
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) =>
          Log.info('[InterstitialWaterfall] Iklan ditampilkan.'),
      onAdDismissedFullScreenContent: (ad) {
        Log.info('[InterstitialWaterfall] Iklan ditutup.');
        // [WAJIB] Buang iklan yang sudah ditampilkan.
        ad.dispose();
        _interstitialAd = null;
        // Panggil callback setelah semua proses internal selesai.
        onAdDismissed?.call();
        // [WAJIB] Muat iklan baru untuk permintaan berikutnya.
        preloadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error('[InterstitialWaterfall] Gagal menampilkan iklan.',
            data: {'error': error.message});
        // Buang iklan yang gagal tampil.
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed?.call();
        // Coba muat ulang karena yang sebelumnya gagal.
        preloadAd();
      },
    );

    _interstitialAd!.show();
  }

  /// Membuang sumber daya iklan saat tidak lagi diperlukan.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

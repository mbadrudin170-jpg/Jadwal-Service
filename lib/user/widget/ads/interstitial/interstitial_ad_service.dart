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
  Future<void> preloadAd() async {
    // Jangan memuat jika iklan sudah siap, sedang dimuat, atau daftar ID kosong.
    if (isAdReady || _isAdLoading || _adUnitIds.isEmpty) {
      return;
    }

    _isAdLoading = true;
    await _loadWithWaterfall(0); // Mulai proses waterfall dari indeks pertama
  }

  Future<void> _loadWithWaterfall(final int adIndex) async {
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
        '[InterstitialWaterfall] Mencoba memuat iklan #$adIndex: $adUnitId');

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final ad) {
          Log.info('[InterstitialWaterfall] Iklan #$adIndex BERHASIL dimuat.');
          _interstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (final error) async {
          Log.error(
            '[InterstitialWaterfall] Iklan #$adIndex GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          // Langsung coba unit iklan berikutnya tanpa jeda.
          await _loadWithWaterfall(adIndex + 1);
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap. Setelah ditampilkan, iklan akan dibuang
  /// dan iklan baru akan dimuat secara otomatis di latar belakang.
  ///
  /// [onAdDismissed] adalah callback yang dijalankan setelah iklan ditutup.
  Future<void> showAdIfReady({final VoidCallback? onAdDismissed}) async {
    if (!isAdReady) {
      Log.warning(
          '[InterstitialWaterfall] Gagal menampilkan iklan karena belum siap.');
      // Jika tidak siap, coba muat lagi di latar belakang untuk kesempatan berikutnya.
      await preloadAd();
      // Langsung jalankan callback agar alur aplikasi tidak terhenti.
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (final ad) =>
          Log.info('[InterstitialWaterfall] Iklan ditampilkan.'),
      onAdDismissedFullScreenContent: (final ad) async {
        Log.info('[InterstitialWaterfall] Iklan ditutup.');
        // [WAJIB] Buang iklan yang sudah ditampilkan.
        unawaited(ad.dispose());
        _interstitialAd = null;
        // Panggil callback setelah semua proses internal selesai.
        onAdDismissed?.call();
        // [WAJIB] Muat iklan baru untuk permintaan berikutnya.
        await preloadAd();
      },
      onAdFailedToShowFullScreenContent: (final ad, final error) async {
        Log.error('[InterstitialWaterfall] Gagal menampilkan iklan.',
            data: {'error': error.message});
        // Buang iklan yang gagal tampil.
        unawaited(ad.dispose());
        _interstitialAd = null;
        onAdDismissed?.call();
        // Coba muat ulang karena yang sebelumnya gagal.
        await preloadAd();
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

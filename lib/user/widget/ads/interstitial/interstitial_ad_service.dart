// path: lib/user/widget/ads/interstitial/interstitial_ad_service.dart
import 'dart:async';

import 'package:flutter/material.dart'; // DITAMBAHKAN
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/global_key.dart'; // DITAMBAHKAN
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

  /// Apakah iklan sedang dalam proses pengunduhan?
  bool get isAdLoading => _isAdLoading;

  // --- FUNGSI DEBUGGING SEMENTARA ---
  void _showDebugToast(final String message, {final bool isError = false}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
          '[InterstitialWaterfall] Semua unit iklan dalam waterfall gagal dimuat.');
      _showDebugToast('Semua ID iklan gagal dimuat.', isError: true); // DEBUG
      _isAdLoading = false;
      // Status loading diset false agar pemanggilan preloadAd() berikutnya bisa mencoba lagi
      return;
    }

    final adUnitId = _adUnitIds[adIndex];
    Log.info(
        '[InterstitialWaterfall] Mencoba memuat iklan #$adIndex: $adUnitId');
    _showDebugToast('Mencoba memuat iklan #$adIndex'); // DEBUG

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final ad) {
          Log.info('[InterstitialWaterfall] Iklan #$adIndex BERHASIL dimuat.');
          _showDebugToast('Iklan #$adIndex berhasil dimuat.'); // DEBUG
          _interstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (final error) async {
          Log.error(
            '[InterstitialWaterfall] Iklan #$adIndex GAGAL dimuat.',
            data: {'code': error.code, 'message': error.message},
          );
          _showDebugToast('Iklan #$adIndex GAGAL: ${error.message}', isError: true); // DEBUG
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
      _showDebugToast('Iklan belum siap. Memuat ulang...'); // DEBUG
      // Jika tidak siap, coba muat lagi di latar belakang untuk kesempatan berikutnya.
      await preloadAd();
      // Langsung jalankan callback agar alur aplikasi tidak terhenti.
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (final ad) {
        Log.info('[InterstitialWaterfall] Iklan ditampilkan.');
        _showDebugToast('Iklan ditampilkan!'); // DEBUG
      },
      onAdDismissedFullScreenContent: (final ad) async {
        Log.info('[InterstitialWaterfall] Iklan ditutup.');
        _showDebugToast('Iklan ditutup. Memuat yg baru...'); // DEBUG
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
        _showDebugToast('Gagal menampilkan iklan: ${error.message}', isError: true); // DEBUG
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

// path: lib/user/widget/ads/interstitial/interstitial_panduan.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Aplikasi contoh yang memuat iklan interstisial.
class InterstitialExample {
  InterstitialAd? _interstitialAd;

  final String _adUnitId = IdInterstitialAds.interstitialAdUnitIds[0];

  /// Memuat sebuah iklan interstisial.
  Future<void> loadAd() async {
    unawaited(InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (final InterstitialAd ad) {
          // Dipanggil saat iklan berhasil diterima.
          debugPrint('Ad was loaded.');
          // Simpan referensi ke iklan agar bisa ditampilkan nanti.
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (final ad) {
              // Dipanggil saat iklan menampilkan konten layar penuh.
              debugPrint('Ad showed full screen content.');
            },
            onAdFailedToShowFullScreenContent: (final ad, final err) {
              // Dipanggil saat iklan gagal menampilkan konten layar penuh.
              debugPrint(
                'Ad failed to show full screen content with error: $err',
              );
              // Hapus iklan di sini untuk membebaskan sumber daya.
              unawaited(ad.dispose());
            },
            onAdDismissedFullScreenContent: (final ad) {
              // Dipanggil saat iklan menutup konten layar penuh.
              debugPrint('Ad was dismissed.');
              // Hapus iklan di sini untuk membebaskan sumber daya.
              unawaited(ad.dispose());
            },
            onAdImpression: (final ad) {
              // Dipanggil saat sebuah impresi terjadi pada iklan.
              debugPrint('Ad recorded an impression.');
            },
            onAdClicked: (final ad) {
              // Dipanggil saat sebuah klik tercatat pada iklan.
              debugPrint('Ad was clicked.');
            },
          );
        },
        onAdFailedToLoad: (final LoadAdError error) {
          // Dipanggil saat permintaan iklan gagal.
          debugPrint('Ad failed to load with error: $error');
        },
      ),
    ));
  }

  Future<void> show() async {
    unawaited(_interstitialAd?.show());
  }

  void dispose() {
    unawaited(_interstitialAd?.dispose());
  }
}

// path: lib/user/widget/ads/interstitial_ad_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';

/// Kelas untuk mengelola iklan Interstitial (iklan layar penuh).
/// Idealnya, iklan dimuat sebelumnya dan ditampilkan di titik transisi alami.
class InterstitialAdService {
  InterstitialAd? _interstitialAd;

  // Getter untuk memeriksa apakah iklan sudah siap untuk ditampilkan.
  bool get isAdLoaded => _interstitialAd != null;

  /// Memuat iklan Interstitial.
  /// Panggil ini di `initState` halaman di mana Anda berencana menampilkan iklan.
  void loadAd() {
    // Jika iklan sudah ada atau sedang dimuat, tidak perlu melakukan apa-apa.
    if (_interstitialAd != null) {
      Log.info('Interstitial ad is already loaded or loading.');
      return;
    }

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitIdMediasi,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Dipanggil saat iklan berhasil dimuat.
        onAdLoaded: (ad) {
          Log.info('Interstitial ad loaded successfully.');
          _interstitialAd = ad;
        },
        // Dipanggil saat iklan gagal dimuat.
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          Log.error('Failed to load interstitial ad', data: {'error': error.message, 'code': error.code});
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap.
  /// Menerima [onAdDismissed] callback yang akan dijalankan setelah iklan ditutup.
  void showAd({VoidCallback? onAdDismissed}) {
    // Jika iklan belum siap, jangan blokir alur aplikasi.
    if (!isAdLoaded) {
      Log.warning('Tried to show Interstitial ad, but it is not ready yet.');
      // Langsung jalankan aksi selanjutnya agar pengguna tidak terhambat.
      onAdDismissed?.call();
      // Coba muat lagi untuk kesempatan berikutnya.
      loadAd();
      return;
    }

    // Mengatur callback untuk iklan spesifik yang akan ditampilkan ini.
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Log.info('Interstitial ad showed full screen content.');
      },
      // Dipanggil saat iklan ditutup oleh pengguna.
      onAdDismissedFullScreenContent: (ad) {
        Log.info('Interstitial ad dismissed.');
        // Buang resource iklan yang sudah dipakai.
        ad.dispose();
        _interstitialAd = null;
        // Jalankan aksi selanjutnya yang diinginkan oleh pemanggil.
        onAdDismissed?.call();
        // Langsung muat iklan baru untuk pemakaian berikutnya.
        loadAd();
      },
      // Dipanggil jika iklan gagal ditampilkan.
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error(
          'Failed to show interstitial ad',
          data: {'error': error.message, 'code': error.code},
        );
        // Buang resource iklan yang gagal.
        ad.dispose();
        _interstitialAd = null;
        // Tetap jalankan aksi selanjutnya agar aplikasi tidak macet.
        onAdDismissed?.call();
        // Muat iklan baru untuk pemakaian berikutnya.
        loadAd();
      },
    );

    // Tampilkan iklan.
    _interstitialAd!.show();
  }

  /// Membuang resource iklan untuk mencegah memory leak.
  /// Panggil ini di dalam metode `dispose()` dari StatefulWidget Anda.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    Log.info('InterstitialAdService disposed.');
  }
}

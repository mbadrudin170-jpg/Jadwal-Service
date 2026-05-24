// path: lib/user/widget/ads/interstitial_ad_service.dart
// DIUBAH: Metode loadAd sekarang menerima adUnitId untuk fleksibilitas.
// DIUBAH: Service sekarang menyimpan adUnitId terakhir yang digunakan untuk memuat ulang iklan secara otomatis.

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk mengelola iklan Interstitial (iklan layar penuh).
/// Idealnya, iklan dimuat sebelumnya dan ditampilkan di titik transisi alami.
class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  String? _lastUsedAdUnitId;

  // Getter untuk memeriksa apakah iklan sudah siap untuk ditampilkan.
  bool get isAdLoaded => _interstitialAd != null;

  /// Memuat iklan Interstitial dengan ID unit iklan yang spesifik.
  /// Panggil ini di `initState` atau sebelum Anda berencana menampilkan iklan.
  void loadAd({required String adUnitId}) {
    // Simpan adUnitId untuk digunakan kembali nanti (misal: saat reload otomatis).
    _lastUsedAdUnitId = adUnitId;

    if (_interstitialAd != null) {
      Log.info('Interstitial ad is already loaded or loading.');
      return;
    }

    Log.info('Loading interstitial ad with Unit ID: $adUnitId');
    InterstitialAd.load(
      adUnitId: adUnitId, // Menggunakan ID dari parameter
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
          // Jangan hapus _lastUsedAdUnitId agar bisa coba lagi
          Log.error('Failed to load interstitial ad', data: {
            'error': error.message,
            'code': error.code,
            'adUnitId': adUnitId,
          });
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

      // Jika kita tahu ID terakhir yang seharusnya dimuat, coba muat lagi.
      if (_lastUsedAdUnitId != null) {
        Log.info('Reloading ad automatically since it was not ready.');
        loadAd(adUnitId: _lastUsedAdUnitId!);
      }
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
        // Langsung muat iklan baru untuk pemakaian berikutnya dengan ID yang sama.
        if (_lastUsedAdUnitId != null) {
          loadAd(adUnitId: _lastUsedAdUnitId!);
        }
      },
      // Dipanggil jika iklan gagal ditampilkan.
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error(
          'Failed to show interstitial ad',
          data: {
            'error': error.message,
            'code': error.code,
            'adUnitId': _lastUsedAdUnitId
          },
        );
        // Buang resource iklan yang gagal.
        ad.dispose();
        _interstitialAd = null;
        // Tetap jalankan aksi selanjutnya agar aplikasi tidak macet.
        onAdDismissed?.call();
        // Muat iklan baru untuk pemakaian berikutnya dengan ID yang sama.
        if (_lastUsedAdUnitId != null) {
          loadAd(adUnitId: _lastUsedAdUnitId!);
        }
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
    _lastUsedAdUnitId = null; // Bersihkan saat service di-dispose
    Log.info('InterstitialAdService disposed.');
  }
}

// path: lib/user/widget/ads/app_open/app_open_ad_service.dart
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/app_open/id_app_open_ads.dart';

/// Kelas untuk mengelola iklan Pembukaan Aplikasi (App Open Ad).
/// Iklan ini tampil saat aplikasi dibuka atau kembali ke foreground.
class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Waktu kapan iklan terakhir berhasil dimuat.
  DateTime? _appOpenLoadTime;

  /// Durasi maksimal cache iklan sebelum dianggap kedaluwarsa.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Memuat App Open Ad.
  void loadAd() {
    // Jangan muat iklan baru jika sudah ada yang sedang ditampilkan.
    if (_isShowingAd) {
      Log.warning('[AppOpenAd] Iklan sedang tampil, permintaan load ditolak.');
      return;
    }

    // Jangan muat iklan baru jika sudah ada yang siap.
    if (_appOpenAd != null) {
      Log.info('[AppOpenAd] Iklan sudah siap, tidak perlu load lagi.');
      return;
    }

    Log.info('[AppOpenAd] Memulai memuat iklan...');
    unawaited(AppOpenAd.load(
      adUnitId: IdAppOpenAds.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (final ad) {
          Log.info('[AppOpenAd] Iklan BERHASIL dimuat.');
          _appOpenLoadTime = DateTime.now(); // Catat waktu muat
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (final error) {
          Log.error('[AppOpenAd] GAGAL memuat iklan.', data: {
            'code': error.code,
            'message': error.message,
          });
          _appOpenAd = null;
        },
      ),
    ));
  }

  /// Memeriksa apakah iklan yang dimuat masih valid (tidak kedaluwarsa).
  bool get _isAdValid {
    if (_appOpenLoadTime == null) {
      return false;
    }
    final now = DateTime.now();
    final difference = now.difference(_appOpenLoadTime!);
    return difference < maxCacheDuration;
  }

  /// Menampilkan iklan jika tersedia, valid, dan tidak sedang ditampilkan.
  Future<void> show() async {
    if (_appOpenAd == null) {
      Log.info('[AppOpenAd] Mencoba menampilkan, tapi iklan tidak tersedia.');
      loadAd(); // Muat iklan untuk kesempatan berikutnya.
      return;
    }
    // diperbaiki: Pindahkan pengecekan _isShowingAd ke atas untuk efisiensi
    if (_isShowingAd) {
      Log.info(
          '[AppOpenAd] Mencoba menampilkan, tapi iklan lain sedang aktif.');
      return;
    }

    // Periksa apakah iklan sudah kedaluwarsa
    if (!_isAdValid) {
      Log.warning('[AppOpenAd] Iklan kedaluwarsa. Memuat yang baru.');
      unawaited(_appOpenAd!.dispose());
      _appOpenAd = null;
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (final ad) {
        // State sudah diatur sebelumnya, di sini hanya untuk logging
        Log.info('[AppOpenAd] Iklan ditampilkan di layar penuh.');
      },
      onAdFailedToShowFullScreenContent: (final ad, final error) {
        Log.error('[AppOpenAd] GAGAL menampilkan iklan.',
            data: {'code': error.code, 'message': error.message});
        // Reset state agar bisa mencoba lagi
        _isShowingAd = false;
        unawaited(ad.dispose());
        _appOpenAd = null;
        loadAd(); // Muat lagi.
      },
      onAdDismissedFullScreenContent: (final ad) {
        Log.info('[AppOpenAd] Iklan ditutup.');
        // Reset state agar bisa mencoba lagi
        _isShowingAd = false;
        unawaited(ad.dispose());
        _appOpenAd = null;
        loadAd(); // Muat lagi untuk persiapan berikutnya.
      },
    );

    // diperbaiki: Atur flag _isShowingAd menjadi true SEBELUM memanggil show().
    // Ini mencegah race condition di mana showAdIfAvailable dipanggil beberapa kali
    // sebelum callback onAdShowedFullScreenContent sempat dieksekusi.
    _isShowingAd = true;
    Log.info('[AppOpenAd] Memulai proses penampilan iklan...');
    await _appOpenAd!.show();
  }
}

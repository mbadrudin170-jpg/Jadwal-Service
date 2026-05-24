// path: lib/user/widget/ads/app_open/app_open_ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/app_open/id_app_open_ads.dart';

/// Kelas untuk mengelola iklan Pembukaan Aplikasi (App Open Ad).
/// Iklan ini tampil saat aplikasi dibuka atau kembali ke foreground.
class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

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
    AppOpenAd.load(
      adUnitId: IdAppOpenAds.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info('[AppOpenAd] Iklan BERHASIL dimuat.');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          Log.error('[AppOpenAd] GAGAL memuat iklan.', data: {
            'code': error.code,
            'message': error.message,
          });
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Menampilkan iklan jika tersedia dan tidak sedang ditampilkan.
  void showAdIfAvailable() {
    if (_appOpenAd == null) {
      Log.info('[AppOpenAd] Mencoba menampilkan, tapi iklan tidak tersedia.');
      loadAd(); // Muat iklan untuk kesempatan berikutnya.
      return;
    }
    if (_isShowingAd) {
      Log.info(
          '[AppOpenAd] Mencoba menampilkan, tapi iklan lain sedang aktif.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        Log.info('[AppOpenAd] Iklan ditampilkan.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error('[AppOpenAd] GAGAL menampilkan iklan.',
            data: {'code': error.code, 'message': error.message});

        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Muat lagi.
      },
      onAdDismissedFullScreenContent: (ad) {
        Log.info('[AppOpenAd] Iklan ditutup.');

        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Muat lagi untuk persiapan berikutnya.
      },
    );

    _appOpenAd!.show();
  }
}

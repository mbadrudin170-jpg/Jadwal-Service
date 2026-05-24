// path: lib/user/widget/ads/app_open_ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/ad_helper.dart';

/// Kelas untuk mengelola iklan Pembukaan Aplikasi (App Open Ad).
/// Iklan ini tampil saat aplikasi dibuka atau kembali ke foreground.
class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Memuat App Open Ad.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info('App Open Ad loaded successfully.');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          Log.error('Failed to load App Open Ad', data: {'error': error.message, 'code': error.code});
        },
      ),
    );
  }

  /// Menampilkan iklan jika sudah siap dan jika iklan lain tidak sedang tampil.
  void showAdIfReady() {
    if (_appOpenAd == null) {
      Log.info('Tried to show App Open Ad, but it is not ready yet.');
      loadAd(); // Muat lagi untuk kesempatan berikutnya
      return;
    }
    if (_isShowingAd) {
      Log.info('Tried to show App Open Ad, but another ad is already showing.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        Log.info('App Open Ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        Log.info('App Open Ad dismissed.');
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Muat iklan baru setelah yang lama ditutup
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        Log.error(
          'Failed to show App Open Ad',
          data: {'error': error.message, 'code': error.code},
        );
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Muat ulang jika gagal tampil
      },
    );

    _appOpenAd!.show();
  }
}

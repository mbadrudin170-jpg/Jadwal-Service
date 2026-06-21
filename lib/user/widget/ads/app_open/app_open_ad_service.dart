// path: lib/user/widget/ads/app_open/app_open_ad_service.dart
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/app_open/id_app_open_ads.dart';

class LayananIklanBukaAplikasi {
  AppOpenAd? _iklanBukaAplikasi;
  bool _sedangMenampilkanIklan = false;

  DateTime? _waktuMuatIklan;

  final Duration durasiMaksimalCache = const Duration(hours: 4);

  void muatIklan() {
    if (_sedangMenampilkanIklan) {
      Log.warning('[AppOpenAd] Iklan sedang tampil, permintaan load ditolak.');
      return;
    }

    if (_iklanBukaAplikasi != null) {
      Log.info('[AppOpenAd] Iklan sudah siap, tidak perlu load lagi.');
      return;
    }

    Log.info('[AppOpenAd] Memulai memuat iklan...');
    unawaited(
      AppOpenAd.load(
        adUnitId: IdAppOpenAds.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            Log.info('[AppOpenAd] Iklan BERHASIL dimuat.');
            _waktuMuatIklan = DateTime.now();
            _iklanBukaAplikasi = ad;
          },
          onAdFailedToLoad: (error) {
            Log.error(
              '[AppOpenAd] GAGAL memuat iklan.',
              data: {'code': error.code, 'message': error.message},
            );
            _iklanBukaAplikasi = null;
          },
        ),
      ),
    );
  }

  bool get _apakahIklanValid {
    if (_waktuMuatIklan == null) {
      return false;
    }
    final now = DateTime.now();
    final selisih = now.difference(_waktuMuatIklan!);
    return selisih < durasiMaksimalCache;
  }

  Future<void> tampilkanIklan() async {
    if (_iklanBukaAplikasi == null) {
      Log.info('[AppOpenAd] Mencoba menampilkan, tapi iklan tidak tersedia.');
      muatIklan();
      return;
    }

    if (_sedangMenampilkanIklan) {
      Log.info(
        '[AppOpenAd] Mencoba menampilkan, tapi iklan lain sedang aktif.',
      );
      return;
    }

    if (!_apakahIklanValid) {
      Log.warning('[AppOpenAd] Iklan kedaluwarsa. Memuat yang baru.');
      unawaited(_iklanBukaAplikasi!.dispose());
      _iklanBukaAplikasi = null;
      muatIklan();
      return;
    }

    _iklanBukaAplikasi!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Log.info('[AppOpenAd] Iklan ditampilkan di layar penuh.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error(
          '[AppOpenAd] GAGAL menampilkan iklan.',
          data: {'code': error.code, 'message': error.message},
        );
        _sedangMenampilkanIklan = false;
        unawaited(ad.dispose());
        _iklanBukaAplikasi = null;
        muatIklan();
      },
      onAdDismissedFullScreenContent: (ad) {
        Log.info('[AppOpenAd] Iklan ditutup.');
        _sedangMenampilkanIklan = false;
        unawaited(ad.dispose());
        _iklanBukaAplikasi = null;
        muatIklan();
      },
    );

    _sedangMenampilkanIklan = true;
    Log.info('[AppOpenAd] Memulai proses penampilan iklan...');
    await _iklanBukaAplikasi!.show();
  }
}

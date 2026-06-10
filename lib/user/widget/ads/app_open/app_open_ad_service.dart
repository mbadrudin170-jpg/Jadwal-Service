// path: lib/user/widget/ads/app_open/app_open_ad_service.dart
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/app_open/id_app_open_ads.dart';

/// Layanan untuk mengelola iklan saat aplikasi dibuka (App Open Ad).
/// Iklan ini akan muncul ketika aplikasi pertama kali dibuka atau kembali ke tampilan utama.
class LayananIklanBukaAplikasi {
  AppOpenAd? _iklanBukaAplikasi;
  bool _sedangMenampilkanIklan = false;

  /// Mencatat waktu kapan iklan terakhir kali berhasil dimuat.
  DateTime? _waktuMuatIklan;

  /// Batas waktu maksimal penyimpanan iklan sebelum dianggap basi.
  final Duration durasiMaksimalCache = const Duration(hours: 4);

  /// Memulai proses memuat data iklan dari server.
  // TODO : nama method di bawah ini (loadAd) sebaiknya diganti jika diizinkan merubah API eksternal
  void muatIklan() {
    // Jangan muat iklan baru jika sudah ada yang sedang ditampilkan.
    if (_sedangMenampilkanIklan) {
      Log.warning('[AppOpenAd] Iklan sedang tampil, permintaan load ditolak.');
      return;
    }

    // Jangan muat iklan baru jika sudah ada yang siap.
    if (_iklanBukaAplikasi != null) {
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
          _waktuMuatIklan = DateTime.now(); // Catat waktu muat
          _iklanBukaAplikasi = ad;
        },
        onAdFailedToLoad: (final error) {
          Log.error('[AppOpenAd] GAGAL memuat iklan.', data: {
            'code': error.code,
            'message': error.message,
          });
          _iklanBukaAplikasi = null;
        },
      ),
    ));
  }

  /// Memvalidasi apakah iklan yang sudah dimuat masih layak tampil.
  bool get _apakahIklanValid {
    if (_waktuMuatIklan == null) {
      return false;
    }
    final now = DateTime.now();
    final selisih = now.difference(_waktuMuatIklan!);
    return selisih < durasiMaksimalCache;
  }

  /// Menampilkan iklan ke layar pengguna jika data sudah siap dan valid.
  Future<void> tampilkanIklan() async {
    if (_iklanBukaAplikasi == null) {
      Log.info('[AppOpenAd] Mencoba menampilkan, tapi iklan tidak tersedia.');
      muatIklan(); // Muat iklan untuk kesempatan berikutnya.
      return;
    }

    if (_sedangMenampilkanIklan) {
      Log.info(
          '[AppOpenAd] Mencoba menampilkan, tapi iklan lain sedang aktif.');
      return;
    }

    // Periksa apakah iklan sudah basi (kadaluarsa)
    if (!_apakahIklanValid) {
      Log.warning('[AppOpenAd] Iklan kedaluwarsa. Memuat yang baru.');
      unawaited(_iklanBukaAplikasi!.dispose());
      _iklanBukaAplikasi = null;
      muatIklan();
      return;
    }

    _iklanBukaAplikasi!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (final ad) {
        Log.info('[AppOpenAd] Iklan ditampilkan di layar penuh.');
      },
      onAdFailedToShowFullScreenContent: (final ad, final error) {
        Log.error('[AppOpenAd] GAGAL menampilkan iklan.',
            data: {'code': error.code, 'message': error.message});
        _sedangMenampilkanIklan = false;
        unawaited(ad.dispose());
        _iklanBukaAplikasi = null;
        muatIklan(); // Muat lagi.
      },
      onAdDismissedFullScreenContent: (final ad) {
        Log.info('[AppOpenAd] Iklan ditutup.');
        _sedangMenampilkanIklan = false;
        unawaited(ad.dispose());
        _iklanBukaAplikasi = null;
        muatIklan(); // Muat lagi untuk persiapan berikutnya.
      },
    );

    _sedangMenampilkanIklan = true;
    Log.info('[AppOpenAd] Memulai proses penampilan iklan...');
    await _iklanBukaAplikasi!.show();
  }
}

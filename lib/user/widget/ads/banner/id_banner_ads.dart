// path: lib/user/widget/ads/banner/id_banner_ads.dart
import 'package:flutter/foundation.dart';

/// Class khusus untuk mengelola ID unit iklan yang berhubungan dengan Banner.
class IdBannerAds {
  // --- ID Iklan Banner Produksi ---
  static const String _prodBannerAdMediasi1 =
      'ca-app-pub-9773465799516929/1302679235';
  static const String _prodBannerAdMediasi2 =
      'ca-app-pub-9773465799516929/6555005913';
  static const String _prodBanner1 = 'ca-app-pub-9773465799516929/4952931046';
  static const String _prodBanner2 = 'ca-app-pub-9773465799516929/5180618604';

  // --- ID Iklan Banner Tes ---
  static const String _testBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testProfileBannerAd =
      'ca-app-pub-3940256099942544/6300978111';

  static List<String> get bannerAdUnitIds {
    if (kDebugMode) {
      // Urutan untuk menguji waterfall: gagal, gagal, berhasil.
      return [
        _testBannerAd, // Akan berhasil
      ];
    }
    // Urutan produksi
    return [
      _prodBannerAdMediasi1,
      _prodBannerAdMediasi2,
      _prodBanner1,
      _prodBanner2,
    ];
  }

  /// ID unit iklan untuk Banner di halaman profil (Mediasi).
  static String get profileBannerAdUnitId {
    if (kDebugMode) {
      return _testProfileBannerAd;
    }
    return _prodBannerAdMediasi1;
  }
}

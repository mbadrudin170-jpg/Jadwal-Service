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

  /// ID unit iklan untuk Banner mediasi 1.
  static String get prodBannerAdMediasi1 {
    if (kDebugMode) {
      return _testBannerAd;
    }
    return _prodBannerAdMediasi1;
  }

  /// ID unit iklan untuk Banner mediasi 2.
  static String get prodBannerAdMediasi2 {
    if (kDebugMode) {
      return _testBannerAd;
    }
    return _prodBannerAdMediasi2;
  }

  /// ID unit iklan untuk Banner 1.
  static String get prodBanner1 {
    if (kDebugMode) {
      return _testBannerAd;
    }
    return _prodBanner1;
  }

  /// ID unit iklan untuk Banner 2.
  static String get prodBanner2 {
    if (kDebugMode) {
      return _testBannerAd;
    }
    return _prodBanner2;
  }
}

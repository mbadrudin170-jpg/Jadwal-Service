// path: lib/user/widget/ads/app_open/id_app_open_ads.dart
import 'package:flutter/foundation.dart';

/// Class khusus untuk mengelola ID unit iklan yang berhubungan dengan App Open Ad.
class IdAppOpenAds {
  // --- ID Iklan App Open Produksi ---
  static const String _prodAppOpenAd = 'ca-app-pub-9773465799516929/4233534291';

  // --- ID Iklan App Open Tes ---
  static const String _testAppOpenAd = 'ca-app-pub-3940256099942544/9257395921';

  /// ID unit iklan untuk App Open Ad.
  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return _testAppOpenAd;
    }
    return _prodAppOpenAd;
  }
}

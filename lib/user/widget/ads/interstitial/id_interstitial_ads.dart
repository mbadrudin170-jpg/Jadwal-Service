// path: lib/user/widget/ads/interstitial/id_interstitial_ads.dart
import 'package:flutter/foundation.dart';

/// Class khusus untuk mengelola ID unit iklan yang berhubungan dengan Interstitial.
class IdInterstitialAds {
  // --- ID Iklan Interstitial Produksi ---
  static const String _prodInterstitialAdMediasi =
      'ca-app-pub-9773465799516929/4325033636';
  static const String _prodInterstitial1 =
      'ca-app-pub-9773465799516929/2200295108';
  static const String _prodInterstitial2 =
      'ca-app-pub-9773465799516929/6082636738';

  // --- ID Iklan Interstitial Tes ---
  static const String _testInterstitialAd =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _invalidTestAd = 'ca-app-pub-3940256099942544/1111';

  /// Daftar ID unit iklan Interstitial untuk waterfall.
  static List<String> get interstitialAdUnitIds {
    if (kDebugMode) {
      return [
        _invalidTestAd,
        _testInterstitialAd,
      ];
    }
    return [_prodInterstitialAdMediasi, _prodInterstitial1, _prodInterstitial2];
  }

  /// ID unit iklan untuk Interstitial (Mediasi).
  static String get interstitialAdUnitIdMediasi {
    if (kDebugMode) {
      return _testInterstitialAd;
    }
    return _prodInterstitialAdMediasi;
  }

  /// ID unit iklan untuk Interstitial (Ad Unit 1).
  static String get interstitialAdUnitId1 {
    if (kDebugMode) {
      return _testInterstitialAd;
    }
    return _prodInterstitial1;
  }
}

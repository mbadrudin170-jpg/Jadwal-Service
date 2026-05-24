// path: lib/user/widget/ads/ad_helper.dart
import 'package:flutter/foundation.dart';

/// Kelas bantuan untuk mengambil ID unit iklan yang sesuai.
class AdHelper {
  // --- ID Aplikasi AdMob ---
  static const String appId = 'ca-app-pub-9773465799516929~5575068959';

  // --- ID Iklan Produksi ---
  static const String _prodBannerAdMediasi =
      'ca-app-pub-9773465799516929/1302679235';
  static const String _prodProfileBannerAdMediasi =
      'ca-app-pub-9773465799516929/6555005913';
  static const String _prodRewardedAd =
      'ca-app-pub-9773465799516929/8472539507';
  static const String _prodInterstitialAdMediasi =
      'ca-app-pub-9773465799516929/4325033636';
  static const String _prodAppOpenAd = 'ca-app-pub-9773465799516929/4233534291';
  static const String _prodBanner1 = 'ca-app-pub-9773465799516929/4952931046';
  static const String _prodBanner2 = ' ca-app-pub-9773465799516929/5180618604';
  static const String _prodInterestial1 =
      'ca-app-pub-9773465799516929/2200295108';

  // --- ID Iklan Tes (untuk Pengembangan) ---
  static const String _testBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testRewardedAd =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialAd =
      'ca-app-pub-3940256099942544/5135589807';
  static const String _testAppOpenAd = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testProfileBannerAd =
      'ca-app-pub-3940256099942544/6300978111'; // Boleh pakai ID banner tes yang sama
  static const String _invalidTestBannerAd =
      'ca-app-pub-3940256099942544/1111111111';

  // --- Getter Iklan (Logika untuk memilih ID produksi atau tes) ---

  /// ID unit iklan untuk Banner (A). Digunakan untuk waterfall.
  static String get bannerAdUnitId1 {
    if (kDebugMode) {
      // Di mode debug, kita buat ini gagal agar waterfall bisa diuji
      return _invalidTestBannerAd;
    }
    return _prodBanner1;
  }

  /// ID unit iklan untuk Banner (B). Digunakan untuk waterfall.
  static String get bannerAdUnitIdMediasi {
    if (kDebugMode) {
      // Di mode debug, kita buat ini juga gagal
      return _invalidTestBannerAd;
    }
    return _prodBannerAdMediasi;
  }

  /// ID unit iklan untuk Banner (C). Digunakan untuk waterfall.
  static String get bannerAdUnitId2 {
    if (kDebugMode) {
      return _testBannerAd; // Ini akan berhasil
    }
    return _prodBanner2;
  }

  /// ID unit iklan untuk Banner di halaman profil (Mediasi).
  static String get profileBannerAdUnitIdMediasi {
    if (kDebugMode) {
      return _testProfileBannerAd;
    }
    return _prodProfileBannerAdMediasi;
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
    return _prodInterestial1;
  }

  /// ID unit iklan untuk Rewarded.
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAd;
    }
    return _prodRewardedAd;
  }

  /// ID unit iklan untuk App Open Ad.
  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return _testAppOpenAd;
    }
    return _prodAppOpenAd;
  }
}

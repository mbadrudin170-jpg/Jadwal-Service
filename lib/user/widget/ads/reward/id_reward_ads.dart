// path: lib/user/widget/ads/reward/id_reward_ads.dart
import 'package:flutter/foundation.dart';

/// Class khusus untuk mengelola ID unit iklan yang berhubungan dengan Rewarded Ad.
class IdRewardAds {
  // --- ID Iklan Rewarded Produksi ---
  static const String _prodRewardedAd =
      'ca-app-pub-9773465799516929/8472539507';

  // --- ID Iklan Rewarded Tes ---
  static const String _testRewardedAd =
      'ca-app-pub-3940256099942544/5224354917';

  /// ID unit iklan untuk Rewarded Ad.
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAd;
    }
    return _prodRewardedAd;
  }
}

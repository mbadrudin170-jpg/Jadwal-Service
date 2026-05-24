// path: lib/user/widget/ads/bonused_mediator/id_bonused_mediator_ads.dart
import 'package:flutter/foundation.dart';

/// Class to manage ad unit IDs for Bonused Mediator ads.
class IdBonusedMediatorAds {
  // --- Production Bonused Mediator Ad IDs ---
  static const String _prodBonusedMediatorAd =
      'ca-app-pub-9773465799516929/8472539507';

  // --- Test Bonused Mediator Ad IDs ---
  static const String _testBonusedMediatorAd =
      'ca-app-pub-3940256099942544/5224354917';

  /// Ad unit ID for Bonused Mediator Ad.
  static String get bonusedMediatorAdUnitId {
    if (kDebugMode) {
      return _testBonusedMediatorAd;
    }
    return _prodBonusedMediatorAd;
  }
}

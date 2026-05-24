// path: lib/user/widget/ads/bonused_mediator/bonused_mediator_ad_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/widget/ads/bonused_mediator/id_bonused_mediator_ads.dart';

/// Class for managing Bonused Mediator Ads.
/// Users watch an ad to get a reward in the application.
class BonusedMediatorAdService {
  RewardedAd? _rewardedAd;

  // Getter to check if the ad is loaded and ready to be displayed.
  bool get isAdLoaded => _rewardedAd != null;

  /// Loads a Bonused Mediator ad.
  /// [onAdLoaded] will be called when the ad is successfully loaded.
  /// [onAdFailedToLoad] will be called when the ad fails to load.
  void loadAd({
    VoidCallback? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) {
    // Prevents repeated loading if the ad already exists.
    if (_rewardedAd != null) {
      Log.info('Bonused Mediator ad is already loaded.');
      onAdLoaded?.call();
      return;
    }

    RewardedAd.load(
      adUnitId: IdBonusedMediatorAds.bonusedMediatorAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Log.info('Bonused Mediator ad loaded successfully.');
          _rewardedAd = ad;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          Log.error('Failed to load Bonused Mediator ad',
              data: {'error': error.message, 'code': error.code});
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Shows the ad if it is ready and gives a reward upon completion.
  /// [onReward] will be called ONLY if the user completes the ad.
  /// [onAdDismissed] (optional) will be called when the ad is closed, whether the user completes it or not.
  void showAd({
    required VoidCallback onReward,
    VoidCallback? onAdDismissed,
  }) {
    if (!isAdLoaded) {
      Log.warning('Tried to show Bonused Mediator ad, but it is not ready yet.');
      // If the ad is not ready, call onAdDismissed so that the flow is not interrupted.
      onAdDismissed?.call();
      // Try loading again for the next opportunity.
      loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Log.info('Bonused Mediator ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        Log.info('Bonused Mediator ad dismissed.');
        // Run the general callback when the ad is closed.
        onAdDismissed?.call();
        // Dispose of ad resources.
        ad.dispose();
        _rewardedAd = null;
        // Load a new ad for the next use.
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Log.error(
          'Failed to show Bonused Mediator ad',
          data: {'error': error.message, 'code': error.code},
        );
        // Run the general callback so the UI does not hang.
        onAdDismissed?.call();
        // Dispose of ad resources.
        ad.dispose();
        _rewardedAd = null;
        // Load a new ad.
        loadAd();
      },
    );

    // Show the ad and determine what happens when the user is entitled to a reward.
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        Log.info(
          'User earned reward: amount=${reward.amount}, type=${reward.type}',
        );
        // This is a crucial moment to give the user a reward.
        onReward();
      },
    );
  }

  /// Cleans up ad resources to prevent memory leaks.
  /// Must be called in the `dispose()` method of your StatefulWidget.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    Log.info('BonusedMediatorAdService disposed.');
  }
}

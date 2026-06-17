// path: lib/user/providers/ad_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

part 'ad_providers.g.dart';

@Riverpod(keepAlive: true)
InterstitialAdService interstitialAdService(Ref ref) {
  final service = InterstitialAdService();

  ref.onDispose(service.dispose);

  return service;
}

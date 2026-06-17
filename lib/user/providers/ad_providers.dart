// path: lib/user/providers/ad_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/user/widget/ads/interstitial/layanan_iklan_interstisial.dart';

part 'ad_providers.g.dart';

@Riverpod(keepAlive: true)
LayananIklanInterstisial interstitialAdService(Ref ref) {
  final service = LayananIklanInterstisial();

  ref.onDispose(service.dispose);

  return service;
}

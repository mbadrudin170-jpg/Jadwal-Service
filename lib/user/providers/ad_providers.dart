import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

part 'ad_provider.g.dart';

@Riverpod(keepAlive: true)
InterstitialAdService interstitialAdService(Ref ref) {
  // ← tambah tipe Ref
  final service = InterstitialAdService();

  // Perbaiki dengan membungkus dispose dalam fungsi anonim
  // agar tipe-nya jelas (void Function())
  ref.onDispose(service.dispose);

  return service;
}

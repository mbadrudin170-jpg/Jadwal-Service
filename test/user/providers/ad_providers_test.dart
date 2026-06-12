
// path: test/user/providers/ad_providers_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

// Mocks
class MockInterstitialAdService extends Mock implements InterstitialAdService {}

void main() {
  group('interstitialAdServiceProvider', () {
    test('Test 01: should return an instance of InterstitialAdService', () {
      final container = ProviderContainer();
      final service = container.read(interstitialAdServiceProvider);

      expect(service, isA<InterstitialAdService>());
    });
  });
}

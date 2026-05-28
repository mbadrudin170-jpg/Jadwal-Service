// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(interstitialAdService)
final interstitialAdServiceProvider = InterstitialAdServiceProvider._();

final class InterstitialAdServiceProvider extends $FunctionalProvider<
    InterstitialAdService,
    InterstitialAdService,
    InterstitialAdService> with $Provider<InterstitialAdService> {
  InterstitialAdServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'interstitialAdServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$interstitialAdServiceHash();

  @$internal
  @override
  $ProviderElement<InterstitialAdService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InterstitialAdService create(Ref ref) {
    return interstitialAdService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterstitialAdService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterstitialAdService>(value),
    );
  }
}

String _$interstitialAdServiceHash() =>
    r'32cb8fafbad562d742ab5f41f29f3865ea86b946';

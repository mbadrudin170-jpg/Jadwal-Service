// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(interstitialAdService)
final interstitialAdServiceProvider = InterstitialAdServiceProvider._();

final class InterstitialAdServiceProvider
    extends
        $FunctionalProvider<
          LayananIklanInterstisial,
          LayananIklanInterstisial,
          LayananIklanInterstisial
        >
    with $Provider<LayananIklanInterstisial> {
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
  $ProviderElement<LayananIklanInterstisial> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LayananIklanInterstisial create(Ref ref) {
    return interstitialAdService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayananIklanInterstisial value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayananIklanInterstisial>(value),
    );
  }
}

String _$interstitialAdServiceHash() =>
    r'd4fe88e6ac6338c21aaacda38dc34da38059dba8';

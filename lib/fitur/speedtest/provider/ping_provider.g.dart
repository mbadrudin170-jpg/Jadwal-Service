// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ping)
final pingProvider = PingProvider._();

final class PingProvider extends $FunctionalProvider<AsyncValue<PingData>,
        PingData, FutureOr<PingData>>
    with $FutureModifier<PingData>, $FutureProvider<PingData> {
  PingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pingHash();

  @$internal
  @override
  $FutureProviderElement<PingData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PingData> create(Ref ref) {
    return ping(ref);
  }
}

String _$pingHash() => r'de3619f38b8d1ec1fa0cd4d1698c18096a086f6c';

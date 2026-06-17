// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ping)
final pingProvider = PingProvider._();

final class PingProvider
    extends
        $FunctionalProvider<AsyncValue<PingData>, PingData, FutureOr<PingData>>
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

String _$pingHash() => r'00d9fa2656e4d2c99bc4e2de3ff43349f6a31608';

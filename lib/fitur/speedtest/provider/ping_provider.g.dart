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

String _$pingHash() => r'8f618a6e3e25ab6ca190ed53fa742a3b0181a8dc';

@ProviderFor(httpPing)
final httpPingProvider = HttpPingProvider._();

final class HttpPingProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  HttpPingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpPingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpPingHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return httpPing(ref);
  }
}

String _$httpPingHash() => r'd40359925cf1b6fb94c217e43ce8a68657a76a73';

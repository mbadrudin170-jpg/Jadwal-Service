// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_langganan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ambilDetailLangganan)
final ambilDetailLanggananProvider = AmbilDetailLanggananFamily._();

final class AmbilDetailLanggananProvider extends $FunctionalProvider<
        AsyncValue<DetailLanggananState?>,
        DetailLanggananState?,
        FutureOr<DetailLanggananState?>>
    with
        $FutureModifier<DetailLanggananState?>,
        $FutureProvider<DetailLanggananState?> {
  AmbilDetailLanggananProvider._(
      {required AmbilDetailLanggananFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'ambilDetailLanggananProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$ambilDetailLanggananHash();

  @override
  String toString() {
    return r'ambilDetailLanggananProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DetailLanggananState?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DetailLanggananState?> create(Ref ref) {
    final argument = this.argument as String;
    return ambilDetailLangganan(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AmbilDetailLanggananProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ambilDetailLanggananHash() =>
    r'bbd675f5eddd8109d3aaf2817e7f03f04194cb23';

final class AmbilDetailLanggananFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DetailLanggananState?>, String> {
  AmbilDetailLanggananFamily._()
      : super(
          retry: null,
          name: r'ambilDetailLanggananProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AmbilDetailLanggananProvider call(
    String idTransaksi,
  ) =>
      AmbilDetailLanggananProvider._(argument: idTransaksi, from: this);

  @override
  String toString() => r'ambilDetailLanggananProvider';
}

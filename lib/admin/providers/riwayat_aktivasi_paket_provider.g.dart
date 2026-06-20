// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riwayat_aktivasi_paket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RiwayatAktivasiPaket)
final riwayatAktivasiPaketProvider = RiwayatAktivasiPaketProvider._();

final class RiwayatAktivasiPaketProvider
    extends
        $AsyncNotifierProvider<
          RiwayatAktivasiPaket,
          RiwayatAktivasiPaketState
        > {
  RiwayatAktivasiPaketProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'riwayatAktivasiPaketProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riwayatAktivasiPaketHash();

  @$internal
  @override
  RiwayatAktivasiPaket create() => RiwayatAktivasiPaket();
}

String _$riwayatAktivasiPaketHash() =>
    r'73363c4e6c29072d8843927b7b30c7a303e07732';

abstract class _$RiwayatAktivasiPaket
    extends $AsyncNotifier<RiwayatAktivasiPaketState> {
  FutureOr<RiwayatAktivasiPaketState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RiwayatAktivasiPaketState>,
              RiwayatAktivasiPaketState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RiwayatAktivasiPaketState>,
                RiwayatAktivasiPaketState
              >,
              AsyncValue<RiwayatAktivasiPaketState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

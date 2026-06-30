// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_aktif_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PelangganAktif)
final pelangganAktifProvider = PelangganAktifProvider._();

final class PelangganAktifProvider
    extends $AsyncNotifierProvider<PelangganAktif, PelangganAktifState> {
  PelangganAktifProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganAktifProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganAktifHash();

  @$internal
  @override
  PelangganAktif create() => PelangganAktif();
}

String _$pelangganAktifHash() => r'0a88a052466a639ea13bc088759c436910cd6cfa';

abstract class _$PelangganAktif extends $AsyncNotifier<PelangganAktifState> {
  FutureOr<PelangganAktifState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PelangganAktifState>, PelangganAktifState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PelangganAktifState>, PelangganAktifState>,
              AsyncValue<PelangganAktifState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(detailPelangganAktif)
final detailPelangganAktifProvider = DetailPelangganAktifProvider._();

final class DetailPelangganAktifProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DetailPelangganAktifProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailPelangganAktifProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailPelangganAktifHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return detailPelangganAktif(ref);
  }
}

String _$detailPelangganAktifHash() =>
    r'27f1d5c020290ba608e0f2cfb0d8715a4f2ee1e8';

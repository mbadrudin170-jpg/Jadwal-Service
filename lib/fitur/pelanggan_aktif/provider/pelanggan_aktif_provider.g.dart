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

String _$pelangganAktifHash() => r'844df9bc78450d65f895bfcf88644042e632af1c';

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

@ProviderFor(daftarPelangganAktifTerurut)
final daftarPelangganAktifTerurutProvider =
    DaftarPelangganAktifTerurutProvider._();

final class DaftarPelangganAktifTerurutProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DetailPelangganAktifModel>>,
          List<DetailPelangganAktifModel>,
          FutureOr<List<DetailPelangganAktifModel>>
        >
    with
        $FutureModifier<List<DetailPelangganAktifModel>>,
        $FutureProvider<List<DetailPelangganAktifModel>> {
  DaftarPelangganAktifTerurutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'daftarPelangganAktifTerurutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$daftarPelangganAktifTerurutHash();

  @$internal
  @override
  $FutureProviderElement<List<DetailPelangganAktifModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DetailPelangganAktifModel>> create(Ref ref) {
    return daftarPelangganAktifTerurut(ref);
  }
}

String _$daftarPelangganAktifTerurutHash() =>
    r'8487e5b8dd88bef544b9d2005355b4e4c180c8eb';

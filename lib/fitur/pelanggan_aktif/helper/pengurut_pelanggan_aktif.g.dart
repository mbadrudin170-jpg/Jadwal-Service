// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengurut_pelanggan_aktif.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UrutanPelangganAktifState)
final urutanPelangganAktifStateProvider = UrutanPelangganAktifStateProvider._();

final class UrutanPelangganAktifStateProvider
    extends $NotifierProvider<UrutanPelangganAktifState, UrutanPelangganAktif> {
  UrutanPelangganAktifStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urutanPelangganAktifStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urutanPelangganAktifStateHash();

  @$internal
  @override
  UrutanPelangganAktifState create() => UrutanPelangganAktifState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrutanPelangganAktif value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrutanPelangganAktif>(value),
    );
  }
}

String _$urutanPelangganAktifStateHash() =>
    r'ff5d87fe62843686f05dbda5cfd2c0690460b4e1';

abstract class _$UrutanPelangganAktifState
    extends $Notifier<UrutanPelangganAktif> {
  UrutanPelangganAktif build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UrutanPelangganAktif, UrutanPelangganAktif>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UrutanPelangganAktif, UrutanPelangganAktif>,
              UrutanPelangganAktif,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

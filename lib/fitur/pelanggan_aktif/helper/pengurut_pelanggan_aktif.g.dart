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
    extends
        $NotifierProvider<UrutanPelangganAktifState, UrutanPelangganAktifEnum> {
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
  Override overrideWithValue(UrutanPelangganAktifEnum value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrutanPelangganAktifEnum>(value),
    );
  }
}

String _$urutanPelangganAktifStateHash() =>
    r'1ea8a3a6127ca23823647c094e0cb9158bb6aaf0';

abstract class _$UrutanPelangganAktifState
    extends $Notifier<UrutanPelangganAktifEnum> {
  UrutanPelangganAktifEnum build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<UrutanPelangganAktifEnum, UrutanPelangganAktifEnum>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UrutanPelangganAktifEnum, UrutanPelangganAktifEnum>,
              UrutanPelangganAktifEnum,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

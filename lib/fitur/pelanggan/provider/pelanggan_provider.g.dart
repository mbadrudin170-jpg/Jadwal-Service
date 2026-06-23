// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Pelanggan)
final pelangganProvider = PelangganProvider._();

final class PelangganProvider
    extends $AsyncNotifierProvider<Pelanggan, PelangganState> {
  PelangganProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganHash();

  @$internal
  @override
  Pelanggan create() => Pelanggan();
}

String _$pelangganHash() => r'3ec31d5924cc83f05532477305b0ebaaff54dcba';

abstract class _$Pelanggan extends $AsyncNotifier<PelangganState> {
  FutureOr<PelangganState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PelangganState>, PelangganState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PelangganState>, PelangganState>,
              AsyncValue<PelangganState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.

@ProviderFor(UrutanPelangganState)
final urutanPelangganStateProvider = UrutanPelangganStateProvider._();

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.
final class UrutanPelangganStateProvider
    extends $NotifierProvider<UrutanPelangganState, UrutanPelanggan> {
  /// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.
  UrutanPelangganStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urutanPelangganStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urutanPelangganStateHash();

  @$internal
  @override
  UrutanPelangganState create() => UrutanPelangganState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrutanPelanggan value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrutanPelanggan>(value),
    );
  }
}

String _$urutanPelangganStateHash() =>
    r'4d10172b1c7b6624a3ba78ae04fb5e40835a3fd8';

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.

abstract class _$UrutanPelangganState extends $Notifier<UrutanPelanggan> {
  UrutanPelanggan build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UrutanPelanggan, UrutanPelanggan>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UrutanPelanggan, UrutanPelanggan>,
              UrutanPelanggan,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// =========================================================================
/// TULIS DI SINI (Bagian paling bawah file pelanggan_provider.dart)
/// =========================================================================
/// Provider generator modern untuk status mode pencarian aktif/tidak

@ProviderFor(IsSearchingPelanggan)
final isSearchingPelangganProvider = IsSearchingPelangganProvider._();

/// =========================================================================
/// TULIS DI SINI (Bagian paling bawah file pelanggan_provider.dart)
/// =========================================================================
/// Provider generator modern untuk status mode pencarian aktif/tidak
final class IsSearchingPelangganProvider
    extends $NotifierProvider<IsSearchingPelanggan, bool> {
  /// =========================================================================
  /// TULIS DI SINI (Bagian paling bawah file pelanggan_provider.dart)
  /// =========================================================================
  /// Provider generator modern untuk status mode pencarian aktif/tidak
  IsSearchingPelangganProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSearchingPelangganProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSearchingPelangganHash();

  @$internal
  @override
  IsSearchingPelanggan create() => IsSearchingPelanggan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSearchingPelangganHash() =>
    r'38724895cc23955136de503eb511810c7092933f';

/// =========================================================================
/// TULIS DI SINI (Bagian paling bawah file pelanggan_provider.dart)
/// =========================================================================
/// Provider generator modern untuk status mode pencarian aktif/tidak

abstract class _$IsSearchingPelanggan extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider generator modern untuk menyimpan text query pencarian pelanggan

@ProviderFor(SearchQueryPelanggan)
final searchQueryPelangganProvider = SearchQueryPelangganProvider._();

/// Provider generator modern untuk menyimpan text query pencarian pelanggan
final class SearchQueryPelangganProvider
    extends $NotifierProvider<SearchQueryPelanggan, String> {
  /// Provider generator modern untuk menyimpan text query pencarian pelanggan
  SearchQueryPelangganProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryPelangganProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryPelangganHash();

  @$internal
  @override
  SearchQueryPelanggan create() => SearchQueryPelanggan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryPelangganHash() =>
    r'd98c3e64b36f2e986e38ff15fa8338e4b99eb1d2';

/// Provider generator modern untuk menyimpan text query pencarian pelanggan

abstract class _$SearchQueryPelanggan extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

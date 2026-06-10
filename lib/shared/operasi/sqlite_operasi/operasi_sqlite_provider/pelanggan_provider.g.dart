// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider asinkron untuk mengambil semua data customer beserta poin mereka dari SQLite.

@ProviderFor(customerList)
final customerListProvider = CustomerListProvider._();

/// Provider asinkron untuk mengambil semua data customer beserta poin mereka dari SQLite.

final class CustomerListProvider extends $FunctionalProvider<
        AsyncValue<
            List<
                (
                  CustomerModel,
                  int,
                )>>,
        List<
            (
              CustomerModel,
              int,
            )>,
        FutureOr<
            List<
                (
                  CustomerModel,
                  int,
                )>>>
    with
        $FutureModifier<
            List<
                (
                  CustomerModel,
                  int,
                )>>,
        $FutureProvider<
            List<
                (
                  CustomerModel,
                  int,
                )>> {
  /// Provider asinkron untuk mengambil semua data customer beserta poin mereka dari SQLite.
  CustomerListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customerListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerListHash();

  @$internal
  @override
  $FutureProviderElement<
      List<
          (
            CustomerModel,
            int,
          )>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      List<
          (
            CustomerModel,
            int,
          )>> create(Ref ref) {
    return customerList(ref);
  }
}

String _$customerListHash() => r'95c853b8e06ecad07a3915450a8401d4d3e336ba';

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
    r'bf46790b0c49ff9c8da072dc3368a5f8fbae199c';

/// Provider untuk menyimpan state opsi urutan pelanggan yang dipilih oleh user.

abstract class _$UrutanPelangganState extends $Notifier<UrutanPelanggan> {
  UrutanPelanggan build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UrutanPelanggan, UrutanPelanggan>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UrutanPelanggan, UrutanPelanggan>,
        UrutanPelanggan,
        Object?,
        Object?>;
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
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
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
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Provider untuk mengambil detail data satu pelanggan beserta poinnya secara asinkron

@ProviderFor(customerDetail)
final customerDetailProvider = CustomerDetailFamily._();

/// Provider untuk mengambil detail data satu pelanggan beserta poinnya secara asinkron

final class CustomerDetailProvider extends $FunctionalProvider<
        AsyncValue<
            (
              CustomerModel?,
              int,
            )>,
        (
          CustomerModel?,
          int,
        ),
        FutureOr<
            (
              CustomerModel?,
              int,
            )>>
    with
        $FutureModifier<
            (
              CustomerModel?,
              int,
            )>,
        $FutureProvider<
            (
              CustomerModel?,
              int,
            )> {
  /// Provider untuk mengambil detail data satu pelanggan beserta poinnya secara asinkron
  CustomerDetailProvider._(
      {required CustomerDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'customerDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerDetailHash();

  @override
  String toString() {
    return r'customerDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
      (
        CustomerModel?,
        int,
      )> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      (
        CustomerModel?,
        int,
      )> create(Ref ref) {
    final argument = this.argument as String;
    return customerDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerDetailHash() => r'baac615ffb2b665b4a2833d5a8a716092bb53227';

/// Provider untuk mengambil detail data satu pelanggan beserta poinnya secara asinkron

final class CustomerDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                (
                  CustomerModel?,
                  int,
                )>,
            String> {
  CustomerDetailFamily._()
      : super(
          retry: null,
          name: r'customerDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider untuk mengambil detail data satu pelanggan beserta poinnya secara asinkron

  CustomerDetailProvider call(
    String id,
  ) =>
      CustomerDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'customerDetailProvider';
}

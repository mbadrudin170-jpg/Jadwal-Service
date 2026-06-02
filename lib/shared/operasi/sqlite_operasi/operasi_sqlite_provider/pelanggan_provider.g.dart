// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider asinkron untuk mengambil data daftar pelanggan yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.

@ProviderFor(customerList)
final customerListProvider = CustomerListProvider._();

/// Provider asinkron untuk mengambil data daftar pelanggan yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.

final class CustomerListProvider extends $FunctionalProvider<
        AsyncValue<List<CustomerModel>>,
        List<CustomerModel>,
        FutureOr<List<CustomerModel>>>
    with
        $FutureModifier<List<CustomerModel>>,
        $FutureProvider<List<CustomerModel>> {
  /// Provider asinkron untuk mengambil data daftar pelanggan yang aktif dari SQLite.
  /// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.
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
  $FutureProviderElement<List<CustomerModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerModel>> create(Ref ref) {
    return customerList(ref);
  }
}

String _$customerListHash() => r'c2705cf3aa74067c0ca741bb771ebb78c093168d';

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
  void runBuild() {
    final ref = this.ref as $Ref<UrutanPelanggan, UrutanPelanggan>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UrutanPelanggan, UrutanPelanggan>,
        UrutanPelanggan,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

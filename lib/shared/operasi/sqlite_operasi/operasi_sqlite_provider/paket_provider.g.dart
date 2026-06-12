// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider asinkron untuk mengambil data daftar paket yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.

@ProviderFor(packageList)
final packageListProvider = PackageListProvider._();

/// Provider asinkron untuk mengambil data daftar paket yang aktif dari SQLite.
/// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.

final class PackageListProvider extends $FunctionalProvider<
        AsyncValue<List<PaketModel>>,
        List<PaketModel>,
        FutureOr<List<PaketModel>>>
    with $FutureModifier<List<PaketModel>>, $FutureProvider<List<PaketModel>> {
  /// Provider asinkron untuk mengambil data daftar paket yang aktif dari SQLite.
  /// Menggunakan autoDispose (default generator) agar otomatis reset saat halaman ditinggalkan.
  PackageListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'packageListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$packageListHash();

  @$internal
  @override
  $FutureProviderElement<List<PaketModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaketModel>> create(Ref ref) {
    return packageList(ref);
  }
}

String _$packageListHash() => r'73efbd8f71fd1b7c74bcd59221a3ee440d893dea';

/// Provider untuk menyimpan state opsi urutan paket yang dipilih oleh user.

@ProviderFor(UrutanPaketState)
final urutanPaketStateProvider = UrutanPaketStateProvider._();

/// Provider untuk menyimpan state opsi urutan paket yang dipilih oleh user.
final class UrutanPaketStateProvider
    extends $NotifierProvider<UrutanPaketState, UrutanPaket> {
  /// Provider untuk menyimpan state opsi urutan paket yang dipilih oleh user.
  UrutanPaketStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'urutanPaketStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$urutanPaketStateHash();

  @$internal
  @override
  UrutanPaketState create() => UrutanPaketState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrutanPaket value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrutanPaket>(value),
    );
  }
}

String _$urutanPaketStateHash() => r'b2bcbf8b6d251591b8743bfb0e9022ca4945dcbe';

/// Provider untuk menyimpan state opsi urutan paket yang dipilih oleh user.

abstract class _$UrutanPaketState extends $Notifier<UrutanPaket> {
  UrutanPaket build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UrutanPaket, UrutanPaket>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UrutanPaket, UrutanPaket>, UrutanPaket, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

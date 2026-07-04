// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengurut_pelanggan.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UrutanPelangganState)
final urutanPelangganStateProvider = UrutanPelangganStateProvider._();

final class UrutanPelangganStateProvider
    extends $NotifierProvider<UrutanPelangganState, UrutanPelanggan> {
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
    r'00011679e041c63f27338fb6f0bc66cf681c6468';

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

@ProviderFor(pelangganDenganPoin)
final pelangganDenganPoinProvider = PelangganDenganPoinProvider._();

final class PelangganDenganPoinProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<(PelangganModel, int)>>,
          List<(PelangganModel, int)>,
          FutureOr<List<(PelangganModel, int)>>
        >
    with
        $FutureModifier<List<(PelangganModel, int)>>,
        $FutureProvider<List<(PelangganModel, int)>> {
  PelangganDenganPoinProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganDenganPoinProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganDenganPoinHash();

  @$internal
  @override
  $FutureProviderElement<List<(PelangganModel, int)>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<(PelangganModel, int)>> create(Ref ref) {
    return pelangganDenganPoin(ref);
  }
}

String _$pelangganDenganPoinHash() =>
    r'19d437da6f721525032ece1911741ead2cd63e27';

@ProviderFor(filteredCustomers)
final filteredCustomersProvider = FilteredCustomersProvider._();

final class FilteredCustomersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<(PelangganModel, int)>>,
          List<(PelangganModel, int)>,
          FutureOr<List<(PelangganModel, int)>>
        >
    with
        $FutureModifier<List<(PelangganModel, int)>>,
        $FutureProvider<List<(PelangganModel, int)>> {
  FilteredCustomersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredCustomersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredCustomersHash();

  @$internal
  @override
  $FutureProviderElement<List<(PelangganModel, int)>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<(PelangganModel, int)>> create(Ref ref) {
    return filteredCustomers(ref);
  }
}

String _$filteredCustomersHash() => r'1429a200e6f9c3a47b42de96447ab25b1eab8632';

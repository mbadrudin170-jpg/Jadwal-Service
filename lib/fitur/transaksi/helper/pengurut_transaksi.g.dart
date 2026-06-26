// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengurut_transaksi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UrutanTransaksiState)
final urutanTransaksiStateProvider = UrutanTransaksiStateProvider._();

final class UrutanTransaksiStateProvider
    extends $NotifierProvider<UrutanTransaksiState, UrutanTransaksi> {
  UrutanTransaksiStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urutanTransaksiStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urutanTransaksiStateHash();

  @$internal
  @override
  UrutanTransaksiState create() => UrutanTransaksiState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrutanTransaksi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrutanTransaksi>(value),
    );
  }
}

String _$urutanTransaksiStateHash() =>
    r'7ad7b5259a17189c4e9084588c42e8ba890c14d5';

abstract class _$UrutanTransaksiState extends $Notifier<UrutanTransaksi> {
  UrutanTransaksi build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UrutanTransaksi, UrutanTransaksi>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UrutanTransaksi, UrutanTransaksi>,
              UrutanTransaksi,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(sortedTransaksi)
final sortedTransaksiProvider = SortedTransaksiProvider._();

final class SortedTransaksiProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransaksiModel>>,
          List<TransaksiModel>,
          FutureOr<List<TransaksiModel>>
        >
    with
        $FutureModifier<List<TransaksiModel>>,
        $FutureProvider<List<TransaksiModel>> {
  SortedTransaksiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedTransaksiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedTransaksiHash();

  @$internal
  @override
  $FutureProviderElement<List<TransaksiModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransaksiModel>> create(Ref ref) {
    return sortedTransaksi(ref);
  }
}

String _$sortedTransaksiHash() => r'14ff167c295450133995b5280d13357b1b09ddc7';

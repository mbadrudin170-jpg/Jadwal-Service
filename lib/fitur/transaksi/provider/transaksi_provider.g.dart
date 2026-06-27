// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Transaksi)
final transaksiProvider = TransaksiProvider._();

final class TransaksiProvider
    extends $AsyncNotifierProvider<Transaksi, TransaksiState> {
  TransaksiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaksiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaksiHash();

  @$internal
  @override
  Transaksi create() => Transaksi();
}

String _$transaksiHash() => r'4d1edc54eb0473e7e20c4a109e20f43b5c3e8a56';

abstract class _$Transaksi extends $AsyncNotifier<TransaksiState> {
  FutureOr<TransaksiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TransaksiState>, TransaksiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransaksiState>, TransaksiState>,
              AsyncValue<TransaksiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(transaksiPerPelanggan)
final transaksiPerPelangganProvider = TransaksiPerPelangganFamily._();

final class TransaksiPerPelangganProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransaksiModel>>,
          List<TransaksiModel>,
          FutureOr<List<TransaksiModel>>
        >
    with
        $FutureModifier<List<TransaksiModel>>,
        $FutureProvider<List<TransaksiModel>> {
  TransaksiPerPelangganProvider._({
    required TransaksiPerPelangganFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transaksiPerPelangganProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transaksiPerPelangganHash();

  @override
  String toString() {
    return r'transaksiPerPelangganProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TransaksiModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransaksiModel>> create(Ref ref) {
    final argument = this.argument as String;
    return transaksiPerPelanggan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransaksiPerPelangganProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transaksiPerPelangganHash() =>
    r'db98e6e613787fca5e8b775dac5933abffbc4679';

final class TransaksiPerPelangganFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransaksiModel>>, String> {
  TransaksiPerPelangganFamily._()
    : super(
        retry: null,
        name: r'transaksiPerPelangganProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TransaksiPerPelangganProvider call(String idPelanggan) =>
      TransaksiPerPelangganProvider._(argument: idPelanggan, from: this);

  @override
  String toString() => r'transaksiPerPelangganProvider';
}

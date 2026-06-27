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

String _$transaksiHash() => r'fccbed48b61631b2e3c9acc88b76a73af683c152';

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

@ProviderFor(riwayatPoinPelanggan)
final riwayatPoinPelangganProvider = RiwayatPoinPelangganFamily._();

final class RiwayatPoinPelangganProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransaksiModel>>,
          List<TransaksiModel>,
          FutureOr<List<TransaksiModel>>
        >
    with
        $FutureModifier<List<TransaksiModel>>,
        $FutureProvider<List<TransaksiModel>> {
  RiwayatPoinPelangganProvider._({
    required RiwayatPoinPelangganFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riwayatPoinPelangganProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riwayatPoinPelangganHash();

  @override
  String toString() {
    return r'riwayatPoinPelangganProvider'
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
    return riwayatPoinPelanggan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiwayatPoinPelangganProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riwayatPoinPelangganHash() =>
    r'4901bac4405aa3499c5d2d67e23c36f840d64b9d';

final class RiwayatPoinPelangganFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransaksiModel>>, String> {
  RiwayatPoinPelangganFamily._()
    : super(
        retry: null,
        name: r'riwayatPoinPelangganProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RiwayatPoinPelangganProvider call(String idPelanggan) =>
      RiwayatPoinPelangganProvider._(argument: idPelanggan, from: this);

  @override
  String toString() => r'riwayatPoinPelangganProvider';
}

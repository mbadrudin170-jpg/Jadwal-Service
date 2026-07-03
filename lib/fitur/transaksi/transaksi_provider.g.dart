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

String _$transaksiHash() => r'd51b686582e43a3e05ad8d91e043d86ac65f0412';

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

@ProviderFor(riwayatTransaksiPelanggan)
final riwayatTransaksiPelangganProvider = RiwayatTransaksiPelangganFamily._();

final class RiwayatTransaksiPelangganProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int totalPoin, List<TransaksiModel> transaksi})>,
          ({int totalPoin, List<TransaksiModel> transaksi}),
          FutureOr<({int totalPoin, List<TransaksiModel> transaksi})>
        >
    with
        $FutureModifier<({int totalPoin, List<TransaksiModel> transaksi})>,
        $FutureProvider<({int totalPoin, List<TransaksiModel> transaksi})> {
  RiwayatTransaksiPelangganProvider._({
    required RiwayatTransaksiPelangganFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riwayatTransaksiPelangganProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riwayatTransaksiPelangganHash();

  @override
  String toString() {
    return r'riwayatTransaksiPelangganProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<({int totalPoin, List<TransaksiModel> transaksi})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int totalPoin, List<TransaksiModel> transaksi})> create(Ref ref) {
    final argument = this.argument as String;
    return riwayatTransaksiPelanggan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiwayatTransaksiPelangganProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riwayatTransaksiPelangganHash() =>
    r'354b7749528ce46b936fd12b1123ecaaf6bda1ae';

final class RiwayatTransaksiPelangganFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({int totalPoin, List<TransaksiModel> transaksi})>,
          String
        > {
  RiwayatTransaksiPelangganFamily._()
    : super(
        retry: null,
        name: r'riwayatTransaksiPelangganProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RiwayatTransaksiPelangganProvider call(String idPelanggan) =>
      RiwayatTransaksiPelangganProvider._(argument: idPelanggan, from: this);

  @override
  String toString() => r'riwayatTransaksiPelangganProvider';
}

@ProviderFor(ambilBerdasarkanIdPelanggan)
final ambilBerdasarkanIdPelangganProvider =
    AmbilBerdasarkanIdPelangganFamily._();

final class AmbilBerdasarkanIdPelangganProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransaksiModel>>,
          List<TransaksiModel>,
          FutureOr<List<TransaksiModel>>
        >
    with
        $FutureModifier<List<TransaksiModel>>,
        $FutureProvider<List<TransaksiModel>> {
  AmbilBerdasarkanIdPelangganProvider._({
    required AmbilBerdasarkanIdPelangganFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ambilBerdasarkanIdPelangganProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ambilBerdasarkanIdPelangganHash();

  @override
  String toString() {
    return r'ambilBerdasarkanIdPelangganProvider'
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
    return ambilBerdasarkanIdPelanggan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AmbilBerdasarkanIdPelangganProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ambilBerdasarkanIdPelangganHash() =>
    r'1c8553214c1e46644e83fae77251cef6ec393e09';

final class AmbilBerdasarkanIdPelangganFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransaksiModel>>, String> {
  AmbilBerdasarkanIdPelangganFamily._()
    : super(
        retry: null,
        name: r'ambilBerdasarkanIdPelangganProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AmbilBerdasarkanIdPelangganProvider call(String idPelanggan) =>
      AmbilBerdasarkanIdPelangganProvider._(argument: idPelanggan, from: this);

  @override
  String toString() => r'ambilBerdasarkanIdPelangganProvider';
}

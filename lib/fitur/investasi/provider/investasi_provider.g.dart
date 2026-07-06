// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investasi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InvestasiNotifier)
final investasiProvider = InvestasiNotifierProvider._();

final class InvestasiNotifierProvider
    extends $AsyncNotifierProvider<InvestasiNotifier, InvestasiState> {
  InvestasiNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'investasiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$investasiNotifierHash();

  @$internal
  @override
  InvestasiNotifier create() => InvestasiNotifier();
}

String _$investasiNotifierHash() => r'aecb081008bc6fdd09065125286190177a1f59a7';

abstract class _$InvestasiNotifier extends $AsyncNotifier<InvestasiState> {
  FutureOr<InvestasiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<InvestasiState>, InvestasiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<InvestasiState>, InvestasiState>,
              AsyncValue<InvestasiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider untuk mendapatkan data investasi investor tertentu

@ProviderFor(detailInvestorInvestasi)
final detailInvestorInvestasiProvider = DetailInvestorInvestasiFamily._();

/// Provider untuk mendapatkan data investasi investor tertentu

final class DetailInvestorInvestasiProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({List<DividenModel> dividen, List<InvestasiModel> investasi})
          >,
          ({List<DividenModel> dividen, List<InvestasiModel> investasi}),
          FutureOr<
            ({List<DividenModel> dividen, List<InvestasiModel> investasi})
          >
        >
    with
        $FutureModifier<
          ({List<DividenModel> dividen, List<InvestasiModel> investasi})
        >,
        $FutureProvider<
          ({List<DividenModel> dividen, List<InvestasiModel> investasi})
        > {
  /// Provider untuk mendapatkan data investasi investor tertentu
  DetailInvestorInvestasiProvider._({
    required DetailInvestorInvestasiFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailInvestorInvestasiProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailInvestorInvestasiHash();

  @override
  String toString() {
    return r'detailInvestorInvestasiProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
    ({List<DividenModel> dividen, List<InvestasiModel> investasi})
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({List<DividenModel> dividen, List<InvestasiModel> investasi})>
  create(Ref ref) {
    final argument = this.argument as String;
    return detailInvestorInvestasi(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailInvestorInvestasiProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailInvestorInvestasiHash() =>
    r'f5513f94963dc6c871e5698a2cfaee37218e5a98';

/// Provider untuk mendapatkan data investasi investor tertentu

final class DetailInvestorInvestasiFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<
            ({List<DividenModel> dividen, List<InvestasiModel> investasi})
          >,
          String
        > {
  DetailInvestorInvestasiFamily._()
    : super(
        retry: null,
        name: r'detailInvestorInvestasiProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider untuk mendapatkan data investasi investor tertentu

  DetailInvestorInvestasiProvider call(String idInvestor) =>
      DetailInvestorInvestasiProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'detailInvestorInvestasiProvider';
}

/// Provider untuk mendapatkan total modal investor

@ProviderFor(totalModalInvestor)
final totalModalInvestorProvider = TotalModalInvestorFamily._();

/// Provider untuk mendapatkan total modal investor

final class TotalModalInvestorProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Provider untuk mendapatkan total modal investor
  TotalModalInvestorProvider._({
    required TotalModalInvestorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalModalInvestorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalModalInvestorHash();

  @override
  String toString() {
    return r'totalModalInvestorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return totalModalInvestor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalModalInvestorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalModalInvestorHash() =>
    r'b9d2c3c0c437db6972aa1f9f4e9fe259b0cd3235';

/// Provider untuk mendapatkan total modal investor

final class TotalModalInvestorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  TotalModalInvestorFamily._()
    : super(
        retry: null,
        name: r'totalModalInvestorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider untuk mendapatkan total modal investor

  TotalModalInvestorProvider call(String idInvestor) =>
      TotalModalInvestorProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'totalModalInvestorProvider';
}

/// Provider untuk mendapatkan total dividen investor

@ProviderFor(totalDividenInvestor)
final totalDividenInvestorProvider = TotalDividenInvestorFamily._();

/// Provider untuk mendapatkan total dividen investor

final class TotalDividenInvestorProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Provider untuk mendapatkan total dividen investor
  TotalDividenInvestorProvider._({
    required TotalDividenInvestorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalDividenInvestorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalDividenInvestorHash();

  @override
  String toString() {
    return r'totalDividenInvestorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return totalDividenInvestor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalDividenInvestorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalDividenInvestorHash() =>
    r'00d2ce9b4d4ed4709bddfdb0b25f57c665ea571e';

/// Provider untuk mendapatkan total dividen investor

final class TotalDividenInvestorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  TotalDividenInvestorFamily._()
    : super(
        retry: null,
        name: r'totalDividenInvestorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider untuk mendapatkan total dividen investor

  TotalDividenInvestorProvider call(String idInvestor) =>
      TotalDividenInvestorProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'totalDividenInvestorProvider';
}

/// Provider untuk mendapatkan total persentase investor

@ProviderFor(totalPersentaseInvestor)
final totalPersentaseInvestorProvider = TotalPersentaseInvestorFamily._();

/// Provider untuk mendapatkan total persentase investor

final class TotalPersentaseInvestorProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  /// Provider untuk mendapatkan total persentase investor
  TotalPersentaseInvestorProvider._({
    required TotalPersentaseInvestorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalPersentaseInvestorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalPersentaseInvestorHash();

  @override
  String toString() {
    return r'totalPersentaseInvestorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return totalPersentaseInvestor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalPersentaseInvestorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalPersentaseInvestorHash() =>
    r'b46fc9ef94826e8655dae7fb5e328a5d0c5660a0';

/// Provider untuk mendapatkan total persentase investor

final class TotalPersentaseInvestorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  TotalPersentaseInvestorFamily._()
    : super(
        retry: null,
        name: r'totalPersentaseInvestorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider untuk mendapatkan total persentase investor

  TotalPersentaseInvestorProvider call(String idInvestor) =>
      TotalPersentaseInvestorProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'totalPersentaseInvestorProvider';
}

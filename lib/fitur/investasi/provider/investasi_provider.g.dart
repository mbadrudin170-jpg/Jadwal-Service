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

String _$investasiNotifierHash() => r'0c25612789ee2ed04ae79dc189b3faac2c1a346d';

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

@ProviderFor(detailInvestorInvestasi)
final detailInvestorInvestasiProvider = DetailInvestorInvestasiFamily._();

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
    r'59c3a8337cc21a4bd899a41835d171e7075090f9';

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

  DetailInvestorInvestasiProvider call(String idInvestor) =>
      DetailInvestorInvestasiProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'detailInvestorInvestasiProvider';
}

@ProviderFor(totalModalInvestor)
final totalModalInvestorProvider = TotalModalInvestorFamily._();

final class TotalModalInvestorProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
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
    r'486defab84fbfe7b00c5ccbeb1e4c97352ec7453';

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

  TotalModalInvestorProvider call(String idInvestor) =>
      TotalModalInvestorProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'totalModalInvestorProvider';
}

@ProviderFor(totalDividenInvestor)
final totalDividenInvestorProvider = TotalDividenInvestorFamily._();

final class TotalDividenInvestorProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
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
    r'9feb35fbcf68186d7ae9413a22fc088407cbd456';

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

  TotalDividenInvestorProvider call(String idInvestor) =>
      TotalDividenInvestorProvider._(argument: idInvestor, from: this);

  @override
  String toString() => r'totalDividenInvestorProvider';
}

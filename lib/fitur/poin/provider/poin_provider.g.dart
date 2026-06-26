// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Poin)
final poinProvider = PoinFamily._();

final class PoinProvider extends $AsyncNotifierProvider<Poin, PoinState> {
  PoinProvider._({
    required PoinFamily super.from,
    required (Ref, String) super.argument,
  }) : super(
         retry: null,
         name: r'poinProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$poinHash();

  @override
  String toString() {
    return r'poinProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  Poin create() => Poin();

  @override
  bool operator ==(Object other) {
    return other is PoinProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$poinHash() => r'7a1dc7aa51ae4c63d22063b3f8d68046339bb078';

final class PoinFamily extends $Family
    with
        $ClassFamilyOverride<
          Poin,
          AsyncValue<PoinState>,
          PoinState,
          FutureOr<PoinState>,
          (Ref, String)
        > {
  PoinFamily._()
    : super(
        retry: null,
        name: r'poinProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PoinProvider call(Ref ref, String idPelanggan) =>
      PoinProvider._(argument: (ref, idPelanggan), from: this);

  @override
  String toString() => r'poinProvider';
}

abstract class _$Poin extends $AsyncNotifier<PoinState> {
  late final _$args = ref.$arg as (Ref, String);
  Ref get ref => _$args.$1;
  String get idPelanggan => _$args.$2;

  FutureOr<PoinState> build(Ref ref, String idPelanggan);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PoinState>, PoinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PoinState>, PoinState>,
              AsyncValue<PoinState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(pointsDataSource)
final pointsDataSourceProvider = PointsDataSourceProvider._();

final class PointsDataSourceProvider
    extends
        $FunctionalProvider<
          PointsPageDataSource,
          PointsPageDataSource,
          PointsPageDataSource
        >
    with $Provider<PointsPageDataSource> {
  PointsDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pointsDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointsDataSourceHash();

  @$internal
  @override
  $ProviderElement<PointsPageDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PointsPageDataSource create(Ref ref) {
    return pointsDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PointsPageDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PointsPageDataSource>(value),
    );
  }
}

String _$pointsDataSourceHash() => r'5fed4c856d5a4960ef292facb1c590d69c9280d5';

@ProviderFor(pointsPageData)
final pointsPageDataProvider = PointsPageDataFamily._();

final class PointsPageDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<PointsPageData>,
          PointsPageData,
          FutureOr<PointsPageData>
        >
    with $FutureModifier<PointsPageData>, $FutureProvider<PointsPageData> {
  PointsPageDataProvider._({
    required PointsPageDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pointsPageDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pointsPageDataHash();

  @override
  String toString() {
    return r'pointsPageDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PointsPageData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PointsPageData> create(Ref ref) {
    final argument = this.argument as String;
    return pointsPageData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PointsPageDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pointsPageDataHash() => r'bcbdc2f48789b311ce5a5f09c5ce5764e7a5f8f8';

final class PointsPageDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PointsPageData>, String> {
  PointsPageDataFamily._()
    : super(
        retry: null,
        name: r'pointsPageDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PointsPageDataProvider call(String idPelanggan) =>
      PointsPageDataProvider._(argument: idPelanggan, from: this);

  @override
  String toString() => r'pointsPageDataProvider';
}

@ProviderFor(pointsHistory)
final pointsHistoryProvider = PointsHistoryFamily._();

final class PointsHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransaksiModel>>,
          List<TransaksiModel>,
          FutureOr<List<TransaksiModel>>
        >
    with
        $FutureModifier<List<TransaksiModel>>,
        $FutureProvider<List<TransaksiModel>> {
  PointsHistoryProvider._({
    required PointsHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pointsHistoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pointsHistoryHash();

  @override
  String toString() {
    return r'pointsHistoryProvider'
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
    return pointsHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PointsHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pointsHistoryHash() => r'4849e8f01da7196e1723fa0f4dd66b4753fbff63';

final class PointsHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransaksiModel>>, String> {
  PointsHistoryFamily._()
    : super(
        retry: null,
        name: r'pointsHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PointsHistoryProvider call(String idPelanggan) =>
      PointsHistoryProvider._(argument: idPelanggan, from: this);

  @override
  String toString() => r'pointsHistoryProvider';
}

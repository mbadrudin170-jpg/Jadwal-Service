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
  PoinProvider._(
      {required PoinFamily super.from, required String super.argument})
      : super(
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
        '($argument)';
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

String _$poinHash() => r'd5e0d3fd8fee54d55dabb78a309e380fceff62b2';

final class PoinFamily extends $Family
    with
        $ClassFamilyOverride<Poin, AsyncValue<PoinState>, PoinState,
            FutureOr<PoinState>, String> {
  PoinFamily._()
      : super(
          retry: null,
          name: r'poinProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PoinProvider call(
    String customerId,
  ) =>
      PoinProvider._(argument: customerId, from: this);

  @override
  String toString() => r'poinProvider';
}

abstract class _$Poin extends $AsyncNotifier<PoinState> {
  late final _$args = ref.$arg as String;
  String get customerId => _$args;

  FutureOr<PoinState> build(
    String customerId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PoinState>, PoinState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PoinState>, PoinState>,
        AsyncValue<PoinState>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(pointsDataSource)
final pointsDataSourceProvider = PointsDataSourceProvider._();

final class PointsDataSourceProvider extends $FunctionalProvider<
    PointsPageDataSource,
    PointsPageDataSource,
    PointsPageDataSource> with $Provider<PointsPageDataSource> {
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
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

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

String _$pointsDataSourceHash() => r'9feb7a5adaf71fc41220f2264cb5907c2ed38059';

@ProviderFor(pointsPageData)
final pointsPageDataProvider = PointsPageDataFamily._();

final class PointsPageDataProvider extends $FunctionalProvider<
        AsyncValue<PointsPageData>, PointsPageData, FutureOr<PointsPageData>>
    with $FutureModifier<PointsPageData>, $FutureProvider<PointsPageData> {
  PointsPageDataProvider._(
      {required PointsPageDataFamily super.from,
      required String super.argument})
      : super(
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
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PointsPageData> create(Ref ref) {
    final argument = this.argument as String;
    return pointsPageData(
      ref,
      argument,
    );
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

String _$pointsPageDataHash() => r'c5d811a6de7915b5b086a7a5ef7db681205ba0f2';

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

  PointsPageDataProvider call(
    String customerId,
  ) =>
      PointsPageDataProvider._(argument: customerId, from: this);

  @override
  String toString() => r'pointsPageDataProvider';
}

@ProviderFor(pointsHistory)
final pointsHistoryProvider = PointsHistoryFamily._();

final class PointsHistoryProvider extends $FunctionalProvider<
        AsyncValue<List<TransactionModel>>,
        List<TransactionModel>,
        FutureOr<List<TransactionModel>>>
    with
        $FutureModifier<List<TransactionModel>>,
        $FutureProvider<List<TransactionModel>> {
  PointsHistoryProvider._(
      {required PointsHistoryFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'pointsHistoryProvider',
          isAutoDispose: true,
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
  $FutureProviderElement<List<TransactionModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransactionModel>> create(Ref ref) {
    final argument = this.argument as String;
    return pointsHistory(
      ref,
      argument,
    );
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

String _$pointsHistoryHash() => r'f9a8be686559629aebe8db1978f853829d8bef9d';

final class PointsHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransactionModel>>, String> {
  PointsHistoryFamily._()
      : super(
          retry: null,
          name: r'pointsHistoryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  PointsHistoryProvider call(
    String customerId,
  ) =>
      PointsHistoryProvider._(argument: customerId, from: this);

  @override
  String toString() => r'pointsHistoryProvider';
}

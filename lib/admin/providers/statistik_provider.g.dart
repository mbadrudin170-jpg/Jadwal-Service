// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistik_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Statistik)
final statistikProvider = StatistikProvider._();

final class StatistikProvider
    extends $AsyncNotifierProvider<Statistik, StatistikState> {
  StatistikProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statistikProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statistikHash();

  @$internal
  @override
  Statistik create() => Statistik();
}

String _$statistikHash() => r'b689cfe1b6d47d1028c5a82a1b999ac2bbee1749';

abstract class _$Statistik extends $AsyncNotifier<StatistikState> {
  FutureOr<StatistikState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StatistikState>, StatistikState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<StatistikState>, StatistikState>,
        AsyncValue<StatistikState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

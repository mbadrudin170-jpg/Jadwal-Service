// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operasi_baca_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OperasiBacaProvider)
final operasiBacaProviderProvider = OperasiBacaProviderProvider._();

final class OperasiBacaProviderProvider
    extends $AsyncNotifierProvider<OperasiBacaProvider, OperasiBacaState> {
  OperasiBacaProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'operasiBacaProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$operasiBacaProviderHash();

  @$internal
  @override
  OperasiBacaProvider create() => OperasiBacaProvider();
}

String _$operasiBacaProviderHash() =>
    r'9af726be7e4045eee2cd3dc6524c86183cffb6ed';

abstract class _$OperasiBacaProvider extends $AsyncNotifier<OperasiBacaState> {
  FutureOr<OperasiBacaState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<OperasiBacaState>, OperasiBacaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OperasiBacaState>, OperasiBacaState>,
              AsyncValue<OperasiBacaState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

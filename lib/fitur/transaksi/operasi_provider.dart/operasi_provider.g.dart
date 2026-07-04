// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operasi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OperasiProvider)
final operasiProviderProvider = OperasiProviderProvider._();

final class OperasiProviderProvider
    extends $AsyncNotifierProvider<OperasiProvider, TransaksiTesState> {
  OperasiProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'operasiProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$operasiProviderHash();

  @$internal
  @override
  OperasiProvider create() => OperasiProvider();
}

String _$operasiProviderHash() => r'5a2a7e12f0ea2e00615622c5eeba26472a5e0024';

abstract class _$OperasiProvider extends $AsyncNotifier<TransaksiTesState> {
  FutureOr<TransaksiTesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransaksiTesState>, TransaksiTesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransaksiTesState>, TransaksiTesState>,
              AsyncValue<TransaksiTesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

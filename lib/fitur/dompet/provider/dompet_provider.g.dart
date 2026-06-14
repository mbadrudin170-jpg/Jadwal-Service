// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dompet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Dompet)
final dompetProvider = DompetProvider._();

final class DompetProvider extends $AsyncNotifierProvider<Dompet, DompetState> {
  DompetProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dompetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dompetHash();

  @$internal
  @override
  Dompet create() => Dompet();
}

String _$dompetHash() => r'c8f87b4654fef10211b87b9f16c2e04f6329a9fe';

abstract class _$Dompet extends $AsyncNotifier<DompetState> {
  FutureOr<DompetState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DompetState>, DompetState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<DompetState>, DompetState>,
        AsyncValue<DompetState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

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

String _$dompetHash() => r'b068af33c16b891d5948e4c75897bf32e43c1acb';

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

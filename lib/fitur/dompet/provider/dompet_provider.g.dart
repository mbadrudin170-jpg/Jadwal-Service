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

String _$dompetHash() => r'1d7c2433ccf492b780a0ca9427d4bfde347b1df1';

abstract class _$Dompet extends $AsyncNotifier<DompetState> {
  FutureOr<DompetState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DompetState>, DompetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DompetState>, DompetState>,
              AsyncValue<DompetState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(detailDompet)
final detailDompetProvider = DetailDompetFamily._();

final class DetailDompetProvider
    extends
        $FunctionalProvider<
          AsyncValue<DetailDompetState>,
          DetailDompetState,
          FutureOr<DetailDompetState>
        >
    with
        $FutureModifier<DetailDompetState>,
        $FutureProvider<DetailDompetState> {
  DetailDompetProvider._({
    required DetailDompetFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailDompetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailDompetHash();

  @override
  String toString() {
    return r'detailDompetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DetailDompetState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DetailDompetState> create(Ref ref) {
    final argument = this.argument as String;
    return detailDompet(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailDompetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailDompetHash() => r'177efee8e6a17445649c5e2e00515d48bca3e270';

final class DetailDompetFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DetailDompetState>, String> {
  DetailDompetFamily._()
    : super(
        retry: null,
        name: r'detailDompetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailDompetProvider call(String idDompet) =>
      DetailDompetProvider._(argument: idDompet, from: this);

  @override
  String toString() => r'detailDompetProvider';
}

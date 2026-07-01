// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Paket)
final paketProvider = PaketProvider._();

final class PaketProvider extends $AsyncNotifierProvider<Paket, PaketState> {
  PaketProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paketProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paketHash();

  @$internal
  @override
  Paket create() => Paket();
}

String _$paketHash() => r'035fe50a6f279f2316e7412c89b48a9c4e21e767';

abstract class _$Paket extends $AsyncNotifier<PaketState> {
  FutureOr<PaketState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PaketState>, PaketState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaketState>, PaketState>,
              AsyncValue<PaketState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(UrutanPaketState)
final urutanPaketStateProvider = UrutanPaketStateProvider._();

final class UrutanPaketStateProvider
    extends $NotifierProvider<UrutanPaketState, UrutanPaket> {
  UrutanPaketStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urutanPaketStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urutanPaketStateHash();

  @$internal
  @override
  UrutanPaketState create() => UrutanPaketState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UrutanPaket value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UrutanPaket>(value),
    );
  }
}

String _$urutanPaketStateHash() => r'b2bcbf8b6d251591b8743bfb0e9022ca4945dcbe';

abstract class _$UrutanPaketState extends $Notifier<UrutanPaket> {
  UrutanPaket build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UrutanPaket, UrutanPaket>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UrutanPaket, UrutanPaket>,
              UrutanPaket,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(detailPaket)
final detailPaketProvider = DetailPaketFamily._();

final class DetailPaketProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaketModel>,
          PaketModel,
          FutureOr<PaketModel>
        >
    with $FutureModifier<PaketModel>, $FutureProvider<PaketModel> {
  DetailPaketProvider._({
    required DetailPaketFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailPaketProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailPaketHash();

  @override
  String toString() {
    return r'detailPaketProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaketModel> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PaketModel> create(Ref ref) {
    final argument = this.argument as String;
    return detailPaket(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailPaketProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailPaketHash() => r'50b17c83ded1f696610458751fee28c61eac43a2';

final class DetailPaketFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PaketModel>, String> {
  DetailPaketFamily._()
    : super(
        retry: null,
        name: r'detailPaketProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailPaketProvider call(String id) =>
      DetailPaketProvider._(argument: id, from: this);

  @override
  String toString() => r'detailPaketProvider';
}

@ProviderFor(namaPaket)
final namaPaketProvider = NamaPaketFamily._();

final class NamaPaketProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  NamaPaketProvider._({
    required NamaPaketFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'namaPaketProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$namaPaketHash();

  @override
  String toString() {
    return r'namaPaketProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return namaPaket(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NamaPaketProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$namaPaketHash() => r'366675c6d635e239a201e15c2dfa4693e7c67374';

final class NamaPaketFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  NamaPaketFamily._()
    : super(
        retry: null,
        name: r'namaPaketProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NamaPaketProvider call(String idPaket) =>
      NamaPaketProvider._(argument: idPaket, from: this);

  @override
  String toString() => r'namaPaketProvider';
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'akun_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PengelolaAkun)
final pengelolaAkunProvider = PengelolaAkunProvider._();

final class PengelolaAkunProvider
    extends $AsyncNotifierProvider<PengelolaAkun, AkunState> {
  PengelolaAkunProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pengelolaAkunProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pengelolaAkunHash();

  @$internal
  @override
  PengelolaAkun create() => PengelolaAkun();
}

String _$pengelolaAkunHash() => r'7f1a1e05c894d7ba5a950cb96a320bb82a9f5fc7';

abstract class _$PengelolaAkun extends $AsyncNotifier<AkunState> {
  FutureOr<AkunState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AkunState>, AkunState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AkunState>, AkunState>,
        AsyncValue<AkunState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

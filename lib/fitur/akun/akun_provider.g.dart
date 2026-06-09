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

String _$pengelolaAkunHash() => r'f631261836172a3599be32b303e3747f66a106d2';

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

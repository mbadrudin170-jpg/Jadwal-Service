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
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pengelolaAkunHash();

  @$internal
  @override
  PengelolaAkun create() => PengelolaAkun();
}

String _$pengelolaAkunHash() => r'ba76bd1084517e5309c25756509fef9e9bd68a69';

abstract class _$PengelolaAkun extends $AsyncNotifier<AkunState> {
  FutureOr<AkunState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AkunState>, AkunState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AkunState>, AkunState>,
              AsyncValue<AkunState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

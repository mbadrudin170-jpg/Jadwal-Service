// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pelanggan_aktif_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PelangganAktif)
final pelangganAktifProvider = PelangganAktifProvider._();

final class PelangganAktifProvider
    extends $AsyncNotifierProvider<PelangganAktif, PelangganAktifState> {
  PelangganAktifProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganAktifProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganAktifHash();

  @$internal
  @override
  PelangganAktif create() => PelangganAktif();
}

String _$pelangganAktifHash() => r'1e6b361f16a5afc9f36f0cc3a4366aa942ae5759';

abstract class _$PelangganAktif extends $AsyncNotifier<PelangganAktifState> {
  FutureOr<PelangganAktifState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PelangganAktifState>, PelangganAktifState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PelangganAktifState>, PelangganAktifState>,
              AsyncValue<PelangganAktifState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

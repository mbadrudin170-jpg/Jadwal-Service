// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Transaksi)
final transaksiProvider = TransaksiProvider._();

final class TransaksiProvider
    extends $AsyncNotifierProvider<Transaksi, TransaksiState> {
  TransaksiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaksiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaksiHash();

  @$internal
  @override
  Transaksi create() => Transaksi();
}

String _$transaksiHash() => r'6c8e20f3d6a4493d0feafb0744fb34317735a12e';

abstract class _$Transaksi extends $AsyncNotifier<TransaksiState> {
  FutureOr<TransaksiState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TransaksiState>, TransaksiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransaksiState>, TransaksiState>,
              AsyncValue<TransaksiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

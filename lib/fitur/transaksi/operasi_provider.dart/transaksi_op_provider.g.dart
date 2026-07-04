// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_op_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransaksiOp)
final transaksiOpProvider = TransaksiOpProvider._();

final class TransaksiOpProvider
    extends $AsyncNotifierProvider<TransaksiOp, TransaksiNotifierState> {
  TransaksiOpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaksiOpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaksiOpHash();

  @$internal
  @override
  TransaksiOp create() => TransaksiOp();
}

String _$transaksiOpHash() => r'a1afb7f6b6670dd60fabfa6c261e2fe66a64ffac';

abstract class _$TransaksiOp extends $AsyncNotifier<TransaksiNotifierState> {
  FutureOr<TransaksiNotifierState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TransaksiNotifierState>, TransaksiNotifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TransaksiNotifierState>,
                TransaksiNotifierState
              >,
              AsyncValue<TransaksiNotifierState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

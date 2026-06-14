// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Transaction)
final transactionProvider = TransactionProvider._();

final class TransactionProvider
    extends $AsyncNotifierProvider<Transaction, TransactionState> {
  TransactionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionHash();

  @$internal
  @override
  Transaction create() => Transaction();
}

String _$transactionHash() => r'66171c8a76a000e38a1f0407263095ad6d3681b1';

abstract class _$Transaction extends $AsyncNotifier<TransactionState> {
  FutureOr<TransactionState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransactionState>, TransactionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TransactionState>, TransactionState>,
        AsyncValue<TransactionState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

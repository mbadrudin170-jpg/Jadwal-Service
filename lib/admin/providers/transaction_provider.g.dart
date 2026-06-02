// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

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

String _$transactionHash() => r'8afd3a01d985638475b23f7a97a87dceefe0a1be';

abstract class _$Transaction extends $AsyncNotifier<TransactionState> {
  FutureOr<TransactionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransactionState>, TransactionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TransactionState>, TransactionState>,
        AsyncValue<TransactionState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

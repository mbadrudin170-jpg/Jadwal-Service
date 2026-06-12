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

String _$transactionHash() => r'd66b62c5e336eca82b5efaf02db179f4b099257c';

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

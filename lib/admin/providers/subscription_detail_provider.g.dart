// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getSubscriptionDetail)
final getSubscriptionDetailProvider = GetSubscriptionDetailFamily._();

final class GetSubscriptionDetailProvider extends $FunctionalProvider<
        AsyncValue<SubscriptionDetailState?>,
        SubscriptionDetailState?,
        FutureOr<SubscriptionDetailState?>>
    with
        $FutureModifier<SubscriptionDetailState?>,
        $FutureProvider<SubscriptionDetailState?> {
  GetSubscriptionDetailProvider._(
      {required GetSubscriptionDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'getSubscriptionDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getSubscriptionDetailHash();

  @override
  String toString() {
    return r'getSubscriptionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SubscriptionDetailState?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionDetailState?> create(Ref ref) {
    final argument = this.argument as String;
    return getSubscriptionDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetSubscriptionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getSubscriptionDetailHash() =>
    r'43045afce0b79734caaf919f4e52e589f2225d6c';

final class GetSubscriptionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SubscriptionDetailState?>, String> {
  GetSubscriptionDetailFamily._()
      : super(
          retry: null,
          name: r'getSubscriptionDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  GetSubscriptionDetailProvider call(
    String transactionId,
  ) =>
      GetSubscriptionDetailProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'getSubscriptionDetailProvider';
}

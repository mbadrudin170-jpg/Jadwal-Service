// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveCustomer)
final activeCustomerProvider = ActiveCustomerProvider._();

final class ActiveCustomerProvider
    extends $AsyncNotifierProvider<ActiveCustomer, ActiveCustomerState> {
  ActiveCustomerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeCustomerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeCustomerHash();

  @$internal
  @override
  ActiveCustomer create() => ActiveCustomer();
}

String _$activeCustomerHash() => r'7789a397a310f10cfe103b36aa900240fc7c3077';

abstract class _$ActiveCustomer extends $AsyncNotifier<ActiveCustomerState> {
  FutureOr<ActiveCustomerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ActiveCustomerState>, ActiveCustomerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ActiveCustomerState>, ActiveCustomerState>,
        AsyncValue<ActiveCustomerState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

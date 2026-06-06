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
    extends $NotifierProvider<ActiveCustomer, ActiveCustomerState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveCustomerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveCustomerState>(value),
    );
  }
}

String _$activeCustomerHash() => r'8ab739106dc33685ad13b0ab7ba6009559c219fc';

abstract class _$ActiveCustomer extends $Notifier<ActiveCustomerState> {
  ActiveCustomerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ActiveCustomerState, ActiveCustomerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ActiveCustomerState, ActiveCustomerState>,
        ActiveCustomerState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Order)
final orderProvider = OrderProvider._();

final class OrderProvider extends $AsyncNotifierProvider<Order, OrderState> {
  OrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderHash();

  @$internal
  @override
  Order create() => Order();
}

String _$orderHash() => r'46667c0c098b9eb6581c0aac9716da4499edf473';

abstract class _$Order extends $AsyncNotifier<OrderState> {
  FutureOr<OrderState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OrderState>, OrderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OrderState>, OrderState>,
              AsyncValue<OrderState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

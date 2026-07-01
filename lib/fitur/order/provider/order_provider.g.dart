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

String _$orderHash() => r'5aefaa58768561d0af317a2d0cb3b2008bbd5ea7';

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

@ProviderFor(daftarPesanan)
final daftarPesananProvider = DaftarPesananProvider._();

final class DaftarPesananProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderModel>>,
          List<OrderModel>,
          FutureOr<List<OrderModel>>
        >
    with $FutureModifier<List<OrderModel>>, $FutureProvider<List<OrderModel>> {
  DaftarPesananProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'daftarPesananProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$daftarPesananHash();

  @$internal
  @override
  $FutureProviderElement<List<OrderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderModel>> create(Ref ref) {
    return daftarPesanan(ref);
  }
}

String _$daftarPesananHash() => r'9d650571c28b5c1b23bdef7cbd312befde5eba16';

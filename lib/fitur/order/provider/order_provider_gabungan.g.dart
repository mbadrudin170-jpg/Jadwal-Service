// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider_gabungan.dart';

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

String _$orderHash() => r'54e0bdb53c18283126fa64383c01e63c16229821';

abstract class _$Order extends $AsyncNotifier<OrderState> {
  FutureOr<OrderState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OrderState>, OrderState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<OrderState>, OrderState>,
        AsyncValue<OrderState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(daftarPesanan)
final daftarPesananProvider = DaftarPesananProvider._();

final class DaftarPesananProvider extends $FunctionalProvider<
        AsyncValue<List<OrderModel>>,
        List<OrderModel>,
        FutureOr<List<OrderModel>>>
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
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderModel>> create(Ref ref) {
    return daftarPesanan(ref);
  }
}

String _$daftarPesananHash() => r'4369811eda0620a407d6a40dd7bef16f1b555298';

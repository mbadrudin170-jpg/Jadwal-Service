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

String _$orderHash() => r'38d1329e22adc3c60c2f94864373ddbcdb0130f0';

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

String _$daftarPesananHash() => r'b123136a10fee76f439e4812bdff19a61dedb5f0';

@ProviderFor(daftar)
final daftarProvider = DaftarFamily._();

final class DaftarProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderModel>>,
          List<OrderModel>,
          FutureOr<List<OrderModel>>
        >
    with $FutureModifier<List<OrderModel>>, $FutureProvider<List<OrderModel>> {
  DaftarProvider._({
    required DaftarFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'daftarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$daftarHash();

  @override
  String toString() {
    return r'daftarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OrderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderModel>> create(Ref ref) {
    final argument = this.argument as String;
    return daftar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DaftarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$daftarHash() => r'18aaa9753b4c3464630f41bc6069cf45d43bc472';

final class DaftarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OrderModel>>, String> {
  DaftarFamily._()
    : super(
        retry: null,
        name: r'daftarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DaftarProvider call(String id) => DaftarProvider._(argument: id, from: this);

  @override
  String toString() => r'daftarProvider';
}

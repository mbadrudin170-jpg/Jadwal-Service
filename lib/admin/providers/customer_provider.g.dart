// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerNotifier)
final customerProvider = CustomerNotifierProvider._();

final class CustomerNotifierProvider
    extends $AsyncNotifierProvider<CustomerNotifier, List<PelangganModel>> {
  CustomerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerNotifierHash();

  @$internal
  @override
  CustomerNotifier create() => CustomerNotifier();
}

String _$customerNotifierHash() => r'3bf96388f2ea6a63703ef1e24ec354c3d0e075b2';

abstract class _$CustomerNotifier extends $AsyncNotifier<List<PelangganModel>> {
  FutureOr<List<PelangganModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<PelangganModel>>, List<PelangganModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<PelangganModel>>,
                List<PelangganModel>
              >,
              AsyncValue<List<PelangganModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

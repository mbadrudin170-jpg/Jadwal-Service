// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Voucher)
final voucherProvider = VoucherProvider._();

final class VoucherProvider
    extends $AsyncNotifierProvider<Voucher, VoucherState> {
  VoucherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voucherProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voucherHash();

  @$internal
  @override
  Voucher create() => Voucher();
}

String _$voucherHash() => r'701566d0f04b418558dfb6ff1f280caa65ebd782';

abstract class _$Voucher extends $AsyncNotifier<VoucherState> {
  FutureOr<VoucherState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VoucherState>, VoucherState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VoucherState>, VoucherState>,
              AsyncValue<VoucherState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

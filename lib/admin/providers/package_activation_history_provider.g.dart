// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_activation_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PackageActivationHistory)
final packageActivationHistoryProvider = PackageActivationHistoryProvider._();

final class PackageActivationHistoryProvider extends $AsyncNotifierProvider<
    PackageActivationHistory, PackageActivationHistoryState> {
  PackageActivationHistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'packageActivationHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$packageActivationHistoryHash();

  @$internal
  @override
  PackageActivationHistory create() => PackageActivationHistory();
}

String _$packageActivationHistoryHash() =>
    r'9ccfdfdb83d241ea4a683aad909aa0ca0641692e';

abstract class _$PackageActivationHistory
    extends $AsyncNotifier<PackageActivationHistoryState> {
  FutureOr<PackageActivationHistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PackageActivationHistoryState>,
        PackageActivationHistoryState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PackageActivationHistoryState>,
            PackageActivationHistoryState>,
        AsyncValue<PackageActivationHistoryState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

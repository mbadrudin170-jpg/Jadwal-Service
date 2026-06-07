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
    r'f4a352af4ac9d4720f85ca6337ea761feed4aa83';

abstract class _$PackageActivationHistory
    extends $AsyncNotifier<PackageActivationHistoryState> {
  FutureOr<PackageActivationHistoryState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PackageActivationHistoryState>,
        PackageActivationHistoryState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PackageActivationHistoryState>,
            PackageActivationHistoryState>,
        AsyncValue<PackageActivationHistoryState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

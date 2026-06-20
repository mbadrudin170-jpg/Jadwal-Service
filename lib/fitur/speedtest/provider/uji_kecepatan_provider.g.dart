// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uji_kecepatan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UjiKecepatan)
final ujiKecepatanProvider = UjiKecepatanProvider._();

final class UjiKecepatanProvider
    extends $NotifierProvider<UjiKecepatan, UjiKecepatanState> {
  UjiKecepatanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ujiKecepatanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ujiKecepatanHash();

  @$internal
  @override
  UjiKecepatan create() => UjiKecepatan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UjiKecepatanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UjiKecepatanState>(value),
    );
  }
}

String _$ujiKecepatanHash() => r'8b8816c635793187e2bfa5391198044bf9ce14f5';

abstract class _$UjiKecepatan extends $Notifier<UjiKecepatanState> {
  UjiKecepatanState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UjiKecepatanState, UjiKecepatanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UjiKecepatanState, UjiKecepatanState>,
              UjiKecepatanState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

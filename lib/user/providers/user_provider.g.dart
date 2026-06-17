// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppReadiness)
final appReadinessProvider = AppReadinessProvider._();

final class AppReadinessProvider extends $NotifierProvider<AppReadiness, bool> {
  AppReadinessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appReadinessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appReadinessHash();

  @$internal
  @override
  AppReadiness create() => AppReadiness();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appReadinessHash() => r'2a820cd94d224598a299c205dbe522440174d449';

abstract class _$AppReadiness extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(layananNotifikasi)
final layananNotifikasiProvider = LayananNotifikasiProvider._();

final class LayananNotifikasiProvider
    extends
        $FunctionalProvider<
          LayananNotifikasi,
          LayananNotifikasi,
          LayananNotifikasi
        >
    with $Provider<LayananNotifikasi> {
  LayananNotifikasiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layananNotifikasiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layananNotifikasiHash();

  @$internal
  @override
  $ProviderElement<LayananNotifikasi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LayananNotifikasi create(Ref ref) {
    return layananNotifikasi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayananNotifikasi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayananNotifikasi>(value),
    );
  }
}

String _$layananNotifikasiHash() => r'0488b6d7e1938bf8b5cb9a658a2634c4e9894c4f';

@ProviderFor(userId)
final userIdProvider = UserIdProvider._();

final class UserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  UserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return userId(ref);
  }
}

String _$userIdHash() => r'99159f4d22bbc50c367bcbb1bf5f8ce4a1958fad';

@ProviderFor(layananAktivitasUser)
final layananAktivitasUserProvider = LayananAktivitasUserProvider._();

final class LayananAktivitasUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<LayananAktivitasUser>,
          LayananAktivitasUser,
          FutureOr<LayananAktivitasUser>
        >
    with
        $FutureModifier<LayananAktivitasUser>,
        $FutureProvider<LayananAktivitasUser> {
  LayananAktivitasUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layananAktivitasUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layananAktivitasUserHash();

  @$internal
  @override
  $FutureProviderElement<LayananAktivitasUser> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LayananAktivitasUser> create(Ref ref) {
    return layananAktivitasUser(ref);
  }
}

String _$layananAktivitasUserHash() =>
    r'477083226beda5c128fa3b908af23aef036f99e0';

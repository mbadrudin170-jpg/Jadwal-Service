// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

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

@ProviderFor(notifikasiServis)
final notifikasiServisProvider = NotifikasiServisProvider._();

final class NotifikasiServisProvider
    extends
        $FunctionalProvider<
          LayananNotifikasi,
          LayananNotifikasi,
          LayananNotifikasi
        >
    with $Provider<LayananNotifikasi> {
  NotifikasiServisProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notifikasiServisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notifikasiServisHash();

  @$internal
  @override
  $ProviderElement<LayananNotifikasi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LayananNotifikasi create(Ref ref) {
    return notifikasiServis(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayananNotifikasi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayananNotifikasi>(value),
    );
  }
}

String _$notifikasiServisHash() => r'8ee9ef8aa539ede9bcf4c98a6d46d7b823066886';

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

@ProviderFor(userActivityService)
final userActivityServiceProvider = UserActivityServiceProvider._();

final class UserActivityServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserActivityService>,
          UserActivityService,
          FutureOr<UserActivityService>
        >
    with
        $FutureModifier<UserActivityService>,
        $FutureProvider<UserActivityService> {
  UserActivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userActivityServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userActivityServiceHash();

  @$internal
  @override
  $FutureProviderElement<UserActivityService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserActivityService> create(Ref ref) {
    return userActivityService(ref);
  }
}

String _$userActivityServiceHash() =>
    r'beeebd312a110d9ea13af5ffad86273caa048a21';

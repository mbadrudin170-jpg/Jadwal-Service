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
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(notifikasiServis)
final notifikasiServisProvider = NotifikasiServisProvider._();

final class NotifikasiServisProvider extends $FunctionalProvider<
    NotifikasiServis,
    NotifikasiServis,
    NotifikasiServis> with $Provider<NotifikasiServis> {
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
  $ProviderElement<NotifikasiServis> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotifikasiServis create(Ref ref) {
    return notifikasiServis(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotifikasiServis value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotifikasiServis>(value),
    );
  }
}

String _$notifikasiServisHash() => r'5ac9b5c81a21e80bd12e57882e0334c0ace4c5bc';

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

String _$userIdHash() => r'ac6d20a85f85b5e7032fc6aeccbb9bb3f7a89d5b';

@ProviderFor(userActivityService)
final userActivityServiceProvider = UserActivityServiceProvider._();

final class UserActivityServiceProvider extends $FunctionalProvider<
        AsyncValue<UserActivityService>,
        UserActivityService,
        FutureOr<UserActivityService>>
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
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserActivityService> create(Ref ref) {
    return userActivityService(ref);
  }
}

String _$userActivityServiceHash() =>
    r'7f5ad796551860f2e2cd3b41bfd77187555773d8';

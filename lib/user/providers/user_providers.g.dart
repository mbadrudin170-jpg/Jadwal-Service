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

/// Provider untuk mendapatkan ID pengguna yang sedang login dari SharedPreferences.

@ProviderFor(userId)
final userIdProvider = UserIdProvider._();

/// Provider untuk mendapatkan ID pengguna yang sedang login dari SharedPreferences.

final class UserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Provider untuk mendapatkan ID pengguna yang sedang login dari SharedPreferences.
  UserIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userIdProvider',
          isAutoDispose: true,
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

String _$userIdHash() => r'7f05f63cadaff802484e69701ed696b37d996efa';

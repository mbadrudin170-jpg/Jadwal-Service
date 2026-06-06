// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

@ProviderFor(localStorageService)
final localStorageServiceProvider = LocalStorageServiceProvider._();

final class LocalStorageServiceProvider extends $FunctionalProvider<
        AsyncValue<LocalStorageService>,
        LocalStorageService,
        FutureOr<LocalStorageService>>
    with
        $FutureModifier<LocalStorageService>,
        $FutureProvider<LocalStorageService> {
  LocalStorageServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localStorageServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localStorageServiceHash();

  @$internal
  @override
  $FutureProviderElement<LocalStorageService> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LocalStorageService> create(Ref ref) {
    return localStorageService(ref);
  }
}

String _$localStorageServiceHash() =>
    r'682f08594d407537f17f21974997a6a4de059ac8';

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
          isAutoDispose: false,
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

String _$notifikasiServisHash() => r'50f8527c09c44d5e6a2ffe769c02a165eca31c73';

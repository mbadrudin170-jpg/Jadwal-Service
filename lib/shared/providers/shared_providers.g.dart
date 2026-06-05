// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider untuk menyediakan instance SharedPreferences secara asynchronous.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider untuk menyediakan instance SharedPreferences secara asynchronous.

final class SharedPreferencesProvider extends $FunctionalProvider<
        AsyncValue<SharedPreferences>,
        SharedPreferences,
        FutureOr<SharedPreferences>>
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Provider untuk menyediakan instance SharedPreferences secara asynchronous.
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

/// DIUBAH: Provider diubah menjadi FutureProvider untuk menangani inisialisasi async.

@ProviderFor(localStorageService)
final localStorageServiceProvider = LocalStorageServiceProvider._();

/// DIUBAH: Provider diubah menjadi FutureProvider untuk menangani inisialisasi async.

final class LocalStorageServiceProvider extends $FunctionalProvider<
        AsyncValue<LocalStorageService>,
        LocalStorageService,
        FutureOr<LocalStorageService>>
    with
        $FutureModifier<LocalStorageService>,
        $FutureProvider<LocalStorageService> {
  /// DIUBAH: Provider diubah menjadi FutureProvider untuk menangani inisialisasi async.
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

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

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $AsyncNotifierProvider<ThemeNotifier, ThemeMode> {
  ThemeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();
}

String _$themeNotifierHash() => r'e78c21963b759cfba60a645f48133560d0899698';

abstract class _$ThemeNotifier extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
        AsyncValue<ThemeMode>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
/// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.

@ProviderFor(appRole)
final appRoleProvider = AppRoleProvider._();

/// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
/// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.

final class AppRoleProvider
    extends $FunctionalProvider<AppRole, AppRole, AppRole>
    with $Provider<AppRole> {
  /// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
  /// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.
  AppRoleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appRoleProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appRoleHash();

  @$internal
  @override
  $ProviderElement<AppRole> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppRole create(Ref ref) {
    return appRole(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppRole>(value),
    );
  }
}

String _$appRoleHash() => r'cb30ce59264980d6e8d623c1c86512db1c3caf35';

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
        AsyncValue<LayananPenyimpananLokal>,
        LayananPenyimpananLokal,
        FutureOr<LayananPenyimpananLokal>>
    with
        $FutureModifier<LayananPenyimpananLokal>,
        $FutureProvider<LayananPenyimpananLokal> {
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
  $FutureProviderElement<LayananPenyimpananLokal> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LayananPenyimpananLokal> create(Ref ref) {
    return localStorageService(ref);
  }
}

String _$localStorageServiceHash() =>
    r'6e698d7fd7eeb3f4ad55371b9475cdb188ed0d0a';

/// Provider sederhana yang hanya membuat instance NotifikasiServis.

@ProviderFor(notifikasiServis)
final notifikasiServisProvider = NotifikasiServisProvider._();

/// Provider sederhana yang hanya membuat instance NotifikasiServis.

final class NotifikasiServisProvider extends $FunctionalProvider<
    NotifikasiServis,
    NotifikasiServis,
    NotifikasiServis> with $Provider<NotifikasiServis> {
  /// Provider sederhana yang hanya membuat instance NotifikasiServis.
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

String _$notifikasiServisHash() => r'1a5abc571c94904cfc22a487d7725efdd85923a1';

/// Controller utama untuk notifikasi.
/// Tonton provider ini dari UI untuk menginisialisasi listener.

@ProviderFor(pengontrolNotifikasi)
final pengontrolNotifikasiProvider = PengontrolNotifikasiProvider._();

/// Controller utama untuk notifikasi.
/// Tonton provider ini dari UI untuk menginisialisasi listener.

final class PengontrolNotifikasiProvider
    extends $FunctionalProvider<void, void, void> with $Provider<void> {
  /// Controller utama untuk notifikasi.
  /// Tonton provider ini dari UI untuk menginisialisasi listener.
  PengontrolNotifikasiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pengontrolNotifikasiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pengontrolNotifikasiHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return pengontrolNotifikasi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pengontrolNotifikasiHash() =>
    r'291d09d3e67d210968a772595c4b46d2c55f64bc';

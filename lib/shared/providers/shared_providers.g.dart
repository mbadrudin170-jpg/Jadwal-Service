// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
/// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
/// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// Provider ini WAJIB di-override di root setiap aplikasi (main_user.dart/main_admin.dart).
  /// Ini digunakan untuk memberi tahu provider lain dalam konteks aplikasi mana mereka berjalan.
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
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

@ProviderFor(layananPenyimpananLokal)
final layananPenyimpananLokalProvider = LayananPenyimpananLokalProvider._();

final class LayananPenyimpananLokalProvider
    extends
        $FunctionalProvider<
          AsyncValue<LayananPenyimpananLokal>,
          LayananPenyimpananLokal,
          FutureOr<LayananPenyimpananLokal>
        >
    with
        $FutureModifier<LayananPenyimpananLokal>,
        $FutureProvider<LayananPenyimpananLokal> {
  LayananPenyimpananLokalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layananPenyimpananLokalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layananPenyimpananLokalHash();

  @$internal
  @override
  $FutureProviderElement<LayananPenyimpananLokal> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LayananPenyimpananLokal> create(Ref ref) {
    return layananPenyimpananLokal(ref);
  }
}

String _$layananPenyimpananLokalHash() =>
    r'a6896842e5554ff630479075eedbb2f81542ae5a';

/// Provider sederhana yang hanya membuat instance NotifikasiServis.

@ProviderFor(layananNotifikasi)
final layananNotifikasiProvider = LayananNotifikasiProvider._();

/// Provider sederhana yang hanya membuat instance NotifikasiServis.

final class LayananNotifikasiProvider
    extends
        $FunctionalProvider<
          LayananNotifikasi,
          LayananNotifikasi,
          LayananNotifikasi
        >
    with $Provider<LayananNotifikasi> {
  /// Provider sederhana yang hanya membuat instance NotifikasiServis.
  LayananNotifikasiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layananNotifikasiProvider',
        isAutoDispose: false,
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

String _$layananNotifikasiHash() => r'b1db6972d06b5d7f0ae64ffd3ab6b5dea2cdb459';

@ProviderFor(pengontrolNotifikasi)
final pengontrolNotifikasiProvider = PengontrolNotifikasiProvider._();

final class PengontrolNotifikasiProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
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
    r'fe0141bb5b26e3c4daf18499c674c1c4b59be7e5';

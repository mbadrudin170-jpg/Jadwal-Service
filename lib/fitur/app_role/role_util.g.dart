// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_util.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appRole)
final appRoleProvider = AppRoleProvider._();

final class AppRoleProvider
    extends $FunctionalProvider<AppRole, AppRole, AppRole>
    with $Provider<AppRole> {
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

String _$appRoleHash() => r'7e4e813dcfc110fb92bff87849efc675e9d34750';

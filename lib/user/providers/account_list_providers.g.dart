// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// DIUBAH: FutureProvider yang menunggu LocalStorageService siap sebelum memuat daftar akun.

@ProviderFor(accountList)
final accountListProvider = AccountListProvider._();

/// DIUBAH: FutureProvider yang menunggu LocalStorageService siap sebelum memuat daftar akun.

final class AccountListProvider extends $FunctionalProvider<
        AsyncValue<List<CustomerModel>>,
        List<CustomerModel>,
        FutureOr<List<CustomerModel>>>
    with
        $FutureModifier<List<CustomerModel>>,
        $FutureProvider<List<CustomerModel>> {
  /// DIUBAH: FutureProvider yang menunggu LocalStorageService siap sebelum memuat daftar akun.
  AccountListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountListHash();

  @$internal
  @override
  $FutureProviderElement<List<CustomerModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerModel>> create(Ref ref) {
    return accountList(ref);
  }
}

String _$accountListHash() => r'bd2eb351403f2bd12885e68ef68fbbec3668979f';

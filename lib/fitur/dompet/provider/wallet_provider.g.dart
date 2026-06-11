// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Wallet)
final walletProvider = WalletProvider._();

final class WalletProvider extends $AsyncNotifierProvider<Wallet, WalletState> {
  WalletProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'walletProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$walletHash();

  @$internal
  @override
  Wallet create() => Wallet();
}

String _$walletHash() => r'ba5ef76d13d52a0e9bd4fe742c23f7008d86027d';

abstract class _$Wallet extends $AsyncNotifier<WalletState> {
  FutureOr<WalletState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WalletState>, WalletState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<WalletState>, WalletState>,
        AsyncValue<WalletState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

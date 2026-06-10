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

String _$walletHash() => r'45a4b650c600db5fe5a7a6dac02439fd701551bd';

abstract class _$Wallet extends $AsyncNotifier<WalletState> {
  FutureOr<WalletState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WalletState>, WalletState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<WalletState>, WalletState>,
        AsyncValue<WalletState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

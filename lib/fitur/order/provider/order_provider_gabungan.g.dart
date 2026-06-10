// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider_gabungan.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listOrder)
final listOrderProvider = ListOrderProvider._();

final class ListOrderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  ListOrderProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'listOrderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$listOrderHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return listOrder(ref);
  }
}

String _$listOrderHash() => r'e360fa978edcb42e21f1e3590fe2512d6d449abd';

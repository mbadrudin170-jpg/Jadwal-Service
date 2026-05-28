// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
          isAutoDispose: true,
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

String _$notifikasiServisHash() => r'07b1a109342575b01eafced4d80f90b1bd0d1c00';

@ProviderFor(syncManager)
final syncManagerProvider = SyncManagerProvider._();

final class SyncManagerProvider
    extends $FunctionalProvider<SyncManager, SyncManager, SyncManager>
    with $Provider<SyncManager> {
  SyncManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncManagerHash();

  @$internal
  @override
  $ProviderElement<SyncManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncManager create(Ref ref) {
    return syncManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncManager>(value),
    );
  }
}

String _$syncManagerHash() => r'83ba6fdaaeeb223c0749a38de032a76b8486d877';

@ProviderFor(settingsOperation)
final settingsOperationProvider = SettingsOperationProvider._();

final class SettingsOperationProvider extends $FunctionalProvider<
    SettingsOperation,
    SettingsOperation,
    SettingsOperation> with $Provider<SettingsOperation> {
  SettingsOperationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsOperationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsOperationHash();

  @$internal
  @override
  $ProviderElement<SettingsOperation> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsOperation create(Ref ref) {
    return settingsOperation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsOperation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsOperation>(value),
    );
  }
}

String _$settingsOperationHash() => r'6139ef03e0c4347a2860881a356979e418253c90';

@ProviderFor(settings)
final settingsProvider = SettingsProvider._();

final class SettingsProvider extends $FunctionalProvider<
        AsyncValue<SettingsModel>, SettingsModel, FutureOr<SettingsModel>>
    with $FutureModifier<SettingsModel>, $FutureProvider<SettingsModel> {
  SettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  $FutureProviderElement<SettingsModel> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsModel> create(Ref ref) {
    return settings(ref);
  }
}

String _$settingsHash() => r'6e42f783db766c6ba1950a830f1d300004cc1471';

@ProviderFor(transactionOperation)
final transactionOperationProvider = TransactionOperationProvider._();

final class TransactionOperationProvider extends $FunctionalProvider<
    TransactionOperation,
    TransactionOperation,
    TransactionOperation> with $Provider<TransactionOperation> {
  TransactionOperationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionOperationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionOperationHash();

  @$internal
  @override
  $ProviderElement<TransactionOperation> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionOperation create(Ref ref) {
    return transactionOperation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionOperation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionOperation>(value),
    );
  }
}

String _$transactionOperationHash() =>
    r'3b81eeeb514447f24caa55a120b73a9b680da382';

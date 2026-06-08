// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_operation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider utama untuk menyediakan instance global dari [FirebaseFirestore].

@ProviderFor(firestore)
final firestoreProvider = FirestoreProvider._();

/// Provider utama untuk menyediakan instance global dari [FirebaseFirestore].

final class FirestoreProvider extends $FunctionalProvider<FirebaseFirestore,
    FirebaseFirestore, FirebaseFirestore> with $Provider<FirebaseFirestore> {
  /// Provider utama untuk menyediakan instance global dari [FirebaseFirestore].
  FirestoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firestoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'a56abe42f3fb3ee8bfee4e56b46a7bf8561bdc93';

/// Provider untuk menyediakan instance dari [StatusOpFirebase].

@ProviderFor(statusOpFirebase)
final statusOpFirebaseProvider = StatusOpFirebaseProvider._();

/// Provider untuk menyediakan instance dari [StatusOpFirebase].

final class StatusOpFirebaseProvider extends $FunctionalProvider<
    StatusOpFirebase,
    StatusOpFirebase,
    StatusOpFirebase> with $Provider<StatusOpFirebase> {
  /// Provider untuk menyediakan instance dari [StatusOpFirebase].
  StatusOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statusOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statusOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<StatusOpFirebase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatusOpFirebase create(Ref ref) {
    return statusOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatusOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatusOpFirebase>(value),
    );
  }
}

String _$statusOpFirebaseHash() => r'f62a8b947dbaf86b3ae3b9445d0c64757bf85f12';

/// Provider untuk menyediakan instance dari [BaseOpFirebase].

@ProviderFor(baseOpFirebase)
final baseOpFirebaseProvider = BaseOpFirebaseProvider._();

/// Provider untuk menyediakan instance dari [BaseOpFirebase].

final class BaseOpFirebaseProvider
    extends $FunctionalProvider<BaseOpFirebase, BaseOpFirebase, BaseOpFirebase>
    with $Provider<BaseOpFirebase> {
  /// Provider untuk menyediakan instance dari [BaseOpFirebase].
  BaseOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'baseOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$baseOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<BaseOpFirebase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BaseOpFirebase create(Ref ref) {
    return baseOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BaseOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BaseOpFirebase>(value),
    );
  }
}

String _$baseOpFirebaseHash() => r'a1e4d359b3e36266674737cc7d0a79a371480ee1';

/// Provider untuk menyediakan instance dari [ActiveCustomerOpFirebase].

@ProviderFor(activeCustomerOpFirebase)
final activeCustomerOpFirebaseProvider = ActiveCustomerOpFirebaseProvider._();

/// Provider untuk menyediakan instance dari [ActiveCustomerOpFirebase].

final class ActiveCustomerOpFirebaseProvider extends $FunctionalProvider<
    ActiveCustomerOpFirebase,
    ActiveCustomerOpFirebase,
    ActiveCustomerOpFirebase> with $Provider<ActiveCustomerOpFirebase> {
  /// Provider untuk menyediakan instance dari [ActiveCustomerOpFirebase].
  ActiveCustomerOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeCustomerOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeCustomerOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<ActiveCustomerOpFirebase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ActiveCustomerOpFirebase create(Ref ref) {
    return activeCustomerOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveCustomerOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveCustomerOpFirebase>(value),
    );
  }
}

String _$activeCustomerOpFirebaseHash() =>
    r'0c89da5e78bec7637eb99e3ada1bd1113bfa7e16';

@ProviderFor(feedbackOpFirebase)
final feedbackOpFirebaseProvider = FeedbackOpFirebaseProvider._();

final class FeedbackOpFirebaseProvider extends $FunctionalProvider<
    FeedbackOpFirebase,
    FeedbackOpFirebase,
    FeedbackOpFirebase> with $Provider<FeedbackOpFirebase> {
  FeedbackOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedbackOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedbackOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<FeedbackOpFirebase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedbackOpFirebase create(Ref ref) {
    return feedbackOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedbackOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedbackOpFirebase>(value),
    );
  }
}

String _$feedbackOpFirebaseHash() =>
    r'3c193febabd074229daf73794f7242e9c5eb7738';

@ProviderFor(feedbackStream)
final feedbackStreamProvider = FeedbackStreamFamily._();

final class FeedbackStreamProvider extends $FunctionalProvider<
        AsyncValue<List<FeedbackModel>>,
        List<FeedbackModel>,
        Stream<List<FeedbackModel>>>
    with
        $FutureModifier<List<FeedbackModel>>,
        $StreamProvider<List<FeedbackModel>> {
  FeedbackStreamProvider._(
      {required FeedbackStreamFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'feedbackStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedbackStreamHash();

  @override
  String toString() {
    return r'feedbackStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FeedbackModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<FeedbackModel>> create(Ref ref) {
    final argument = this.argument as String;
    return feedbackStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedbackStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedbackStreamHash() => r'37aa40ee5f44034dbf909d0c085d96cda07c7989';

final class FeedbackStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FeedbackModel>>, String> {
  FeedbackStreamFamily._()
      : super(
          retry: null,
          name: r'feedbackStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FeedbackStreamProvider call(
    String userId,
  ) =>
      FeedbackStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'feedbackStreamProvider';
}

@ProviderFor(customerOpFirebase)
final customerOpFirebaseProvider = CustomerOpFirebaseProvider._();

final class CustomerOpFirebaseProvider extends $FunctionalProvider<
    CustomerOpFirebase,
    CustomerOpFirebase,
    CustomerOpFirebase> with $Provider<CustomerOpFirebase> {
  CustomerOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'customerOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$customerOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<CustomerOpFirebase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CustomerOpFirebase create(Ref ref) {
    return customerOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerOpFirebase>(value),
    );
  }
}

String _$customerOpFirebaseHash() =>
    r'296a6bd7e00e9f018c13c4b561f1bc101c7b7689';

@ProviderFor(packageOpFirebase)
final packageOpFirebaseProvider = PackageOpFirebaseProvider._();

final class PackageOpFirebaseProvider extends $FunctionalProvider<
    PackageOpFirebase,
    PackageOpFirebase,
    PackageOpFirebase> with $Provider<PackageOpFirebase> {
  PackageOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'packageOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$packageOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<PackageOpFirebase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PackageOpFirebase create(Ref ref) {
    return packageOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PackageOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PackageOpFirebase>(value),
    );
  }
}

String _$packageOpFirebaseHash() => r'b35081ba0f083713c1f722aa3c3fd0d741f784ff';

@ProviderFor(transactionOpFirebase)
final transactionOpFirebaseProvider = TransactionOpFirebaseProvider._();

final class TransactionOpFirebaseProvider extends $FunctionalProvider<
    TransactionOpFirebase,
    TransactionOpFirebase,
    TransactionOpFirebase> with $Provider<TransactionOpFirebase> {
  TransactionOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'transactionOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$transactionOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<TransactionOpFirebase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionOpFirebase create(Ref ref) {
    return transactionOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionOpFirebase>(value),
    );
  }
}

String _$transactionOpFirebaseHash() =>
    r'3d7e4c75d1c790bfc69d8adae6084cc50af22687';

@ProviderFor(notifikasiOpFirebase)
final notifikasiOpFirebaseProvider = NotifikasiOpFirebaseProvider._();

final class NotifikasiOpFirebaseProvider extends $FunctionalProvider<
    NotifikasiOpFirebase,
    NotifikasiOpFirebase,
    NotifikasiOpFirebase> with $Provider<NotifikasiOpFirebase> {
  NotifikasiOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notifikasiOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notifikasiOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<NotifikasiOpFirebase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotifikasiOpFirebase create(Ref ref) {
    return notifikasiOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotifikasiOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotifikasiOpFirebase>(value),
    );
  }
}

String _$notifikasiOpFirebaseHash() =>
    r'489e388fa84e197606c8be3132176f01addc564c';

@ProviderFor(orderOpFirebase)
final orderOpFirebaseProvider = OrderOpFirebaseProvider._();

final class OrderOpFirebaseProvider extends $FunctionalProvider<OrderOpFirebase,
    OrderOpFirebase, OrderOpFirebase> with $Provider<OrderOpFirebase> {
  OrderOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orderOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<OrderOpFirebase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderOpFirebase create(Ref ref) {
    return orderOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderOpFirebase>(value),
    );
  }
}

String _$orderOpFirebaseHash() => r'91a84983dc0ee49d1317fca190b73daaf5369c6d';

@ProviderFor(iOrderOpFirebase)
final iOrderOpFirebaseProvider = IOrderOpFirebaseProvider._();

final class IOrderOpFirebaseProvider extends $FunctionalProvider<
    IOrderOperation,
    IOrderOperation,
    IOrderOperation> with $Provider<IOrderOperation> {
  IOrderOpFirebaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'iOrderOpFirebaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$iOrderOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<IOrderOperation> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IOrderOperation create(Ref ref) {
    return iOrderOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IOrderOperation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IOrderOperation>(value),
    );
  }
}

String _$iOrderOpFirebaseHash() => r'7e914986d462b63c9f0193b491fc630cfc0813da';

@ProviderFor(activeNotificationsStream)
final activeNotificationsStreamProvider = ActiveNotificationsStreamProvider._();

final class ActiveNotificationsStreamProvider extends $FunctionalProvider<
        AsyncValue<List<NotifikasiModel>>,
        List<NotifikasiModel>,
        Stream<List<NotifikasiModel>>>
    with
        $FutureModifier<List<NotifikasiModel>>,
        $StreamProvider<List<NotifikasiModel>> {
  ActiveNotificationsStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeNotificationsStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeNotificationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<NotifikasiModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<NotifikasiModel>> create(Ref ref) {
    return activeNotificationsStream(ref);
  }
}

String _$activeNotificationsStreamHash() =>
    r'1018648da844207c72b484206aade00561771760';

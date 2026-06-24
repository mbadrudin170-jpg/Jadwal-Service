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

final class FirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
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
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

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

final class StatusOpFirebaseProvider
    extends
        $FunctionalProvider<
          StatusOpFirebase,
          StatusOpFirebase,
          StatusOpFirebase
        >
    with $Provider<StatusOpFirebase> {
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

@ProviderFor(feedbackOpFirebase)
final feedbackOpFirebaseProvider = FeedbackOpFirebaseProvider._();

final class FeedbackOpFirebaseProvider
    extends
        $FunctionalProvider<
          FeedbackOpFirebase,
          FeedbackOpFirebase,
          FeedbackOpFirebase
        >
    with $Provider<FeedbackOpFirebase> {
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
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

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
    r'aa7c6b16b01795839bb8c201262975d321216b4b';

@ProviderFor(feedbackStream)
final feedbackStreamProvider = FeedbackStreamFamily._();

final class FeedbackStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedbackModel>>,
          List<FeedbackModel>,
          Stream<List<FeedbackModel>>
        >
    with
        $FutureModifier<List<FeedbackModel>>,
        $StreamProvider<List<FeedbackModel>> {
  FeedbackStreamProvider._({
    required FeedbackStreamFamily super.from,
    required String super.argument,
  }) : super(
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
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedbackModel>> create(Ref ref) {
    final argument = this.argument as String;
    return feedbackStream(ref, argument);
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

String _$feedbackStreamHash() => r'884555dea084c9141158cb14b5c2489604da030d';

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

  FeedbackStreamProvider call(String userId) =>
      FeedbackStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'feedbackStreamProvider';
}

@ProviderFor(pelangganOpFirebase)
final pelangganOpFirebaseProvider = PelangganOpFirebaseProvider._();

final class PelangganOpFirebaseProvider
    extends
        $FunctionalProvider<
          PelangganOpFirebase,
          PelangganOpFirebase,
          PelangganOpFirebase
        >
    with $Provider<PelangganOpFirebase> {
  PelangganOpFirebaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganOpFirebaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<PelangganOpFirebase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PelangganOpFirebase create(Ref ref) {
    return pelangganOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PelangganOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PelangganOpFirebase>(value),
    );
  }
}

String _$pelangganOpFirebaseHash() =>
    r'85c60ee6a0d443fa221156a31754b591a709f822';

@ProviderFor(pelangganAktifOpFirebase)
final pelangganAktifOpFirebaseProvider = PelangganAktifOpFirebaseProvider._();

final class PelangganAktifOpFirebaseProvider
    extends
        $FunctionalProvider<
          PelangganAktifOpFirebase,
          PelangganAktifOpFirebase,
          PelangganAktifOpFirebase
        >
    with $Provider<PelangganAktifOpFirebase> {
  PelangganAktifOpFirebaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pelangganAktifOpFirebaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pelangganAktifOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<PelangganAktifOpFirebase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PelangganAktifOpFirebase create(Ref ref) {
    return pelangganAktifOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PelangganAktifOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PelangganAktifOpFirebase>(value),
    );
  }
}

String _$pelangganAktifOpFirebaseHash() =>
    r'86bff10a5b137827d31472c15005cba1c9cb6ca2';

@ProviderFor(paketOpFirebase)
final paketOpFirebaseProvider = PaketOpFirebaseProvider._();

final class PaketOpFirebaseProvider
    extends
        $FunctionalProvider<PaketOpFirebase, PaketOpFirebase, PaketOpFirebase>
    with $Provider<PaketOpFirebase> {
  PaketOpFirebaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paketOpFirebaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paketOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<PaketOpFirebase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaketOpFirebase create(Ref ref) {
    return paketOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaketOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaketOpFirebase>(value),
    );
  }
}

String _$paketOpFirebaseHash() => r'9b5525426ad36fd4aeadb5cabf7d8ecae7ba79ec';

@ProviderFor(transaksiOpFirebase)
final transaksiOpFirebaseProvider = TransaksiOpFirebaseProvider._();

final class TransaksiOpFirebaseProvider
    extends
        $FunctionalProvider<
          TransaksiOpFirebase,
          TransaksiOpFirebase,
          TransaksiOpFirebase
        >
    with $Provider<TransaksiOpFirebase> {
  TransaksiOpFirebaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transaksiOpFirebaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transaksiOpFirebaseHash();

  @$internal
  @override
  $ProviderElement<TransaksiOpFirebase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransaksiOpFirebase create(Ref ref) {
    return transaksiOpFirebase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransaksiOpFirebase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransaksiOpFirebase>(value),
    );
  }
}

String _$transaksiOpFirebaseHash() =>
    r'bce671d9358df9ca188be9caefd70efc6911af5c';

@ProviderFor(notifikasiOpFirebase)
final notifikasiOpFirebaseProvider = NotifikasiOpFirebaseProvider._();

final class NotifikasiOpFirebaseProvider
    extends
        $FunctionalProvider<
          NotifikasiOpFirebase,
          NotifikasiOpFirebase,
          NotifikasiOpFirebase
        >
    with $Provider<NotifikasiOpFirebase> {
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
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

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

final class OrderOpFirebaseProvider
    extends
        $FunctionalProvider<OrderOpFirebase, OrderOpFirebase, OrderOpFirebase>
    with $Provider<OrderOpFirebase> {
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

@ProviderFor(activeNotificationsStream)
final activeNotificationsStreamProvider = ActiveNotificationsStreamProvider._();

final class ActiveNotificationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotifikasiModel>>,
          List<NotifikasiModel>,
          Stream<List<NotifikasiModel>>
        >
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
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NotifikasiModel>> create(Ref ref) {
    return activeNotificationsStream(ref);
  }
}

String _$activeNotificationsStreamHash() =>
    r'4e4561520c50e9b2e39a656e772df96e1d145bc8';

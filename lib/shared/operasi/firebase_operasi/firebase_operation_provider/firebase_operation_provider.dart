// path: lib/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/active_customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';

part 'firebase_operation_provider.g.dart';

/// Provider utama untuk menyediakan instance global dari [FirebaseFirestore].
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provider untuk menyediakan instance dari [StatusOpFirebase].
@Riverpod(keepAlive: true)
StatusOpFirebase statusOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  return StatusOpFirebase(firestore: firestoreInstance);
}

/// Provider untuk menyediakan instance dari [BaseOpFirebase].
@Riverpod(keepAlive: true)
BaseOpFirebase baseOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  final statusOpInstance = ref.watch(statusOpFirebaseProvider);

  return BaseOpFirebase(
    firestore: firestoreInstance,
    statusOp: statusOpInstance,
  );
}

/// Provider untuk menyediakan instance dari [ActiveCustomerOpFirebase].
@Riverpod(keepAlive: true)
ActiveCustomerOpFirebase activeCustomerOpFirebase(Ref ref) {
  Log.info('Membuat instance ActiveCustomerOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  return ActiveCustomerOpFirebase(firestore: firestoreInstance);
}

@Riverpod(keepAlive: true)
FeedbackOpFirebase feedbackOpFirebase(Ref ref) {
  Log.info('Membuat instance FeedbackOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return FeedbackOpFirebase(
    firestore: firestoreInstance,
    baseOp: baseOp,
  );
}

@riverpod
Stream<List<FeedbackModel>> feedbackStream(Ref ref, String userId) {
  final feedbackOp = ref.watch(feedbackOpFirebaseProvider);
  return feedbackOp.getByUser(userId);
}

@Riverpod(keepAlive: true)
CustomerOpFirebase customerOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);

  return CustomerOpFirebase(
    firestore: firestoreInstance,
    baseOp: baseOp,
  );
}

@Riverpod(keepAlive: true)
PackageOpFirebase packageOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);

  return PackageOpFirebase(
    firestore: firestoreInstance,
  );
}

@Riverpod(keepAlive: true)
TransactionOpFirebase transactionOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  return TransactionOpFirebase(
    firestore: firestoreInstance,
  );
}

@Riverpod(keepAlive: true)
NotifikasiOpFirebase notifikasiOpFirebase(Ref ref) {
  Log.info('Membuat instance NotifikasiOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return NotifikasiOpFirebase(
    firestore: firestoreInstance,
    baseOp: baseOp,
  );
}

@Riverpod(keepAlive: true)
OrderOpFirebase orderOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return OrderOpFirebase(
    firestore: firestoreInstance,
    baseOp: baseOp,
  );
}

@riverpod
Stream<List<NotifikasiModel>> activeNotificationsStream(Ref ref) {
  final notifikasiOp = ref.read(notifikasiOpFirebaseProvider);
  return notifikasiOp.getActiveNotifications();
}

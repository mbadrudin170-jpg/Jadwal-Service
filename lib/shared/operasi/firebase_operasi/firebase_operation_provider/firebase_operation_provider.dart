// path: lib/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/active_customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

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

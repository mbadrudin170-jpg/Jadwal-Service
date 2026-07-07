// path: lib/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_firebase.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_firebase.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_firebase.dart';
import 'package:wifi/fitur/notifikasi/operasi/notifikasi_op_firebase.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_firebase.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';
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

@Riverpod(keepAlive: true)
FeedbackOpFirebase feedbackOpFirebase(Ref ref) {
  Log.info('Membuat instance FeedbackOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return FeedbackOpFirebase(
    firestore: firestoreInstance,
    baseOpFirebase: baseOp,
  );
}

@Riverpod(keepAlive: true)
PelangganOpFirebase pelangganOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);

  return PelangganOpFirebase(
    firestore: firestoreInstance,
    baseOpFirebase: baseOp,
  );
}

@Riverpod(keepAlive: true)
PelangganAktifOpFirebase pelangganAktifOpFirebase(Ref ref) {
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return PelangganAktifOpFirebase(baseOp: baseOp);
}

@Riverpod(keepAlive: true)
PaketOpFirebase paketOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return PaketOpFirebase(firestore: firestoreInstance, baseOp: baseOp);
}

@Riverpod(keepAlive: true)
TransaksiOpFirebase transaksiOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  return TransaksiOpFirebase(firestore: firestoreInstance);
}

@Riverpod(keepAlive: true)
NotifikasiOpFirebase notifikasiOpFirebase(Ref ref) {
  Log.info('Membuat instance NotifikasiOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return NotifikasiOpFirebase(firestore: firestoreInstance, baseOp: baseOp);
}

@Riverpod(keepAlive: true)
OrderOpFirebase orderOpFirebase(Ref ref) {
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return OrderOpFirebase(firestore: firestoreInstance, baseOp: baseOp);
}
// ============================================================
// TAMBAHKAN DI BAGIAN BAWAH FILE, SETELAH PROVIDER LAINNYA
// ============================================================

/// Provider untuk menyediakan instance dari [InvestasiOpFirebase].
@Riverpod(keepAlive: true)
InvestasiOpFirebase investasiOpFirebase(Ref ref) {
  Log.info('Membuat instance InvestasiOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return InvestasiOpFirebase(
    firestore: firestoreInstance,
    baseOpFirebase: baseOp,
  );
}

/// Provider untuk menyediakan instance dari [DompetOpFirebase].
@Riverpod(keepAlive: true)
DompetOpFirebase dompetOpFirebase(Ref ref) {
  Log.info('Membuat instance DompetOpFirebase via @riverpod...');
  final firestoreInstance = ref.watch(firestoreProvider);
  final baseOp = ref.watch(baseOpFirebaseProvider);
  return DompetOpFirebase(
    firestore: firestoreInstance,
    baseOpFirebase: baseOp,
  );
}
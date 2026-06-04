// path: test/shared/operasi/firebase_operasi/status_op_firebase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wifi/shared/model/status_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late StatusOpFirebase statusOp;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    statusOp = StatusOpFirebase(firestore: fakeFirestore);
  });

  group('StatusOpFirebase Tests', () {
    test('1. updateGlobalStatus - seharusnya membuat atau memperbarui status global', () async {
      await statusOp.updateGlobalStatus();

      final doc = await fakeFirestore.collection('status_global').doc(globalStatusId).get();

      expect(doc.exists, isTrue);
      expect(doc.data()?.containsKey('updatedAt'), isTrue);
    });
  });
}

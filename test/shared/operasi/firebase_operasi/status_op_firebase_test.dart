// path: test/shared/operasi/firebase_operasi/status_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/model/status_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

void main() {
  group('StatusOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late StatusOpFirebase statusOpFirebase;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      statusOpFirebase = StatusOpFirebase(firestore: fakeFirestore);
    });

    test('01. harus memperbarui status global dengan benar', () async {
      await statusOpFirebase.perbaruiStatusGlobal();

      final doc = await fakeFirestore
          .collection(NamaTabel.statusGlobal)
          .doc(globalStatusId)
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data(), isNotNull);
      // Di FakeFirebaseFirestore, FieldValue.serverTimestamp() akan menghasilkan null
      // Jadi kita hanya perlu memastikan document-nya ada.
      // Untuk pengetesan lebih lanjut, perlu mock FieldValue.serverTimestamp()
    });
  });
}

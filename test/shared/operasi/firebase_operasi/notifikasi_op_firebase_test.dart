// path: test/shared/operasi/firebase_operasi/notifikasi_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';

void main() {
  group('NotifikasiOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late NotifikasiOpFirebase notifikasiOpFirebase;
    const userId = 'testUser';
    const token = 'test_token';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      notifikasiOpFirebase = NotifikasiOpFirebase(firestore: fakeFirestore);
    });

    test('simpanToken harus menyimpan token pengguna', () async {
      // Act
      await notifikasiOpFirebase.simpanToken(userId, token);

      // Assert
      final doc = await fakeFirestore.collection('fcm_tokens').doc(userId).get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['token'], token);
      expect(doc.data()?['diperbaruiPada'], isNotNull);
    });

    test('hapusToken harus menghapus token pengguna', () async {
      // Arrange
      await fakeFirestore.collection('fcm_tokens').doc(userId).set({
        'token': token,
        'diperbaruiPada': DateTime.now(),
      });

      // Act
      await notifikasiOpFirebase.hapusToken(userId);

      // Assert
      final doc = await fakeFirestore.collection('fcm_tokens').doc(userId).get();
      expect(doc.exists, isFalse);
    });
  });
}

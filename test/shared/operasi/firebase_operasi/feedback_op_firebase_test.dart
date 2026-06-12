// path: test/shared/operasi/firebase_operasi/feedback_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_firebase.dart';

void main() {
  // Gunakan fake_cloud_firestore untuk tes yang andal tanpa mock channel
  late FakeFirebaseFirestore fakeFirestore;
  late FeedbackOpFirebase feedbackOp;
  final collectionName = NamaTabel.get(TableName.feedback);

  setUp(() {
    // 1. Buat instance Firestore palsu untuk setiap tes
    fakeFirestore = FakeFirebaseFirestore();

    // 2. Suntikkan (inject) instance palsu ke dalam kelas operasi
    // Kita tidak perlu lagi mockito untuk BaseOpFirebase
    final baseOp = BaseOpFirebase(firestore: fakeFirestore);
    feedbackOp = FeedbackOpFirebase(firestore: fakeFirestore, baseOp: baseOp);
  });

  group('Tes Integrasi FeedbackOpFirebase dengan FakeFirestore', () {
    test(
        'create() harus menambahkan dokumen baru ke koleksi feedback dengan data yang benar',
        () async {
      // Arrange
      final feedback = FeedbackModel(
          content: 'Ini adalah feedback pertama.',
          userId: 'user123',
          updatedAt: DateTime.now().toUtc());

      // Act
      await feedbackOp.create(feedback);

      // Assert
      // Verifikasi langsung ke database palsu
      final snapshot = await fakeFirestore.collection(collectionName).get();
      expect(snapshot.docs.length, 1, reason: 'Harus ada 1 dokumen di koleksi');

      final doc = snapshot.docs.first;
      expect(doc.data()[NamaKolom.content], 'Ini adalah feedback pertama.');
      expect(doc.data()[NamaKolom.userId], 'user123');
      // FakeFirestore secara otomatis menangani FieldValue.serverTimestamp()
      // dengan mengisi waktu saat ini, jadi kita hanya perlu memastikan itu tidak null.
      expect(doc.data()[NamaKolom.date], isNotNull);
      expect(doc.data()[NamaKolom.updatedAt], isNotNull);
    });

    test('update() harus memperbarui konten dokumen yang ada', () async {
      // Arrange - Buat dokumen awal
      final docRef = await fakeFirestore.collection(collectionName).add({
        NamaKolom.content: 'Konten lama',
        NamaKolom.userId: 'user456',
        NamaKolom.date: DateTime(2023),
      });

      const newContent = 'Konten telah diperbarui.';

      // Act
      await feedbackOp.update(docRef.id, newContent);

      // Assert
      final updatedDoc =
          await fakeFirestore.collection(collectionName).doc(docRef.id).get();
      expect(updatedDoc.exists, isTrue);
      expect(updatedDoc.data()?[NamaKolom.content], newContent);
      // Pastikan field lain tidak berubah
      expect(updatedDoc.data()?[NamaKolom.userId], 'user456');
      expect(updatedDoc.data()?[NamaKolom.updatedAt], isNotNull);
    });

    test('delete() harus menghapus dokumen secara permanen', () async {
      // Arrange
      final docRef = await fakeFirestore
          .collection(collectionName)
          .add({'content': 'Akan dihapus'});
      expect((await docRef.get()).exists, isTrue,
          reason: 'Dokumen harus ada sebelum dihapus');

      // Act
      await feedbackOp.delete(docRef.id);

      // Assert
      final docAfterDelete =
          await fakeFirestore.collection(collectionName).doc(docRef.id).get();
      expect(docAfterDelete.exists, isFalse,
          reason: 'Dokumen seharusnya sudah tidak ada setelah delete');
    });

    test('softDeleteFeedback() harus mengatur isDeleted menjadi true',
        () async {
      // Arrange
      final docRef = await fakeFirestore.collection(collectionName).add({
        NamaKolom.content: 'Akan di-soft-delete',
        NamaKolom.isDeleted: false,
      });

      // Act
      await feedbackOp.softDeleteFeedback(docRef.id);

      // Assert
      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()?[NamaKolom.isDeleted], isTrue);
      expect(updatedDoc.data()?[NamaKolom.archivedAt], isNotNull);
    });
  });
}

// path: test/fitur/feedback/operasi/feedback_op_firebase_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

import 'feedback_op_firebase_test.mocks.dart';

// Firestore yang rusak untuk simulasi error
class BrokenFirebaseFirestore extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String name) {
    if (name == NamaTabel.feedback) {
      throw Exception('Gagal mengakses koleksi');
    }
    return super.collection(name);
  }
}

@GenerateMocks([BaseOpFirebase])
void main() {
  late FeedbackOpFirebase feedbackOpFirebase;
  late MockBaseOpFirebase mockBaseOp;
  late FirebaseFirestore fakeFirestore;
  late DocumentReference<Map<String, dynamic>> fakeDocRef;

  // Data sampel
  final feedback = FeedbackModel(
    id: 'feedback1',
    pesan: 'Ini adalah feedback',
    userId: 'user1',
    tanggal: DateTime.now(),
  );

  setUp(() {
    mockBaseOp = MockBaseOpFirebase();
    fakeFirestore = FakeFirebaseFirestore();
    fakeDocRef = fakeFirestore.collection(NamaTabel.feedback).doc('fake_id');
    feedbackOpFirebase = FeedbackOpFirebase(
      firestore: fakeFirestore,
      baseOpFirebase: mockBaseOp,
    );
  });

  group('FeedbackOpFirebase', () {
    test('01. create - harus mendelegasikan ke baseOp.tambah', () async {
      // Arrange
      when(mockBaseOp.tambah(
        NamaTabel.feedback,
        any,
      )).thenAnswer((_) async => fakeDocRef);

      // Act
      await feedbackOpFirebase.tambahFeedback(feedback);

      // Assert
      verify(mockBaseOp.tambah(
        NamaTabel.feedback,
        any,
      )).called(1);
    });

    test('02. update - harus mendelegasikan ke baseOp.update', () async {
      // Arrange
      when(mockBaseOp.update(
        NamaTabel.feedback,
        'feedback1',
        {NamaKolom.pesan: 'Pesan baru'},
      )).thenAnswer((_) async => Future.value());

      const docId = 'feedback1';
      const newContent = 'Pesan baru';

      // Act
      await feedbackOpFirebase.perbaruiFeedback(docId, newContent);

      // Assert
      verify(mockBaseOp.update(
        NamaTabel.feedback,
        docId,
        {NamaKolom.pesan: newContent},
      )).called(1);
    });

    test('03. delete - harus mendelegasikan ke baseOp.hapusPermanen', () async {
      // Arrange
      when(mockBaseOp.hapusPermanen(
        NamaTabel.feedback,
        'feedback1',
      )).thenAnswer((_) async => Future.value());

      const docId = 'feedback1';

      // Act
      await feedbackOpFirebase.delete(docId);

      // Assert
      verify(mockBaseOp.hapusPermanen(
        NamaTabel.feedback,
        docId,
      )).called(1);
    });

    test(
        '04. softDeleteFeedback - harus mendelegasikan ke baseOp.hapusSementara',
        () async {
      // Arrange
      when(mockBaseOp.hapusSementara(
        NamaTabel.feedback,
        'feedback1',
      )).thenAnswer((_) async => Future.value());

      const docId = 'feedback1';

      // Act
      await feedbackOpFirebase.softDeleteFeedback(docId);

      // Assert
      verify(mockBaseOp.hapusSementara(
        NamaTabel.feedback,
        docId,
      )).called(1);
    });

    group('getByUser', () {
      final tgl1 = DateTime(2023, 1, 1);
      final tgl2 = DateTime(2023, 1, 2);

      final feedback1 = FeedbackModel(
          id: 'fb1',
          pesan: 'Feedback 1',
          userId: 'user1',
          tanggal: tgl1,
          dihapus: false);
      final feedback2 = FeedbackModel(
          id: 'fb2',
          pesan: 'Feedback 2',
          userId: 'user1',
          tanggal: tgl2,
          dihapus: false);
      final feedbackDihapus = FeedbackModel(
          id: 'fb3',
          pesan: 'Feedback 3',
          userId: 'user1',
          tanggal: tgl1,
          dihapus: true);
      final feedbackUserLain = FeedbackModel(
          id: 'fb4',
          pesan: 'Feedback 4',
          userId: 'user2',
          tanggal: tgl1,
          dihapus: false);

      test(
          '05. harus mengembalikan stream berisi daftar feedback yang benar untuk pengguna',
          () async {
        // Arrange
        await fakeFirestore
            .collection(NamaTabel.feedback)
            .doc(feedback1.id)
            .set(feedback1.toFirebase());
        await fakeFirestore
            .collection(NamaTabel.feedback)
            .doc(feedback2.id)
            .set(feedback2.toFirebase());
        await fakeFirestore
            .collection(NamaTabel.feedback)
            .doc(feedbackDihapus.id)
            .set(feedbackDihapus.toFirebase());
        await fakeFirestore
            .collection(NamaTabel.feedback)
            .doc(feedbackUserLain.id)
            .set(feedbackUserLain.toFirebase());

        // Act
        final stream = feedbackOpFirebase.ambilBerdasarkanUser('user1');

        // Assert
        expect(
            stream,
            emits(isA<List<FeedbackModel>>()
                .having((list) => list.length, 'panjang daftar', 2)
                // Feedback 2 harus pertama karena tanggalnya lebih baru
                .having((list) => list[0].id, 'id item pertama', feedback2.id)
                .having((list) => list[1].id, 'id item kedua', feedback1.id)));
      });

      test('06. harus mengembalikan stream kosong jika tidak ada data',
          () async {
        // Arrange
        // Tidak ada data yang ditambahkan ke fakeFirestore

        // Act
        final stream = feedbackOpFirebase.ambilBerdasarkanUser('user-kosong');

        // Assert
        expect(stream, emits([]));
      });

      test('07. harus menangani error dari stream firestore', () async {
        // Arrange
        feedbackOpFirebase = FeedbackOpFirebase(
          firestore: BrokenFirebaseFirestore(),
          baseOpFirebase: mockBaseOp,
        );

        // Act
        final stream = feedbackOpFirebase.ambilBerdasarkanUser('user1');

        // Assert
        expect(stream, emitsError(isA<Exception>()));
      });
    });
  });
}

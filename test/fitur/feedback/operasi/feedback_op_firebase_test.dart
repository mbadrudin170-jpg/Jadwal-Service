// path: test/fitur/feedback/operasi/feedback_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockBaseOpFirebase extends Mock implements BaseOpFirebase {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockBaseOpFirebase mockBaseOp;
  late FeedbackOpFirebase feedbackOpFirebase;
  late MockCollectionReference mockCollectionReference;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockBaseOp = MockBaseOpFirebase();
    mockCollectionReference = MockCollectionReference();

    when(() => mockFirestore.collection(NamaTabel.feedback))
        .thenReturn(mockCollectionReference);

    feedbackOpFirebase =
        FeedbackOpFirebase(firestore: mockFirestore, baseOp: mockBaseOp);
  });

  group('FeedbackOpFirebase', () {
    final feedback = FeedbackModel(pesan: 'Test content', userId: 'user1');
    const docId = 'feedback1';

    test('01. harus mendelegasikan pembuatan feedback ke BaseOpFirebase',
        () async {
      final data = feedback.toFirebase();
      data[NamaKolom.tanggal] = FieldValue.serverTimestamp();

      when(() => mockBaseOp.tambah(NamaTabel.feedback, any()))
          .thenAnswer((_) async => MockDocumentReference());

      await feedbackOpFirebase.create(feedback);

      verify(() => mockBaseOp.tambah(
              NamaTabel.feedback, any(that: isA<Map<String, dynamic>>())))
          .called(1);
    });

    test('02. harus mendelegasikan pembaruan feedback ke BaseOpFirebase',
        () async {
      const newContent = 'Updated content';
      when(() => mockBaseOp.update(NamaTabel.feedback, docId, any()))
          .thenAnswer((_) async {});

      await feedbackOpFirebase.update(docId, newContent);

      verify(() => mockBaseOp.update(
          NamaTabel.feedback, docId, {NamaKolom.pesan: newContent})).called(1);
    });

    test('03. harus mendelegasikan penghapusan permanen ke BaseOpFirebase',
        () async {
      when(() => mockBaseOp.hapusPermanen(NamaTabel.feedback, docId))
          .thenAnswer((_) async {});

      await feedbackOpFirebase.delete(docId);

      verify(() => mockBaseOp.hapusPermanen(NamaTabel.feedback, docId))
          .called(1);
    });

    test('04. harus mendelegasikan soft delete ke BaseOpFirebase', () async {
      when(() => mockBaseOp.hapusSementara(NamaTabel.feedback, docId))
          .thenAnswer((_) async {});

      await feedbackOpFirebase.softDeleteFeedback(docId);

      verify(() => mockBaseOp.hapusSementara(NamaTabel.feedback, docId))
          .called(1);
    });

    group('getByUser', () {
      const userId = 'user1';
      final now = DateTime.now();
      final feedbackData = {
        'id': 'fb1',
        'content': 'Feedback 1',
        'userId': userId,
        'date': Timestamp.fromDate(now),
        'isDeleted': false,
        'updatedAt': Timestamp.fromDate(now),
      };

      test('05. harus mengembalikan stream list FeedbackModel saat data ada',
          () {
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDocSnapshot = MockQueryDocumentSnapshot();

        when(() => mockCollectionReference
            .where(NamaKolom.userId, isEqualTo: userId)
            .where(NamaKolom.diHapus, isEqualTo: false)
            .orderBy(NamaKolom.tanggal, descending: true)
            .snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));

        when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
        when(() => mockDocSnapshot.id).thenReturn('fb1');
        when(() => mockDocSnapshot.data()).thenReturn(feedbackData);

        final stream = feedbackOpFirebase.getByUser(userId);

        expect(
            stream,
            emits(isA<List<FeedbackModel>>()
              ..having((list) => list.first.id, 'ID sama', 'fb1')));
      });

      test('06. harus mengembalikan stream kosong saat tidak ada data', () {
        final mockQuerySnapshot = MockQuerySnapshot();

        when(() => mockCollectionReference
            .where(NamaKolom.userId, isEqualTo: userId)
            .where(NamaKolom.diHapus, isEqualTo: false)
            .orderBy(NamaKolom.tanggal, descending: true)
            .snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));

        when(() => mockQuerySnapshot.docs).thenReturn([]);

        final stream = feedbackOpFirebase.getByUser(userId);

        expect(stream, emits(isEmpty));
      });

      test('07. harus menangani error pada stream', () {
        final error = Exception('Firestore error');

        when(() => mockCollectionReference
            .where(NamaKolom.userId, isEqualTo: userId)
            .where(NamaKolom.diHapus, isEqualTo: false)
            .orderBy(NamaKolom.tanggal, descending: true)
            .snapshots()).thenAnswer((_) => Stream.error(error));

        final stream = feedbackOpFirebase.getByUser(userId);

        expect(stream, emitsError(error));
      });
    });
  });
}

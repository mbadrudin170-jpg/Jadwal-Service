// path: test/fitur/feedback/operasi/feedback_op_firebase_test.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

import 'feedback_op_firebase_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  BaseOpFirebase,
  CollectionReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentReference,
])
void main() {
  late FeedbackOpFirebase feedbackOpFirebase;
  late MockFirebaseFirestore mockFirestore;
  late MockBaseOpFirebase mockBaseOpFirebase;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockBaseOpFirebase = MockBaseOpFirebase();
    mockCollectionReference = MockCollectionReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();

    feedbackOpFirebase = FeedbackOpFirebase(
      firestore: mockFirestore,
      baseOpFirebase: mockBaseOpFirebase,
    );

    when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
    when(
      mockCollectionReference.where(any, isEqualTo: anyNamed('isEqualTo')),
    ).thenReturn(mockQuery);
    when(
      mockQuery.where(any, isEqualTo: anyNamed('isEqualTo')),
    ).thenReturn(mockQuery);
    when(
      mockQuery.orderBy(any, descending: anyNamed('descending')),
    ).thenReturn(mockQuery);
    when(
      mockQuery.snapshots(),
    ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
  });

  final feedbackModel = FeedbackModel(
    id: '1',
    pesan: 'This is a feedback',
    userId: 'user123',
    tanggal: DateTime.now(),
  );

  group('FeedbackOpFirebase', () {
    test('01. tambahFeedback harus memanggil _baseOpFirebase.tambah', () async {
      // Arrange
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(
        mockBaseOpFirebase.tambah(any, any),
      ).thenAnswer((_) async => mockDocRef);

      // Act
      await feedbackOpFirebase.tambah(feedbackModel);

      // Assert
      verify(mockBaseOpFirebase.tambah(any, any)).called(1);
    });

    test(
      '02. perbaruiFeedback harus memanggil _baseOpFirebase.update',
      () async {
        // Arrange
        const docId = 'feedback1';
        const newContent = 'Updated feedback';
        when(
          mockBaseOpFirebase.update(any, any, any),
        ).thenAnswer((_) async => Future.value());

        // Act
        await feedbackOpFirebase.perbarui(docId, newContent);

        // Assert
        verify(
          mockBaseOpFirebase.update(any, docId, {NamaKolom.pesan: newContent}),
        ).called(1);
      },
    );

    test('03. delete harus memanggil _baseOpFirebase.hapusPermanen', () async {
      // Arrange
      const docId = 'feedback1';
      when(
        mockBaseOpFirebase.hapusPermanen(any, any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await feedbackOpFirebase.delete(docId);

      // Assert
      verify(mockBaseOpFirebase.hapusPermanen(any, docId)).called(1);
    });

    test(
      '04. softDeleteFeedback harus memanggil _baseOpFirebase.hapusSementara',
      () async {
        // Arrange
        const docId = 'feedback1';
        when(
          mockBaseOpFirebase.softDelete(any, any),
        ).thenAnswer((_) async => Future.value());

        // Act
        await feedbackOpFirebase.softDelete(docId);

        // Assert
        verify(mockBaseOpFirebase.softDelete(any, docId)).called(1);
      },
    );

    test(
      '05. ambilBerdasarkanUser harus mengembalikan stream list feedback',
      () {
        // Arrange
        const userId = 'user123';
        final mockDocSnapshot =
            MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
        when(mockDocSnapshot.id).thenReturn('feedback1');
        when(mockDocSnapshot.data()).thenReturn(feedbackModel.toFirebase());

        // Act
        final stream = feedbackOpFirebase.ambilBerdasarkanUser(userId);

        // Assert
        expect(stream, isA<Stream<List<FeedbackModel>>>());
        stream.listen(
          expectAsync1((list) {
            expect(list.length, 1);
            expect(list.first.id, 'feedback1');
            expect(list.first.userId, userId);
          }),
        );
      },
    );

    test('06. ambilBerdasarkanUser harus menangani error', () {
      // Arrange
      const userId = 'user123';
      final error = Exception('Firestore error');
      when(mockQuery.snapshots()).thenAnswer((_) => Stream.error(error));

      // Act
      final stream = feedbackOpFirebase.ambilBerdasarkanUser(userId);

      // Assert
      expect(stream, emitsError(isA<Exception>()));
    });
  });
}

// path: test/shared/operasi/firebase_operasi/base_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

import 'base_op_firebase_test.mocks.dart';

@GenerateMocks([StatusOpFirebase])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockStatusOpFirebase mockStatusOpFirebase;
  late BaseOpFirebase baseOpFirebase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStatusOpFirebase = MockStatusOpFirebase();

    // Atur mock untuk mengembalikan Future<void> yang sudah selesai.
    // Ini diperlukan karena metode yang diuji memanggilnya dan mengharapkan Future.
    when(mockStatusOpFirebase.updateGlobalStatus()).thenAnswer((_) async {});

    baseOpFirebase = BaseOpFirebase(
      firestore: fakeFirestore,
      statusOp: mockStatusOpFirebase,
    );
  });

  group('BaseOpFirebase', () {
    const collectionName = 'test_collection';

    Map<String, dynamic>? dataAsMap(Map<String, dynamic>? data) {
      return data;
    }

    test('insert() harus menambahkan dokumen dan memanggil updateGlobalStatus',
        () async {
      const docId = 'test_doc_1';
      final data = <String, dynamic>{'id': docId, 'value': 'hello'};

      await baseOpFirebase.sisipkan(collectionName, docId, data);

      final doc =
          await fakeFirestore.collection(collectionName).doc(docId).get();
      final docData = dataAsMap(doc.data());
      expect(doc.exists, isTrue);
      expect(docData?['value'], 'hello');
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test(
        'add() harus menambahkan dokumen baru dan memanggil updateGlobalStatus',
        () async {
      final data = <String, dynamic>{'id': 'new_id', 'value': 'added'};

      final docRef = await baseOpFirebase.add(collectionName, data);

      final doc = await docRef.get();
      final docData = dataAsMap(doc.data() as Map<String, dynamic>?);
      expect(doc.exists, isTrue);
      expect(docData?['value'], 'added');
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('update() harus memperbarui dokumen dan memanggil updateGlobalStatus',
        () async {
      const docId = 'doc_to_update';
      final initialData = <String, dynamic>{'id': docId, 'value': 'initial'};
      await fakeFirestore
          .collection(collectionName)
          .doc(docId)
          .set(initialData);
      final updateData = <String, dynamic>{'value': 'updated'};

      await baseOpFirebase.update(collectionName, docId, updateData);

      final doc =
          await fakeFirestore.collection(collectionName).doc(docId).get();
      final docData = dataAsMap(doc.data());
      expect(docData?['value'], 'updated');
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('delete() harus menghapus dokumen dan memanggil updateGlobalStatus',
        () async {
      const docId = 'doc_to_delete';
      final data = <String, dynamic>{'id': docId};
      await fakeFirestore.collection(collectionName).doc(docId).set(data);

      await baseOpFirebase.hapusPermanen(collectionName, docId);

      final doc =
          await fakeFirestore.collection(collectionName).doc(docId).get();
      expect(doc.exists, isFalse);
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test(
        'softDelete() harus mengatur isDeleted dan memanggil updateGlobalStatus',
        () async {
      const docId = 'doc_to_soft_delete';
      final data = <String, dynamic>{'id': docId, ColumnNames.isDeleted: false};
      await fakeFirestore.collection(collectionName).doc(docId).set(data);

      await baseOpFirebase.hapusSementara(collectionName, docId);

      final doc =
          await fakeFirestore.collection(collectionName).doc(docId).get();
      final docData = dataAsMap(doc.data());
      expect(doc.exists, isTrue);
      expect(docData?[ColumnNames.isDeleted], isTrue);
      expect(docData?.containsKey(ColumnNames.archivedAt), isTrue);
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test(
        'insertOrUpdateBatch() harus memproses semua item dan memanggil updateGlobalStatus',
        () async {
      final items = <Map<String, dynamic>>[
        {'id': 'batch1', 'value': 1},
        {'id': 'batch2', 'value': 2},
        {'id': 'batch1', 'value': 3}, // Akan menimpa batch1
      ];

      await baseOpFirebase.insertOrUpdateBatch(collectionName, items, 'id');

      final snapshot = await fakeFirestore.collection(collectionName).get();
      expect(snapshot.docs.length, 2);

      final doc1 =
          await fakeFirestore.collection(collectionName).doc('batch1').get();
      expect(dataAsMap(doc1.data())?['value'], 3);

      final doc2 =
          await fakeFirestore.collection(collectionName).doc('batch2').get();
      expect(dataAsMap(doc2.data())?['value'], 2);

      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test(
        'softDeleteAll() harus memproses semua item dan memanggil updateGlobalStatus SEKALI',
        () async {
      // ATUR
      await fakeFirestore
          .collection(collectionName)
          .doc('doc1')
          .set({'id': 'doc1', ColumnNames.isDeleted: false});
      await fakeFirestore
          .collection(collectionName)
          .doc('doc2')
          .set({'id': 'doc2', ColumnNames.isDeleted: false});
      await fakeFirestore.collection(collectionName).doc('doc3').set({
        'id': 'doc3',
        ColumnNames.isDeleted: true
      }); // Ini tidak akan tersentuh

      // JALANKAN
      final count = await baseOpFirebase.hapusSementaraSemua(collectionName);

      // VERIFIKASI
      expect(count, 2); // Hanya 2 dokumen yang seharusnya diubah

      final doc1 =
          await fakeFirestore.collection(collectionName).doc('doc1').get();
      final doc2 =
          await fakeFirestore.collection(collectionName).doc('doc2').get();

      expect(dataAsMap(doc1.data())?[ColumnNames.isDeleted], isTrue);
      expect(
          dataAsMap(doc1.data())?.containsKey(ColumnNames.archivedAt), isTrue);
      expect(dataAsMap(doc2.data())?[ColumnNames.isDeleted], isTrue);
      expect(
          dataAsMap(doc2.data())?.containsKey(ColumnNames.archivedAt), isTrue);

      // Pastikan dokumen yang sudah terhapus tidak ikut diubah (tidak ada archivedAt)
      final doc3 =
          await fakeFirestore.collection(collectionName).doc('doc3').get();
      expect(
          dataAsMap(doc3.data())?.containsKey(ColumnNames.archivedAt), isFalse);

      // Verifikasi bahwa updateGlobalStatus hanya dipanggil SEKALI.
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });
  });
}

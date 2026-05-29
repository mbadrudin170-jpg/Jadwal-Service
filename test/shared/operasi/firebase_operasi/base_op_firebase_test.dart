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
    // Inisialisasi instance palsu untuk setiap tes agar terisolasi
    fakeFirestore = FakeFirebaseFirestore();
    mockStatusOpFirebase = MockStatusOpFirebase();

    // Injeksi dependensi palsu ke dalam kelas yang diuji
    baseOpFirebase = BaseOpFirebase(
      firestore: fakeFirestore,
      statusOp: mockStatusOpFirebase,
    );
    // Penting: Reset interaksi mock setiap kali tes dijalankan
    reset(mockStatusOpFirebase);
  });

  group('BaseOpFirebase', () {
    const collectionName = 'test_collection';

    // Helper untuk melakukan casting data dengan aman
    Map<String, dynamic>? dataAsMap(Map<String, dynamic>? data) {
      return data;
    }

    test('insert() harus menambahkan dokumen dan memanggil updateGlobalStatus', () async {
      // ATUR: Data didefinisikan di dalam tes untuk isolasi
      const docId = 'test_doc_1';
      final data = {'id': docId, 'value': 'hello'};

      // JALANKAN
      await baseOpFirebase.insert(collectionName, docId, data);

      // VERIFIKASI
      final doc = await fakeFirestore.collection(collectionName).doc(docId).get();
      final docData = dataAsMap(doc.data());
      expect(doc.exists, isTrue);
      expect(docData?['value'], 'hello');
      expect(docData?.containsKey(ColumnNames.updatedAt), isTrue);

      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('add() harus menambahkan dokumen baru dan memanggil updateGlobalStatus', () async {
      // ATUR
      final data = {'id': 'new_id', 'value': 'added'};

      // JALANKAN
      final docRef = await baseOpFirebase.add(collectionName, data);

      // VERIFIKASI
      final doc = await docRef.get();
      final docData = dataAsMap(doc.data() as Map<String, dynamic>?);
      expect(doc.exists, isTrue);
      expect(docData?['value'], 'added');
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('update() harus memperbarui dokumen dan memanggil updateGlobalStatus', () async {
      // ATUR
      const docId = 'doc_to_update';
      final initialData = {'id': docId, 'value': 'initial'};
      await fakeFirestore.collection(collectionName).doc(docId).set(initialData);
      final updateData = {'value': 'updated'};

      // JALANKAN
      await baseOpFirebase.update(collectionName, docId, updateData);

      // VERIFIKASI
      final doc = await fakeFirestore.collection(collectionName).doc(docId).get();
      final docData = dataAsMap(doc.data());
      expect(docData?['value'], 'updated');
      expect(docData?.containsKey(ColumnNames.updatedAt), isTrue);
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('delete() harus menghapus dokumen dan memanggil updateGlobalStatus', () async {
      // ATUR
      const docId = 'doc_to_delete';
      final data = {'id': docId};
      await fakeFirestore.collection(collectionName).doc(docId).set(data);

      // JALANKAN
      await baseOpFirebase.delete(collectionName, docId);

      // VERIFIKASI
      final doc = await fakeFirestore.collection(collectionName).doc(docId).get();
      expect(doc.exists, isFalse);
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('softDelete() harus mengatur isDeleted dan memanggil updateGlobalStatus', () async {
      // ATUR
      const docId = 'doc_to_soft_delete';
      final data = {'id': docId, 'isDeleted': false};
      await fakeFirestore.collection(collectionName).doc(docId).set(data);

      // JALANKAN
      await baseOpFirebase.softDelete(collectionName, docId);

      // VERIFIKASI
      final doc = await fakeFirestore.collection(collectionName).doc(docId).get();
      final docData = dataAsMap(doc.data());
      expect(doc.exists, isTrue);
      expect(docData?[ColumnNames.isDeleted], isTrue);
      expect(docData?.containsKey(ColumnNames.archivedAt), isTrue);
      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('insertOrUpdateBatch() harus memproses semua item dan memanggil updateGlobalStatus', () async {
      // ATUR
      final items = [
        {'id': 'batch1', 'value': 1, 'isDeleted': false},
        {'id': 'batch2', 'value': 2, 'isDeleted': false},
        {'id': 'batch1', 'value': 3, 'isDeleted': false}, // Akan menimpa batch1
      ];

      // JALANKAN
      await baseOpFirebase.insertOrUpdateBatch(collectionName, items, 'id');

      // VERIFIKASI
      final snapshot = await fakeFirestore.collection(collectionName).get();
      expect(snapshot.docs.length, 2);

      final doc1 = await fakeFirestore.collection(collectionName).doc('batch1').get();
      final doc1Data = dataAsMap(doc1.data());
      expect(doc1Data?['value'], 3);

      final doc2 = await fakeFirestore.collection(collectionName).doc('batch2').get();
      final doc2Data = dataAsMap(doc2.data());
      expect(doc2Data?['value'], 2);

      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });

    test('softDeleteAll() harus memproses semua item dan memanggil updateGlobalStatus', () async {
      // ATUR
      await fakeFirestore.collection(collectionName).doc('doc1').set({'id': 'doc1', 'isDeleted': false});
      await fakeFirestore.collection(collectionName).doc('doc2').set({'id': 'doc2', 'isDeleted': false});
      await fakeFirestore.collection(collectionName).doc('doc3').set({'id': 'doc3', 'isDeleted': true});

      // JALANKAN
      final count = await baseOpFirebase.softDeleteAll(collectionName);

      // VERIFIKASI
      expect(count, 2); // Harusnya 2 dokumen terpengaruh

      final doc1 = await fakeFirestore.collection(collectionName).doc('doc1').get();
      final doc2 = await fakeFirestore.collection(collectionName).doc('doc2').get();
      final doc3 = await fakeFirestore.collection(collectionName).doc('doc3').get();

      final doc1Data = dataAsMap(doc1.data());
      final doc2Data = dataAsMap(doc2.data());
      final doc3Data = dataAsMap(doc3.data());

      expect(doc1Data?['isDeleted'], isTrue);
      expect(doc2Data?['isDeleted'], isTrue);
      // Cek bahwa archivedAt hanya ditambahkan ke dokumen yg baru di-soft-delete
      expect(doc1Data?.containsKey('archivedAt'), isTrue);
      expect(doc2Data?.containsKey('archivedAt'), isTrue);
      // Dokumen yang sudah isDeleted=true sebelumnya tidak boleh diubah
      expect(doc3Data?.containsKey('archivedAt'), isFalse);

      verify(mockStatusOpFirebase.updateGlobalStatus()).called(1);
    });
  });
}

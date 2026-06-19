// path: test/shared/operasi/firebase_operasi/base_op_firebase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

class MockStatusOpFirebase extends Mock implements StatusOpFirebase {}

void main() {
  group('BaseOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockStatusOpFirebase mockStatusOp;
    late BaseOpFirebase baseOpFirebase;

    const collectionName = 'test_collection';
    const docId = 'test_doc';
    final data = {'nama': 'Test'};

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockStatusOp = MockStatusOpFirebase();
      baseOpFirebase = BaseOpFirebase(
        firestore: fakeFirestore,
        statusOp: mockStatusOp,
      );
    });

    test(
      '01. tambah - harus menambahkan dokumen dan memperbarui status',
      () async {
        final docRef = await baseOpFirebase.tambah(collectionName, data);

        final doc = await docRef.get();
        expect(doc.exists, isTrue);
        expect(doc.data()?['nama'], 'Test');
        expect(doc.data()?[NamaKolom.diperbaruiPada], isNotNull);

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );

    test(
      '02. sisipkan - harus menyisipkan dokumen dan memperbarui status',
      () async {
        await baseOpFirebase.sisipkan(collectionName, docId, data);

        final doc = await fakeFirestore
            .collection(collectionName)
            .doc(docId)
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()?['nama'], 'Test');
        expect(doc.data()?[NamaKolom.diperbaruiPada], isNotNull);

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );

    test(
      '03. update - harus memperbarui dokumen dan memperbarui status',
      () async {
        await fakeFirestore.collection(collectionName).doc(docId).set(data);
        final updatedData = {'nama': 'Updated Test'};

        await baseOpFirebase.update(collectionName, docId, updatedData);

        final doc = await fakeFirestore
            .collection(collectionName)
            .doc(docId)
            .get();
        expect(doc.data()?['nama'], 'Updated Test');
        expect(doc.data()?[NamaKolom.diperbaruiPada], isNotNull);

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );

    test(
      '04. hapusSementara - harus melakukan soft delete dan memperbarui status',
      () async {
        await fakeFirestore.collection(collectionName).doc(docId).set(data);

        await baseOpFirebase.hapusSementara(collectionName, docId);

        final doc = await fakeFirestore
            .collection(collectionName)
            .doc(docId)
            .get();
        expect(doc.data()?[NamaKolom.dihapus], isTrue);
        expect(doc.data()?[NamaKolom.diperbaruiPada], isNotNull);
        expect(doc.data()?[NamaKolom.diarsipkanPada], isNotNull);

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );

    test(
      '05. hapusPermanen - harus menghapus dokumen dan memperbarui status',
      () async {
        await fakeFirestore.collection(collectionName).doc(docId).set(data);

        await baseOpFirebase.hapusPermanen(collectionName, docId);

        final doc = await fakeFirestore
            .collection(collectionName)
            .doc(docId)
            .get();
        expect(doc.exists, isFalse);

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );

    test(
      '06. hapusSementaraSemua - harus melakukan soft delete pada semua dokumen',
      () async {
        await fakeFirestore.collection(collectionName).doc('doc1').set({
          'nama': 'doc1',
          NamaKolom.dihapus: false,
        });
        await fakeFirestore.collection(collectionName).doc('doc2').set({
          'nama': 'doc2',
          NamaKolom.dihapus: false,
        });

        final count = await baseOpFirebase.hapusSementaraSemua(collectionName);

        expect(count, 2);
        final snapshot = await fakeFirestore.collection(collectionName).get();
        for (final doc in snapshot.docs) {
          expect(doc.data()[NamaKolom.dihapus], isTrue);
        }

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );

    test(
      '07. insertOrUpdateBatch - harus menyisipkan atau memperbarui batch',
      () async {
        final items = [
          {'id': 'doc1', 'nama': 'Doc 1'},
          {'id': 'doc2', 'nama': 'Doc 2'},
          {'id': 'doc1', 'nama': 'Updated Doc 1'},
        ];

        await baseOpFirebase.insertOrUpdateBatch(collectionName, items, 'id');

        final doc1 = await fakeFirestore
            .collection(collectionName)
            .doc('doc1')
            .get();
        final doc2 = await fakeFirestore
            .collection(collectionName)
            .doc('doc2')
            .get();

        expect(doc1.data()?['nama'], 'Updated Doc 1');
        expect(doc2.data()?['nama'], 'Doc 2');

        verify(mockStatusOp.perbaruiStatusGlobal()).called(1);
      },
    );
  });
}

extension on Object? {
  operator [](String other) {}
}

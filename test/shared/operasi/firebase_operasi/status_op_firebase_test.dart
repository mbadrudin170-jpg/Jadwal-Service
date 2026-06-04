// path: test/shared/operasi/firebase_operasi/status_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/status_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

void main() {
  group('StatusOpFirebase Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late StatusOpFirebase statusOpFirebase;
    late String collectionName;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      statusOpFirebase = StatusOpFirebase(firestore: fakeFirestore);
      collectionName = TableNameValue.get(TableName.statusGlobal);
    });

    test(
        '1. updateGlobalStatus - seharusnya membuat atau memperbarui status global',
        () async {
      // Arrange: Buat dokumen kosong terlebih dahulu untuk mensimulasikan dokumen yang ada.
      // Ini adalah workaround untuk batasan `fake_cloud_firestore` dengan serverTimestamp.
      await fakeFirestore
          .collection(collectionName)
          .doc(globalStatusId)
          .set({});

      // Act: Panggil method yang diuji. Ini sekarang akan menjalankan jalur 'update'.
      await statusOpFirebase.updateGlobalStatus();

      // Assert: Ambil dokumen dan verifikasi.
      final doc = await fakeFirestore
          .collection(collectionName)
          .doc(globalStatusId)
          .get();

      // Verifikasi bahwa dokumen ada dan berisi field 'updatedAt'.
      expect(doc.exists, isTrue);
      expect(doc.data()?.containsKey(ColumnNames.updatedAt), isTrue,
          reason: 'Field updatedAt seharusnya ada setelah pembaruan');
      expect(doc.data()?[ColumnNames.updatedAt], isNotNull,
          reason: 'Nilai updatedAt tidak boleh null');
    });
  });
}

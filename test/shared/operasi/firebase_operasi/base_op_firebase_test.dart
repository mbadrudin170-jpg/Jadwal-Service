// path: test/shared/operasi/firebase_operasi/base_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

// Dummy model for testing
class DummyModel implements HasId {
  @override
  final String id;
  final String name;
  final int value;

  DummyModel({required this.id, required this.name, required this.value});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'value': value};
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BaseOpFirebase baseOpFirebase;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    baseOpFirebase = BaseOpFirebase(firestore: fakeFirestore);
  });

  group('BaseOpFirebase Basic Tests', () {
    test('01. sisipkan harus membuat dokumen baru', () async {
      await baseOpFirebase.sisipkan('test_collection', 'doc1', {
        'name': 'test',
        'value': 100,
      });

      final doc = await fakeFirestore
          .collection('test_collection')
          .doc('doc1')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['name'], 'test');
    });

    test('02. update harus memperbarui dokumen', () async {
      await baseOpFirebase.sisipkan('test_collection', 'doc2', {
        'name': 'old',
        'value': 50,
      });

      await baseOpFirebase.update('test_collection', 'doc2', {'name': 'new'});

      final doc = await fakeFirestore
          .collection('test_collection')
          .doc('doc2')
          .get();

      expect(doc.data()?['name'], 'new');
      expect(doc.data()?['value'], 50);
    });

    test('03. softDelete harus menandai dokumen sebagai dihapus', () async {
      await baseOpFirebase.sisipkan('test_collection', 'doc3', {
        'name': 'delete_me',
      });

      await baseOpFirebase.softDelete('test_collection', 'doc3');

      final doc = await fakeFirestore
          .collection('test_collection')
          .doc('doc3')
          .get();

      expect(doc.data()?['is_deleted'], true);
      expect(doc.data()?['archived_at'], isNotNull);
    });
  });
}

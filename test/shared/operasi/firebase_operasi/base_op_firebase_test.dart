// path: test/shared/operasi/firebase_operasi/base_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

// Dummy model for testing
class DummyModel with HasId {
  @override
  final String id;
  final String name;
  final int value;
  bool? isDeleted;
  DateTime? updatedAt;

  DummyModel({
    required this.id,
    required this.name,
    required this.value,
    this.isDeleted,
    this.updatedAt,
  });

  factory DummyModel.fromMap(Map<String, dynamic> map) {
    return DummyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      value: map['value'] as int,
      isDeleted: map['isDeleted'] as bool?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'value': value,
        'isDeleted': isDeleted,
        'updatedAt': updatedAt,
      };
}

// Concrete implementation for testing
class DummyOpFirebase extends BaseOpFirebase<DummyModel> {
  DummyOpFirebase(FirebaseFirestore firestore) : super(
          firestore: firestore,
          collectionName: 'dummies',
          fromMap: (map) => DummyModel.fromMap(map),
          toMap: (model) => model.toMap(),
        );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DummyOpFirebase dummyOp;
  late CollectionReference<Map<String, dynamic>> collection;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dummyOp = DummyOpFirebase(fakeFirestore);
    collection = fakeFirestore.collection('dummies');
  });

  group('BaseOpFirebase Tests', () {
    test('01. add should create a document in Firestore', () async {
      final model = DummyModel(id: '1', name: 'test1', value: 100);
      await dummyOp.add(model);
      final doc = await collection.doc('1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['name'], 'test1');
    });

    test('02. delete should remove a document from Firestore', () async {
      await collection.doc('2').set({'id': '2', 'name': 'test2', 'value': 200});
      await dummyOp.delete('2');
      final doc = await collection.doc('2').get();
      expect(doc.exists, isFalse);
    });

    test('03. softDelete should mark a document as deleted', () async {
      await collection.doc('3').set({'id': '3', 'name': 'test3', 'value': 300});
      await dummyOp.softDelete('3');
      final doc = await collection.doc('3').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['isDeleted'], isTrue);
      expect(doc.data()?['updatedAt'], isNotNull);
    });

    test('04. getById should retrieve a single document', () async {
      await collection.doc('4').set({'id': '4', 'name': 'test4', 'value': 400});
      final model = await dummyOp.getById('4');
      expect(model, isNotNull);
      expect(model!.name, 'test4');
    });

    test('05. getById should return null if document does not exist', () async {
      final model = await dummyOp.getById('non-existent');
      expect(model, isNull);
    });

    test('06. getAll should retrieve all non-deleted documents', () async {
      await collection.doc('5').set({'id': '5', 'name': 'test5', 'value': 500});
      await collection
          .doc('6')
          .set({'id': '6', 'name': 'test6', 'value': 600, 'isDeleted': true});
      final models = await dummyOp.getAll();
      expect(models.length, 1);
      expect(models.first.name, 'test5');
    });

    test('07. getStream should return a stream of non-deleted documents', () async {
      final stream = dummyOp.getStream();
      expect(
        stream,
        emits(
          (List<DummyModel> list) => list.isEmpty,
        ),
      );

      await collection.doc('7').set({'id': '7', 'name': 'test7', 'value': 700});
      expect(
        stream,
        emits(
          (List<DummyModel> list) =>
              list.length == 1 && list.first.name == 'test7',
        ),
      );
    });

    test('08. update should modify a document', () async {
      final model = DummyModel(id: '8', name: 'test8', value: 800);
      await dummyOp.add(model);
      await dummyOp.update(model.copyWith(name: 'updated8'));
      final doc = await collection.doc('8').get();
      expect(doc.data()?['name'], 'updated8');
    });

    test('09. addOrUpdateBatch should create and update documents', () async {
      final modelsToAdd = [
        DummyModel(id: '9', name: 'test9', value: 900),
        DummyModel(id: '10', name: 'test10', value: 1000),
      ];
      final modelsToUpdate = [
        DummyModel(id: '9', name: 'updated9', value: 901),
      ];

      await dummyOp.addOrUpdateBatch(modelsToAdd);
      var doc9 = await collection.doc('9').get();
      var doc10 = await collection.doc('10').get();
      expect(doc9.data()?['name'], 'test9');
      expect(doc10.exists, isTrue);

      await dummyOp.addOrUpdateBatch(modelsToUpdate);
      doc9 = await collection.doc('9').get();
      expect(doc9.data()?['name'], 'updated9');
    });

    test('10. hasNewData should detect new or updated documents', () async {
      final lastCheck = DateTime.now().subtract(const Duration(minutes: 5));
      final newUpdate = DateTime.now();

      expect(await dummyOp.hasNewData(lastCheck), isFalse);

      await collection
          .doc('11')
          .set({'id': '11', 'name': 'test11', 'updatedAt': Timestamp.now()});
      expect(await dummyOp.hasNewData(lastCheck), isTrue);
    });
  });
}

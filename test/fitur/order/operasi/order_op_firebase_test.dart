// path: test/fitur/order/operasi/order_op_firebase_test.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/shared/enum/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

import 'order_op_firebase_test.mocks.dart';

@GenerateMocks([
  BaseOpFirebase,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  DocumentSnapshot,
  AggregateQuery,
  AggregateQuerySnapshot,
], customMocks: [
  MockSpec<Query<Map<String, dynamic>>>(
      as: #MockQueryMap, onMissingStub: OnMissingStub.returnDefault),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(
      as: #MockQuerySnapshotMap, onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
      as: #MockDocumentSnapshotMap, onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
      as: #MockDocumentReferenceMap, onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockCollectionReferenceMap,
      onMissingStub: OnMissingStub.returnDefault),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
    as: #MockQueryDocumentSnapshotMap,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  late MockBaseOpFirebase mockBaseOp;
  late MockFirebaseFirestore mockFirestore;
  late OrderOpFirebase orderOpFirebase;
  late MockCollectionReferenceMap mockCollectionReference;
  late MockDocumentReferenceMap mockDocumentReference;
  late MockQueryMap mockQuery;
  late MockDocumentSnapshotMap mockDocumentSnapshot;
  late MockQuerySnapshotMap mockQuerySnapshot;
  late MockAggregateQuery mockAggregateQuery;
  late MockAggregateQuerySnapshot mockAggregateQuerySnapshot;

  setUp(() {
    mockBaseOp = MockBaseOpFirebase();
    mockFirestore = MockFirebaseFirestore();
    orderOpFirebase = OrderOpFirebase(
      firestore: mockFirestore,
      baseOp: mockBaseOp,
    );
    mockCollectionReference = MockCollectionReferenceMap();
    mockDocumentReference = MockDocumentReferenceMap();
    mockQuery = MockQueryMap();
    mockDocumentSnapshot = MockDocumentSnapshotMap();
    mockQuerySnapshot = MockQuerySnapshotMap();
    mockAggregateQuery = MockAggregateQuery();
    mockAggregateQuerySnapshot = MockAggregateQuerySnapshot();

    when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockCollectionReference.where(any, isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.orderBy(any, descending: anyNamed('descending')))
        .thenReturn(mockQuery);
    when(mockQuery.where(any, isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.count()).thenReturn(mockAggregateQuery);
    when(mockAggregateQuery.get())
        .thenAnswer((_) async => mockAggregateQuerySnapshot);
  });

  final order = OrderModel(
    id: 'order1',
    customerId: 'cust1',
    customerName: 'John Doe',
    packageName: 'Paket 1',
    packageId: 'pkg1',
    price: 100000,
    duration: 30,
    orderDate: DateTime(2023, 1, 1),
    status: StatusOrderEnum.pending,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  final orderMap = order.toFirebase();

  group('Grup Pengujian OrderOpFirebase', () {
    test('1. Uji penambahan pesanan baru', () async {
      when(mockBaseOp.insert(any, any, any)).thenAnswer((_) async => {});
      await orderOpFirebase.addOrder(order);
      verify(mockBaseOp.insert(any, order.id, orderMap)).called(1);
    });

    test('2. Uji pembaruan pesanan', () async {
      when(mockBaseOp.update(any, any, any)).thenAnswer((_) async => {});
      await orderOpFirebase.updateOrder(order);
      verify(mockBaseOp.update(any, order.id, orderMap)).called(1);
    });

    test('3. Uji penghapusan lunak pesanan', () async {
      const orderId = 'order1';
      when(mockBaseOp.softDelete(any, any)).thenAnswer((_) async => {});
      await orderOpFirebase.softDeleteOrder(orderId);
      verify(mockBaseOp.softDelete(any, orderId)).called(1);
    });

    test('4. Uji mendapatkan stream semua pesanan', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshotMap();
      when(mockQueryDocSnapshot.id).thenReturn(order.id);
      when(mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController = StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      final resultStream = orderOpFirebase.getAllOrdersStream();

      expect(
          resultStream,
          emits(isA<List<OrderModel>>()
              .having((list) => list.length, 'panjang', 1)
              .having((list) => list.first.id, 'id', order.id)));

      streamController.add(mockQuerySnapshot);
      streamController.close();
    });

    test('5. Uji mendapatkan pesanan berdasarkan ID', () async {
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn(order.id);
      when(mockDocumentSnapshot.data()).thenReturn(orderMap);

      final result = await orderOpFirebase.getOrderById(order.id);

      expect(result, isA<OrderModel>());
      expect(result?.id, order.id);
      verify(mockCollectionReference.doc(order.id)).called(1);
    });

    test('6. Uji mendapatkan stream pesanan berdasarkan ID pengguna', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshotMap();
      when(mockQueryDocSnapshot.id).thenReturn(order.id);
      when(mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController = StreamController<QuerySnapshot<Map<String, dynamic>>>();
      final mockCollection = MockCollectionReferenceMap();
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')))
          .thenReturn(mockQuery);
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      final resultStream = orderOpFirebase.getAllByUserId('cust1');

      expect(
          resultStream,
          emits(isA<List<OrderModel>>()
              .having((list) => list.length, 'panjang', 1)
              .having((list) => list.first.customerId, 'customerId', 'cust1')));

      streamController.add(mockQuerySnapshot);
      streamController.close();
    });

    test('7. Uji mendapatkan stream pesanan berdasarkan status', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshotMap();
      when(mockQueryDocSnapshot.id).thenReturn(order.id);
      when(mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController = StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      final resultStream =
          orderOpFirebase.getStreamByStatus(StatusOrderEnum.pending);

      expect(
          resultStream,
          emits(isA<List<OrderModel>>()
              .having((list) => list.length, 'panjang', 1)
              .having((list) => list.first.status, 'status',
                  StatusOrderEnum.pending)));

      streamController.add(mockQuerySnapshot);
      streamController.close();
    });

    test('8. Uji mendapatkan list pesanan berdasarkan status', () async {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshotMap();
      when(mockQueryDocSnapshot.id).thenReturn(order.id);
      when(mockQueryDocSnapshot.data()).thenReturn(orderMap);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      final result =
          await orderOpFirebase.getOrdersByStatus(StatusOrderEnum.pending);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.status, StatusOrderEnum.pending);
    });

    test('9. Uji menghitung pesanan berdasarkan status', () async {
      when(mockAggregateQuerySnapshot.count).thenReturn(5);

      final result =
          await orderOpFirebase.countOrdersByStatus(StatusOrderEnum.pending);

      expect(result, 5);
      verify(mockQuery.count()).called(1);
    });
  });
}


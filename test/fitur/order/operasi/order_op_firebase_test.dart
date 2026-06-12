// path: test/fitur/order/operasi/order_op_firebase_test.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/status_order_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

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
  StatusOpFirebase,
], customMocks: [
  MockSpec<Query<Map<String, dynamic>>>(as: #MockQueryMap),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(as: #MockQuerySnapshotMap),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
      as: #MockDocumentSnapshotMap),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
      as: #MockDocumentReferenceMap),
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockCollectionReferenceMap),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
    as: #MockQueryDocumentSnapshotMap,
  ),
])
void main() {
  late MockBaseOpFirebase mockBaseOp;
  late MockFirebaseFirestore mockFirestore;
  late OrderOpFirebase orderOpFirebase;
  late MockCollectionReferenceMap mockOrderCollectionReference;
  late MockCollectionReferenceMap mockStatusCollectionReference;
  late MockDocumentReferenceMap mockDocumentReference;
  late MockQueryMap mockQuery;
  late MockDocumentSnapshotMap mockDocumentSnapshot;
  late MockQuerySnapshotMap mockQuerySnapshot;
  late MockAggregateQuery mockAggregateQuery;
  late MockAggregateQuerySnapshot mockAggregateQuerySnapshot;

  setUp(() {
    // 1. Inisialisasi semua mocks
    mockBaseOp = MockBaseOpFirebase();
    mockFirestore = MockFirebaseFirestore();
    mockOrderCollectionReference = MockCollectionReferenceMap();
    mockStatusCollectionReference = MockCollectionReferenceMap();
    mockDocumentReference = MockDocumentReferenceMap();
    mockQuery = MockQueryMap();
    mockDocumentSnapshot = MockDocumentSnapshotMap();
    mockQuerySnapshot = MockQuerySnapshotMap();
    mockAggregateQuery = MockAggregateQuery();
    mockAggregateQuerySnapshot = MockAggregateQuerySnapshot();

    // 2. Stub panggilan yang terjadi di dalam konstruktor SEBELUM instansiasi
    // Stub untuk koleksi 'status_global' yang menyebabkan error
    when(mockFirestore.collection(NamaTabel.get(TableName.statusGlobal)))
        .thenReturn(mockStatusCollectionReference);
    when(mockStatusCollectionReference.doc(any))
        .thenReturn(mockDocumentReference);

    // Stub untuk koleksi utama 'customer_order'
    when(mockFirestore.collection(NamaTabel.get(TableName.customerOrder)))
        .thenReturn(mockOrderCollectionReference);

    // Stub untuk method `set` yang dipanggil oleh StatusOpFirebase
    when(mockDocumentReference.set(any, any)).thenAnswer((_) async {});

    // 3. Instansiasi kelas yang diuji setelah stubbing konstruktor selesai
    orderOpFirebase = OrderOpFirebase(
      firestore: mockFirestore,
      baseOp: mockBaseOp,
    );

    // 4. Stub sisa method yang dibutuhkan untuk tes
    when(mockOrderCollectionReference.doc(any))
        .thenReturn(mockDocumentReference);
    when(mockOrderCollectionReference.where(any,
            isEqualTo: anyNamed('isEqualTo')))
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
    packageId: 'pkg1',
    date: DateTime(2023, 1),
    updatedAt: DateTime(2023, 1),
  );

  final orderMap = order.toFirebase();

  group('Grup Pengujian OrderOpFirebase', () {
    test('1. Uji penambahan pesanan baru', () async {
      when(mockBaseOp.sisipkan(any, any, any))
          .thenAnswer((_) => Future.value());
      await orderOpFirebase.addOrder(order);
      verify(mockBaseOp.sisipkan(
              NamaTabel.get(TableName.customerOrder), order.id, orderMap))
          .called(1);
    });

    test('2. Uji pembaruan pesanan', () async {
      when(mockBaseOp.update(any, any, any)).thenAnswer((_) => Future.value());
      await orderOpFirebase.updateOrder(order);
      verify(mockBaseOp.update(
              NamaTabel.get(TableName.customerOrder), order.id, orderMap))
          .called(1);
    });

    test('3. Uji penghapusan lunak pesanan', () async {
      const orderId = 'order1';
      when(mockBaseOp.hapusSementara(any, any))
          .thenAnswer((_) => Future.value());

      await orderOpFirebase.softDeleteOrder(orderId);

      verify(mockBaseOp.hapusSementara(
              NamaTabel.get(TableName.customerOrder), orderId))
          .called(1);
    });

    test('4. Uji mendapatkan stream semua pesanan', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshotMap();
      when(mockQueryDocSnapshot.id).thenReturn(order.id);
      when(mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
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
      verify(mockOrderCollectionReference.doc(order.id)).called(1);
    });

    test('6. Uji mendapatkan stream pesanan berdasarkan ID pengguna', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshotMap();
      when(mockQueryDocSnapshot.id).thenReturn(order.id);
      when(mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
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

      final streamController =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      final resultStream =
          orderOpFirebase.getStreamByStatus(StatusOrderEnum.baru);

      expect(
          resultStream,
          emits(isA<List<OrderModel>>()
              .having((list) => list.length, 'panjang', 1)
              .having((list) => list.first.status, 'status',
                  StatusOrderEnum.baru)));

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
          await orderOpFirebase.getOrdersByStatus(StatusOrderEnum.baru);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.status, StatusOrderEnum.baru);
    });

    test('9. Uji menghitung pesanan berdasarkan status', () async {
      when(mockAggregateQuerySnapshot.count).thenReturn(5);

      final result = await orderOpFirebase.countOrdersByStatus(
          StatusOrderEnum.baru, 'cust1');

      expect(result, 5);
      verify(mockQuery.count()).called(1);
    });
  });
}

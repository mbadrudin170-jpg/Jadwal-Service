// path: test/fitur/order/operasi/order_op_firebase_test.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/status_order_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/status_op_firebase.dart';

// Mock classes
class MockBaseOpFirebase extends Mock implements BaseOpFirebase {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockAggregateQuery extends Mock implements AggregateQuery {}

class MockAggregateQuerySnapshot extends Mock
    implements AggregateQuerySnapshot {}

class MockStatusOpFirebase extends Mock implements StatusOpFirebase {}

void main() {
  late MockBaseOpFirebase mockBaseOp;
  late MockFirebaseFirestore mockFirestore;
  late OrderOpFirebase orderOpFirebase;
  late MockCollectionReference mockOrderCollectionReference;
  late MockCollectionReference mockStatusCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockQuery mockQuery;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockAggregateQuery mockAggregateQuery;
  late MockAggregateQuerySnapshot mockAggregateQuerySnapshot;

  setUp(() {
    // 1. Inisialisasi semua mocks
    mockBaseOp = MockBaseOpFirebase();
    mockFirestore = MockFirebaseFirestore();
    mockOrderCollectionReference = MockCollectionReference();
    mockStatusCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockQuery = MockQuery();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();
    mockAggregateQuery = MockAggregateQuery();
    mockAggregateQuerySnapshot = MockAggregateQuerySnapshot();

    // 2. Stub panggilan yang terjadi di dalam konstruktor SEBELUM instansiasi
    // Stub untuk koleksi 'status_global' yang menyebabkan error
    when(() => mockFirestore.collection(NamaTabel.statusGlobal))
        .thenReturn(mockStatusCollectionReference);
    when(() => mockStatusCollectionReference.doc(any()))
        .thenReturn(mockDocumentReference);

    // Stub untuk koleksi utama 'customer_order'
    when(() => mockFirestore.collection(NamaTabel.customerOrder))
        .thenReturn(mockOrderCollectionReference);

    // Stub untuk method `set` yang dipanggil oleh StatusOpFirebase
    when(() => mockDocumentReference.set(any(), any())).thenAnswer((_) async {});

    // 3. Instansiasi kelas yang diuji setelah stubbing konstruktor selesai
    orderOpFirebase = OrderOpFirebase(
      firestore: mockFirestore,
      baseOp: mockBaseOp,
    );

    // 4. Stub sisa method yang dibutuhkan untuk tes
    when(() => mockOrderCollectionReference.doc(any()))
        .thenReturn(mockDocumentReference);
    when(() => mockOrderCollectionReference.where(any,
            isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockQuery);
    when(() => mockQuery.orderBy(any, descending: any(named: 'descending'))).thenReturn(mockQuery);
    when(() => mockQuery.where(any, isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockQuery);
    when(() => mockQuery.count()).thenReturn(mockAggregateQuery);
    when(() => mockAggregateQuery.get())
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
      when(() => mockBaseOp.sisipkan(any(), any(), any()))
          .thenAnswer((_) => Future.value());
      await orderOpFirebase.addOrder(order);
      verify(() => mockBaseOp.sisipkan(
              NamaTabel.customerOrder, order.id, orderMap))
          .called(1);
    });

    test('2. Uji pembaruan pesanan', () async {
      when(() => mockBaseOp.update(any(), any(), any())).thenAnswer((_) => Future.value());
      await orderOpFirebase.updateOrder(order);
      verify(() => mockBaseOp.update(
              NamaTabel.customerOrder, order.id, orderMap))
          .called(1);
    });

    test('3. Uji penghapusan lunak pesanan', () async {
      const orderId = 'order1';
      when(() => mockBaseOp.hapusSementara(any(), any()))
          .thenAnswer((_) => Future.value());

      await orderOpFirebase.softDeleteOrder(orderId);

      verify(() => mockBaseOp.hapusSementara(
              NamaTabel.customerOrder, orderId))
          .called(1);
    });

    test('4. Uji mendapatkan stream semua pesanan', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshot();
      when(() => mockQueryDocSnapshot.id).thenReturn(order.id);
      when(() => mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(() => mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

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
      when(() => mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.id).thenReturn(order.id);
      when(() => mockDocumentSnapshot.data()).thenReturn(orderMap);

      final result = await orderOpFirebase.getOrderById(order.id);

      expect(result, isA<OrderModel>());
      expect(result?.id, order.id);
      verify(() => mockOrderCollectionReference.doc(order.id)).called(1);
    });

    test('6. Uji mendapatkan stream pesanan berdasarkan ID pengguna', () {
      final mockQueryDocSnapshot = MockQueryDocumentSnapshot();
      when(() => mockQueryDocSnapshot.id).thenReturn(order.id);
      when(() => mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(() => mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

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
      final mockQueryDocSnapshot = MockQueryDocumentSnapshot();
      when(() => mockQueryDocSnapshot.id).thenReturn(order.id);
      when(() => mockQueryDocSnapshot.data()).thenReturn(orderMap);

      final streamController =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(() => mockQuery.snapshots()).thenAnswer((_) => streamController.stream);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

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
      final mockQueryDocSnapshot = MockQueryDocumentSnapshot();
      when(() => mockQueryDocSnapshot.id).thenReturn(order.id);
      when(() => mockQueryDocSnapshot.data()).thenReturn(orderMap);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      final result =
          await orderOpFirebase.getOrdersByStatus(StatusOrderEnum.baru);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.status, StatusOrderEnum.baru);
    });

    test('9. Uji menghitung pesanan berdasarkan status', () async {
      when(() => mockAggregateQuerySnapshot.count).thenReturn(5);

      final result = await orderOpFirebase.countOrdersByStatus(
          StatusOrderEnum.baru, 'cust1');

      expect(result, 5);
      verify(() => mockQuery.count()).called(1);
    });
  });
}

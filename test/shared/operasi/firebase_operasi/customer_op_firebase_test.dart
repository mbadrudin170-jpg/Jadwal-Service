// path: test/shared/operasi/firebase_operasi/customer_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CustomerOpFirebase customerOpFirebase;
  late BaseOpFirebase baseOpFirebase;
  final customerCollection = TableNameValue.get(TableName.customer);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    baseOpFirebase = BaseOpFirebase(firestore: fakeFirestore);
    customerOpFirebase = CustomerOpFirebase(firestore: fakeFirestore, baseOp: baseOpFirebase);
  });

  // Data model pelanggan untuk digunakan dalam tes
  final c1 = CustomerModel(
    id: 'cust-001',
    name: 'Pelanggan Satu',
    email: 'satu@example.com',
    isDeleted: false,
    fcmToken: 'token-awal',
    role: '',
    createdAt: DateTime.now(),
  );

  final c2 = CustomerModel(
    id: 'cust-002',
    name: 'Pelanggan Dua',
    email: 'dua@example.com',
    isDeleted: true, // soft-deleted
    role: '',
    createdAt: DateTime.now(),
  );
    final c3 = CustomerModel(
    id: 'cust-003',
    name: 'Pelanggan Tiga',
    email: 'tiga@example.com',
    isDeleted: false,
    role: '',
    createdAt: DateTime.now(),
  );


  group('2. Pengujian CustomerOpFirebase', () {
    test('2.1. harus bisa membuat pelanggan baru', () async {
      await customerOpFirebase.createCustomer(c1);

      final snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![ColumnNames.name], c1.name);
    });

    test('2.2. harus bisa memperbarui data pelanggan', () async {
      await customerOpFirebase.createCustomer(c1);
      final updatedCustomer = c1.copyWith(name: 'Pelanggan Satu (Updated)');

      await customerOpFirebase.updateCustomer(updatedCustomer);

      final snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()![ColumnNames.name], 'Pelanggan Satu (Updated)');
    });

    test('2.3. harus bisa melakukan soft delete pada pelanggan', () async {
      await customerOpFirebase.createCustomer(c1);
      await customerOpFirebase.softDeleteCustomer(c1.id);

      final snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![ColumnNames.isDeleted], isTrue);
    });

    test('2.4. harus bisa menghapus pelanggan secara permanen', () async {
      await customerOpFirebase.createCustomer(c1);
      await customerOpFirebase.deleteCustomer(c1.id);

      final snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('2.5. harus bisa memperbarui waktu terakhir aktif (last active)', () async {
      await customerOpFirebase.createCustomer(c1);
      await customerOpFirebase.updateLastActive(c1.id);

      final snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()![ColumnNames.lastActiveAt], isNotNull);
    });

    test('2.6. harus bisa menyimpan FCM token', () async {
      const newToken = 'fcm-token-baru-123';
      await customerOpFirebase.createCustomer(c1);
      await customerOpFirebase.saveFcmToken(c1.id, newToken);

      final snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], newToken);
    });

    test('2.7. tidak boleh menyimpan FCM token jika null atau kosong', () async {
      await customerOpFirebase.createCustomer(c1);
      
      // Test dengan token null
      await customerOpFirebase.saveFcmToken(c1.id, null);
      var snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], 'token-awal'); // harus tetap token awal
      
      // Test dengan token kosong
      await customerOpFirebase.saveFcmToken(c1.id, '');
      snapshot = await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], 'token-awal'); // harus tetap token awal
    });

    test('2.8. harus bisa mendapatkan semua pelanggan yang tidak di-soft-delete', () async {
      await customerOpFirebase.createCustomer(c1);
      await customerOpFirebase.createCustomer(c2); // isDeleted = true
      await customerOpFirebase.createCustomer(c3);

      final customers = await customerOpFirebase.getAllCustomers();

      expect(customers.length, 2);
      expect(customers.any((c) => c.id == c1.id), isTrue);
      expect(customers.any((c) => c.id == c3.id), isTrue);
      expect(customers.any((c) => c.id == c2.id), isFalse);
    });

    test('2.9. harus bisa mendapatkan data pelanggan sekali (one-time fetch)', () async {
      await customerOpFirebase.createCustomer(c1);

      final customer = await customerOpFirebase.getCustomerOnce(c1.id);

      expect(customer, isNotNull);
      expect(customer!.id, c1.id);
      expect(customer.name, c1.name);
    });

    test('2.10. harus mengembalikan null jika pelanggan tidak ditemukan (one-time fetch)', () async {
      final customer = await customerOpFirebase.getCustomerOnce('id-tidak-ada');
      expect(customer, isNull);
    });

    test('2.11. harus bisa mendapatkan stream data pelanggan', () async {
      await customerOpFirebase.createCustomer(c1);

      final stream = customerOpFirebase.getCustomerStream(c1.id);

      // Menunggu item pertama dari stream
      final customerFromStream = await stream.first;
      expect(customerFromStream, isNotNull);
      expect(customerFromStream!.id, c1.id);

      // Memperbarui data dan memeriksa apakah stream memancarkan data baru
      final updatedCustomer = c1.copyWith(name: 'Nama Baru dari Stream');
      await customerOpFirebase.updateCustomer(updatedCustomer);
      
      final updatedCustomerFromStream = await stream.first;
      expect(updatedCustomerFromStream!.name, 'Nama Baru dari Stream');
    });
  });
}

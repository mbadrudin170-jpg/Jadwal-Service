// path: test/shared/operasi/firebase_operasi/customer_op_firebase_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CustomerOpFirebase customerOpFirebase;
  late BaseOpFirebase baseOpFirebase;
  final customerCollection = NamaTabel.get(TableName.customer);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    baseOpFirebase = BaseOpFirebase(firestore: fakeFirestore);
    customerOpFirebase = CustomerOpFirebase(
        firestore: fakeFirestore, baseOpFirebase: baseOpFirebase);
  });

  // Data model pelanggan untuk digunakan dalam tes
  final c1 = PelangganModel(
    id: 'cust-001',
    nama: 'Pelanggan Satu',
    telepon: '0811111111',
    alamat: 'Jalan Satu',
    password: 'password',
  );

  final c2 = PelangganModel(
    id: 'cust-002',
    nama: 'Pelanggan Dua',
    telepon: '0822222222',
    alamat: 'Jalan Dua',
    password: 'password',
    diHapus: true, // soft-deleted
  );
  final c3 = PelangganModel(
    id: 'cust-003',
    nama: 'Pelanggan Tiga',
    telepon: '0833333333',
    alamat: 'Jalan Tiga',
    password: 'password',
  );

  group('2. Pengujian CustomerOpFirebase', () {
    test('2.1. harus bisa membuat pelanggan baru', () async {
      await customerOpFirebase.addCustomer(c1);

      final snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![NamaKolom.nama], c1.nama);
    });

    test('2.2. harus bisa memperbarui data pelanggan', () async {
      await customerOpFirebase.addCustomer(c1);
      final updatedCustomer = c1.copyWith(name: 'Pelanggan Satu (Updated)');

      await customerOpFirebase.updateCustomer(updatedCustomer);

      final snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()![NamaKolom.nama], 'Pelanggan Satu (Updated)');
    });

    test('2.3. harus bisa melakukan soft delete pada pelanggan', () async {
      await customerOpFirebase.addCustomer(c1);
      await customerOpFirebase.softDeleteCustomer(c1.id);

      final snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![NamaKolom.dihapus], isTrue);
    });

    test('2.4. harus bisa menghapus pelanggan secara permanen', () async {
      await customerOpFirebase.addCustomer(c1);
      await customerOpFirebase.deleteCustomer(c1.id);

      final snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('2.5. harus bisa memperbarui waktu terakhir aktif (last active)',
        () async {
      await customerOpFirebase.addCustomer(c1);
      await customerOpFirebase.updateLastActive(c1.id);

      final snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()![NamaKolom.terkahirAktif], isA<Timestamp>());
    });

    test('2.6. harus bisa menyimpan FCM token', () async {
      const newToken = 'fcm-token-baru-123';
      await customerOpFirebase.addCustomer(c1);
      await customerOpFirebase.saveFcmToken(c1.id, newToken);

      final snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], newToken);
    });

    test('2.7. tidak boleh menyimpan FCM token jika null atau kosong',
        () async {
      const initialToken = 'token-awal';
      await customerOpFirebase.addCustomer(c1);
      // Simpan token awal terlebih dahulu
      await customerOpFirebase.saveFcmToken(c1.id, initialToken);
      var snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], initialToken);

      // Test dengan token null, seharusnya tidak berubah
      await customerOpFirebase.saveFcmToken(c1.id, null);
      snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], initialToken);

      // Test dengan token kosong, seharusnya tidak berubah
      await customerOpFirebase.saveFcmToken(c1.id, '');
      snapshot =
          await fakeFirestore.collection(customerCollection).doc(c1.id).get();
      expect(snapshot.data()!['fcmToken'], initialToken);
    });

    test(
        '2.8. harus bisa mendapatkan semua pelanggan yang tidak di-soft-delete',
        () async {
      await customerOpFirebase.addCustomer(c1);
      await customerOpFirebase.addCustomer(c2); // isDeleted = true
      await customerOpFirebase.addCustomer(c3);

      final customers = await customerOpFirebase.getAllCustomers();

      expect(customers.length, 2);
      expect(customers.any((c) => c.id == c1.id), isTrue);
      expect(customers.any((c) => c.id == c3.id), isTrue);
      expect(customers.any((c) => c.id == c2.id), isFalse);
    });

    test('2.9. harus bisa mendapatkan data pelanggan sekali (one-time fetch)',
        () async {
      await customerOpFirebase.addCustomer(c1);

      final customer = await customerOpFirebase.getById(c1.id);

      expect(customer, isNotNull);
      expect(customer!.id, c1.id);
      expect(customer.nama, c1.nama);
    });

    test(
        '2.10. harus mengembalikan null jika pelanggan tidak ditemukan (one-time fetch)',
        () async {
      final customer = await customerOpFirebase.getById('id-tidak-ada');
      expect(customer, isNull);
    });

    test('2.11. harus bisa mendapatkan stream data pelanggan', () async {
      // 1. Buat customer dulu
      await customerOpFirebase.addCustomer(c1);

      // 2. Dapatkan stream-nya
      final stream = customerOpFirebase.getCustomerStream(c1.id);

      // 3. Siapkan ekspektasi. Stream akan mengeluarkan:
      //    a. Customer awal (karena data sudah ada saat listen)
      //    b. Customer yang sudah diupdate (setelah diupdate)
      expectLater(
        stream,
        emitsInOrder([
          // Matcher untuk data pertama
          isA<PelangganModel>().having((c) => c.nama, 'name', c1.nama),
          // Matcher untuk data kedua setelah update
          isA<PelangganModel>()
              .having((c) => c.nama, 'name', 'Nama Baru dari Stream'),
        ]),
      );

      // 4. Update data, ini akan memicu emisi kedua dari stream
      final updatedCustomer = c1.copyWith(name: 'Nama Baru dari Stream');
      // Tambahkan sedikit delay untuk memastikan expectLater sudah subscribe
      await Future.delayed(const Duration(milliseconds: 10));
      await customerOpFirebase.updateCustomer(updatedCustomer);
    });
  });
}

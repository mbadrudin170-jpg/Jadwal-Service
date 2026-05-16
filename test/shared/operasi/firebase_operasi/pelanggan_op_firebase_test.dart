// path: test/shared/operasi/firebase_operasi/pelanggan_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';

void main() {
  group('PelangganOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late PelangganOpFirebase pelangganOpFirebase;

    final pelangganTest = PelangganModel(
      id: 'user_123',
      nama: 'Nama Pengguna',
      telepon: '081234567890',
      alamat: 'Jl. Contoh No. 123',
      password: 'password123', // Seharusnya tidak disimpan langsung
      diperbarui: DateTime.now(),
    );

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      pelangganOpFirebase = PelangganOpFirebase(firestore: fakeFirestore);

      // Menambahkan data pelanggan awal
      await fakeFirestore
          .collection('pelanggan')
          .doc(pelangganTest.id)
          .set(pelangganTest.toFirebase());
    });

    test('perbaruiPelanggan harus memperbarui data di Firestore', () async {
      final pelangganDiperbarui = pelangganTest.copyWith(nama: 'Nama Baru');

      await pelangganOpFirebase.perbaruiPelanggan(pelangganDiperbarui);

      final snapshot = await fakeFirestore.collection('pelanggan').doc(pelangganTest.id).get();
      final data = snapshot.data();

      expect(data, isNotNull);
      expect(data!['nama'], 'Nama Baru');
    });

    test('ambilPelangganStream mengembalikan stream PelangganModel', () {
      final stream = pelangganOpFirebase.ambilPelangganStream(pelangganTest.id);

      expect(stream, isA<Stream<PelangganModel?>>());

      // Verifikasi data pertama dari stream
      expect(stream, emits(isA<PelangganModel>().having((final p) => p.id, 'id', pelangganTest.id)));
    });

    test('ambilPelangganStream mengembalikan null jika pelanggan tidak ada', () {
       final stream = pelangganOpFirebase.ambilPelangganStream('user_tidak_ada');
       expect(stream, emits(null));
    });

    test('ambilPelangganSekali mengembalikan PelangganModel jika ada', () async {
      final hasil = await pelangganOpFirebase.ambilPelangganSekali(pelangganTest.id);

      expect(hasil, isNotNull);
      expect(hasil, isA<PelangganModel>());
      expect(hasil!.id, pelangganTest.id);
    });

    test('ambilPelangganSekali mengembalikan null jika tidak ada', () async {
      final hasil = await pelangganOpFirebase.ambilPelangganSekali('user_tidak_ada');
      expect(hasil, isNull);
    });

     test('simpanTokenFCM harus memperbarui token FCM', () async {
      const tokenBaru = 'token_fcm_baru';
      await pelangganOpFirebase.simpanTokenFCM(pelangganTest.id, tokenBaru);

      final snapshot = await fakeFirestore.collection('pelanggan').doc(pelangganTest.id).get();

      expect(snapshot.data()?['fcmToken'], tokenBaru);
    });

    test('simpanTokenFCM tidak melakukan apa-apa jika token null atau kosong', () async {
       await pelangganOpFirebase.simpanTokenFCM(pelangganTest.id, null);
       final snapshot1 = await fakeFirestore.collection('pelanggan').doc(pelangganTest.id).get();
       expect(snapshot1.data()!['fcmToken'], isNull);

       await pelangganOpFirebase.simpanTokenFCM(pelangganTest.id, '');
       final snapshot2 = await fakeFirestore.collection('pelanggan').doc(pelangganTest.id).get();
       expect(snapshot2.data()!['fcmToken'], isNull);
    });
  });
}

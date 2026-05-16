
// path: test/shared/operasi/firebase_operasi/paket_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';

void main() {
  group('PaketOpFirebase Test', () {
    late FakeFirebaseFirestore fakeFirestore;
    late PaketOpFirebase paketOpFirebase;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      paketOpFirebase = PaketOpFirebase(fakeFirestore);
    });

    // Data dummy untuk pengujian
    final paketData = {
      'nama': 'Paket Super Cepat',
      'harga': 100000,
      'deskripsi': 'Internet super cepat untuk seluruh keluarga.',
      'dibuat': DateTime.now(),
      'diperbarui': DateTime.now(),
    };

    test('ambilNamaPaket - Sukses', () async {
      // Tambahkan dokumen ke koleksi palsu
      final docRef = await fakeFirestore.collection('paket').add(paketData);
      final paketId = docRef.id;

      final namaPaket = await paketOpFirebase.ambilNamaPaket(paketId);

      expect(namaPaket, 'Paket Super Cepat');
    });

    test('ambilNamaPaket - Gagal (Paket Tidak Ditemukan)', () async {
      const paketId = 'id_tidak_ada';

      final namaPaket = await paketOpFirebase.ambilNamaPaket(paketId);

      expect(namaPaket, 'Paket Tidak Ditemukan');
    });

    test('ambilPaketModelById - Sukses', () async {
      final docRef = await fakeFirestore.collection('paket').add(paketData);
      final paketId = docRef.id;

      final paketModel = await paketOpFirebase.ambilPaketModelById(paketId);

      expect(paketModel, isA<PaketModel>());
      expect(paketModel?.id, paketId);
      expect(paketModel?.nama, 'Paket Super Cepat');
      expect(paketModel?.harga, 100000);
    });

    test('ambilPaketModelById - Gagal (null)', () async {
      const paketId = 'id_tidak_ada';

      final paketModel = await paketOpFirebase.ambilPaketModelById(paketId);

      expect(paketModel, isNull);
    });
  });
}

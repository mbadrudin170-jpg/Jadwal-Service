// path: test/shared/operasi/firebase_operasi/pengaturan_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/operasi/firebase_operasi/pengaturan_op_firebase.dart';

void main() {
  group('PengaturanOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late PengaturanOpFirebase pengaturanOpFirebase;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      pengaturanOpFirebase = PengaturanOpFirebase(firestore: fakeFirestore);
    });

    test('getPengaturan harus mengembalikan data ketika dokumen ada', () async {
      // Menyiapkan data di Firestore palsu
      final dataPengaturan = {
        'modePemeliharaan': true,
        'infoPemeliharaan': 'Sedang ada perbaikan.',
      };
      await fakeFirestore
          .collection('pengaturan')
          .doc('app')
          .set(dataPengaturan);

      // Menjalankan fungsi dan memeriksa hasilnya
      final hasil = await pengaturanOpFirebase.getPengaturan();

      expect(hasil, isA<Map<String, dynamic>>());
      expect(hasil['modePemeliharaan'], isTrue);
      expect(hasil['infoPemeliharaan'], 'Sedang ada perbaikan.');
    });

    test('getPengaturan harus mengembalikan nilai default ketika dokumen tidak ada', () async {
      // Tidak ada data yang disiapkan, sehingga dokumen tidak akan ditemukan

      // Menjalankan fungsi dan memeriksa hasilnya
      final hasil = await pengaturanOpFirebase.getPengaturan();

      expect(hasil['modePemeliharaan'], isFalse);
      expect(
        hasil['infoPemeliharaan'],
        'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
      );
    });
  });
}

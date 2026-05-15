
// path: test/user/data/operasi/kritik_saran_operasi_user_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/user/data/operasi/kritik_saran_operasi_user.dart';

void main() {
  group('KritikSaranOperasiUser Test', () {
    late FakeFirebaseFirestore fakeFirestore;
    late KritikSaranOperasiUser operasi;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      operasi = KritikSaranOperasiUser(fakeFirestore);
    });

    test('buatKritikSaranBaru berhasil menambahkan data ke Firestore', () async {
      final model = KritikSaranModel(
        id: '1',
        userId: 'user123',
        isi: 'Ini adalah kritik pertama.',
        diperbarui: DateTime.now(),
      );

      await operasi.buatKritikSaranBaru(model);

      final snapshot = await fakeFirestore.collection('kritik_saran').get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['userId'], 'user123');
      expect(snapshot.docs.first.data()['isi'], 'Ini adalah kritik pertama.');
    });

    test('bacaSemuaKritikSaran mengembalikan stream data yang benar', () async {
      // Tambahkan beberapa data untuk diuji
      await fakeFirestore.collection('kritik_saran').add({
        'userId': 'user123',
        'isi': 'Kritik 1',
        'diperbarui': DateTime.now(),
      });
      await fakeFirestore.collection('kritik_saran').add({
        'userId': 'user123',
        'isi': 'Kritik 2',
        'diperbarui': DateTime.now().add(const Duration(minutes: 5)),
      });
      await fakeFirestore.collection('kritik_saran').add({
        'userId': 'user456', // Data dari user lain
        'isi': 'Kritik 3',
        'diperbarui': DateTime.now(),
      });

      final stream = operasi.bacaSemuaKritikSaran('user123');

      // Harapkan stream memancarkan daftar dengan 2 item, diurutkan dengan benar
      expect(
        stream,
        emitsInOrder([
          (final List<KritikSaranModel> list) =>
              list.length == 2 && list.first.isi == 'Kritik 2',
        ]),
      );
    });

    test('perbaruiKritikSaran berhasil memperbarui dokumen', () async {
      final docRef = await fakeFirestore.collection('kritik_saran').add({
        'userId': 'user123',
        'isi': 'Isi lama',
        'diperbarui': DateTime.now(),
      });

      await operasi.perbaruiKritikSaran(docRef.id, 'Isi baru yang diperbarui');

      final updatedDoc = await docRef.get();

      expect(updatedDoc.data()?['isi'], 'Isi baru yang diperbarui');
    });

    test('hapusKritikSaran berhasil menghapus dokumen', () async {
      final docRef = await fakeFirestore.collection('kritik_saran').add({
        'userId': 'user123',
        'isi': 'Akan dihapus',
        'diperbarui': DateTime.now(),
      });

      // Pastikan dokumen ada sebelum dihapus
      var snapshot = await fakeFirestore.collection('kritik_saran').get();
      expect(snapshot.docs.length, 1);

      await operasi.hapusKritikSaran(docRef.id);

      // Pastikan dokumen sudah tidak ada setelah dihapus
      snapshot = await fakeFirestore.collection('kritik_saran').get();
      expect(snapshot.docs.length, 0);
    });
  });
}

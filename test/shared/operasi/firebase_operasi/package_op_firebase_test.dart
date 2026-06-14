// path: test/shared/operasi/firebase_operasi/package_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PaketOpFirebase packageOpFirebase;
  final packageCollection = NamaTabel.get(TableName.package);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    packageOpFirebase = PaketOpFirebase(firestore: fakeFirestore);
  });

  // Data model paket untuk digunakan dalam tes
  final p1 = PaketModel(
    id: 'pkg-001',
    nama: 'Paket Internet Super Cepat',
    poinPenukaran: 100,
    durasi: 30,
    harga: 100000,
    tipe: DurationType.days,
  );

  final p2 = PaketModel(
    id: 'pkg-002',
    nama: 'Paket Hemat',
    statusPublik: false, // Bukan paket publik
    poinPenukaran: 50,
    durasi: 7,
    harga: 25000,
    tipe: DurationType.days,
  );

  final p3 = PaketModel(
    id: 'pkg-003',
    nama: 'Paket Bonus',
    durasi: 1,
    harga: 0,
    tipe: DurationType.days,
  );
  final p4 = PaketModel(
    id: 'pkg-004',
    nama: 'Paket Dihapus',
    statusHapus: true, // Sudah dihapus
    poinPenukaran: 120,
    durasi: 30,
    harga: 120000,
    tipe: DurationType.days,
  );

  // Helper untuk menambahkan data ke fake firestore
  Future<void> addPackageToFirestore(PaketModel package) async {
    await fakeFirestore
        .collection(packageCollection)
        .doc(package.id)
        .set(package.toFirebase());
  }

  group('3. Pengujian PackageOpFirebase', () {
    test('3.1. harus bisa mendapatkan paket publik yang bisa ditukar poin',
        () async {
      await addPackageToFirestore(p1);
      await addPackageToFirestore(p2);
      await addPackageToFirestore(p3);
      await addPackageToFirestore(p4);

      final publicPackages = await packageOpFirebase.getPublicPackages();

      expect(publicPackages.length, 1);
      expect(publicPackages.first.id, p1.id);
    });

    test('3.2. harus mengembalikan list kosong jika tidak ada paket publik',
        () async {
      await addPackageToFirestore(p2);
      await addPackageToFirestore(p3);
      await addPackageToFirestore(p4);

      final publicPackages = await packageOpFirebase.getPublicPackages();

      expect(publicPackages.isEmpty, isTrue);
    });

    test('3.3. harus bisa mendapatkan paket berdasarkan ID', () async {
      await addPackageToFirestore(p1);

      final package = await packageOpFirebase.getPackageById(p1.id);

      expect(package, isNotNull);
      expect(package!.id, p1.id);
      expect(package.name, p1.nama);
    });

    test('3.4. harus mengembalikan null jika ID paket tidak ditemukan',
        () async {
      final package = await packageOpFirebase.getPackageById('id-tidak-ada');
      expect(package, isNull);
    });

    test('3.5. harus bisa menghapus paket secara permanen', () async {
      await addPackageToFirestore(p1);
      await packageOpFirebase.deletePackage(p1.id);

      final snapshot =
          await fakeFirestore.collection(packageCollection).doc(p1.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('3.6. harus bisa melakukan soft delete pada paket', () async {
      await addPackageToFirestore(p1);
      await packageOpFirebase.softDeletePackage(p1.id);

      final snapshot =
          await fakeFirestore.collection(packageCollection).doc(p1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![NamaKolom.diHapus], isTrue);
      expect(snapshot.data()![NamaKolom.diarsipkanPada], isNotNull);
    });
  });
}

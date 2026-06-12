// path: test/shared/operasi/firebase_operasi/package_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PaketOpFirebase packageOpFirebase;
  final packageCollection = TableNameValue.get(TableName.package);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    packageOpFirebase = PaketOpFirebase(firestore: fakeFirestore);
  });

  // Data model paket untuk digunakan dalam tes
  final p1 = PackageModel(
    id: 'pkg-001',
    name: 'Paket Internet Super Cepat',
    redemptionPoints: 100,
    duration: 30,
    price: 100000,
    type: DurationType.days,
  );

  final p2 = PackageModel(
    id: 'pkg-002',
    name: 'Paket Hemat',
    isPublic: false, // Bukan paket publik
    redemptionPoints: 50,
    duration: 7,
    price: 25000,
    type: DurationType.days,
  );

  final p3 = PackageModel(
    id: 'pkg-003',
    name: 'Paket Bonus',
    duration: 1,
    price: 0,
    type: DurationType.days,
  );
  final p4 = PackageModel(
    id: 'pkg-004',
    name: 'Paket Dihapus',
    isDeleted: true, // Sudah dihapus
    redemptionPoints: 120,
    duration: 30,
    price: 120000,
    type: DurationType.days,
  );

  // Helper untuk menambahkan data ke fake firestore
  Future<void> addPackageToFirestore(PackageModel package) async {
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
      expect(package.name, p1.name);
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
      expect(snapshot.data()![ColumnNames.isDeleted], isTrue);
      expect(snapshot.data()![ColumnNames.archivedAt], isNotNull);
    });
  });
}

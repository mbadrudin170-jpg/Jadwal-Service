// path: test/shared/operasi/firebase_operasi/active_customer_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/active_customer_op_firebase.dart';

void main() {
  late ActiveCustomerOpFirebase activeCustomerOp;
  late FakeFirebaseFirestore fakeFirestore;
  late CollectionReference collectionRef;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    activeCustomerOp = ActiveCustomerOpFirebase(firestore: fakeFirestore);
    collectionRef =
        fakeFirestore.collection(NamaTabel.get(TableName.activeCustomer));
  });

  final activeCustomer = PelangganAktifModel(
    id: 'cust1',
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
    tanggalMulai: DateTime(2023),
    tangglberakhir: DateTime(2023, 2),
    status: StatusPembayaran.paid,
  );

  test('1. Uji coba setActiveCustomer harus berhasil menambahkan data',
      () async {
    // Act
    await activeCustomerOp.setActiveCustomer(activeCustomer);

    // Assert
    final snapshot = await collectionRef.doc(activeCustomer.idPelanggan).get();
    final data = snapshot.data() as Map<String, dynamic>?;
    expect(snapshot.exists, isTrue);
    expect(data?[NamaKolom.idPelanggan], 'cust1');
    expect(data?[NamaKolom.idPaket], 'pkg1');
  });

  test('2. Uji coba getActiveCustomersById harus mengembalikan data yang benar',
      () async {
    // Arrange
    await collectionRef
        .doc(activeCustomer.idPelanggan)
        .set(activeCustomer.toFirebase());

    // Act
    final result = await activeCustomerOp
        .getActiveCustomersById(activeCustomer.idPelanggan);

    // Assert
    expect(result, isA<PelangganAktifModel>());
    expect(result?.idPelanggan, 'cust1');
    expect(result?.idPaket, 'pkg1');
  });

  test('3. Uji coba deleteActiveCustomer harus berhasil menghapus data',
      () async {
    // Arrange
    await collectionRef
        .doc(activeCustomer.idPelanggan)
        .set(activeCustomer.toFirebase());

    // Act
    await activeCustomerOp.deleteActiveCustomer(activeCustomer.idPelanggan);

    // Assert
    final snapshot = await collectionRef.doc(activeCustomer.idPelanggan).get();
    expect(snapshot.exists, isFalse);
  });
}

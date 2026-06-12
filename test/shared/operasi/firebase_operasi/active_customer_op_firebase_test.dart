// path: test/shared/operasi/firebase_operasi/active_customer_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
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

  final activeCustomer = ActiveCustomerModel(
    id: 'cust1',
    idPelanggan: 'cust1',
    packageId: 'pkg1',
    startDate: DateTime(2023),
    endDate: DateTime(2023, 2),
    status: PaymentStatus.paid,
  );

  test('1. Uji coba setActiveCustomer harus berhasil menambahkan data',
      () async {
    // Act
    await activeCustomerOp.setActiveCustomer(activeCustomer);

    // Assert
    final snapshot = await collectionRef.doc(activeCustomer.idPelanggan).get();
    final data = snapshot.data() as Map<String, dynamic>?;
    expect(snapshot.exists, isTrue);
    expect(data?[NamaKolom.customerId], 'cust1');
    expect(data?[NamaKolom.packageId], 'pkg1');
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
    expect(result, isA<ActiveCustomerModel>());
    expect(result?.idPelanggan, 'cust1');
    expect(result?.packageId, 'pkg1');
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

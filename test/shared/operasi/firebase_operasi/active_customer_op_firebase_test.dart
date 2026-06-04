
// path: test/shared/operasi/firebase_operasi/active_customer_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
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
        fakeFirestore.collection(TableNameValue.get(TableName.activeCustomer));
  });

  final activeCustomer = ActiveCustomerModel(
    id: 'cust1',
    customerId: 'cust1',
    packageId: 'pkg1',
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2023, 2, 1),
    status: PaymentStatus.paid,
  );

  test('1. Uji coba setActiveCustomer harus berhasil menambahkan data', () async {
    // Act
    await activeCustomerOp.setActiveCustomer(activeCustomer);

    // Assert
    final snapshot = await collectionRef.doc(activeCustomer.customerId).get();
    final data = snapshot.data() as Map<String, dynamic>?;
    expect(snapshot.exists, isTrue);
    expect(data?[ColumnNames.customerId], 'cust1');
    expect(data?[ColumnNames.packageId], 'pkg1');
  });

  test('2. Uji coba getActiveCustomersById harus mengembalikan data yang benar',
      () async {
    // Arrange
    await collectionRef
        .doc(activeCustomer.customerId)
        .set(activeCustomer.toFirebase());

    // Act
    final result =
        await activeCustomerOp.getActiveCustomersById(activeCustomer.customerId);

    // Assert
    expect(result, isA<ActiveCustomerModel>());
    expect(result?.customerId, 'cust1');
    expect(result?.packageId, 'pkg1');
  });

  test('3. Uji coba deleteActiveCustomer harus berhasil menghapus data', () async {
    // Arrange
    await collectionRef
        .doc(activeCustomer.customerId)
        .set(activeCustomer.toFirebase());

    // Act
    await activeCustomerOp.deleteActiveCustomer(activeCustomer.customerId);

    // Assert
    final snapshot = await collectionRef.doc(activeCustomer.customerId).get();
    expect(snapshot.exists, isFalse);
  });
}

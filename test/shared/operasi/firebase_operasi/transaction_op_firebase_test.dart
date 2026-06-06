// path: test/shared/operasi/firebase_operasi/transaction_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransactionOpFirebase transactionOpFirebase;
  final transactionsCollection =
      TableNameValue.get(TableName.transactions);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    transactionOpFirebase = TransactionOpFirebase(firestore: fakeFirestore);
  });

  // Data model transaksi untuk digunakan dalam tes
  final t1 = TransactionModel(
    id: 'trx-001',
    customerId: 'cust-123',

    paymentStatus: PaymentStatus.paid.name,
    endDate: DateTime.now().add(const Duration(days: 30)),
    date: DateTime.now(),
    earnedPoints: 10,
    usedPoints: 0,
    isDeleted: false,
    packageName: '',
    packageId: '',
    price: 0,
    month: 0,
    transactionType: '',
    paymentMethod: '',
    createdBy: '',
  );

  final t2 = TransactionModel(
    id: 'trx-002',
    customerId: 'cust-123',
    paymentStatus: PaymentStatus.unpaid.name,
    endDate: DateTime.now().add(const Duration(days: 60)),
    date: DateTime.now(),
    earnedPoints: 20,
    usedPoints: 5,
    isDeleted: false,
    packageName: '',
    packageId: '',
    price: 0,
    month: 0,
    transactionType: '',
    paymentMethod: '',
    createdBy: '',
  );

  final t3 = TransactionModel(
    id: 'trx-003',
    customerId: 'cust-456',
    paymentStatus: PaymentStatus.paid.name,
    endDate: DateTime.now().subtract(const Duration(days: 1)), // sudah kedaluwarsa
    date: DateTime.now(),
    earnedPoints: 5,
    isDeleted: false,
    packageName: '',
    packageId: '',
    price: 0,
    month: 0,
    transactionType: '',
    paymentMethod: '',
    createdBy: '',
  );

  group('1. Pengujian TransactionOpFirebase', () {
    test('1.1. harus bisa menambahkan transaksi', () async {
      await transactionOpFirebase.addTransaction(t1);

      final snapshot =
          await fakeFirestore.collection(transactionsCollection).doc(t1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![ColumnNames.customerId], t1.customerId);
    });

    test('1.2. harus bisa mendapatkan transaksi lunas terbaru', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.addTransaction(t2);

      final latestPaid =
          await transactionOpFirebase.getLatestPaidTransactionByUserId('cust-123');

      expect(latestPaid, isNotNull);
      expect(latestPaid!.id, t1.id);
    });

    test('1.3. harus mengembalikan null jika tidak ada transaksi lunas', () async {
      await transactionOpFirebase.addTransaction(t2); // Hanya transaksi unpaid

      final latestPaid =
          await transactionOpFirebase.getLatestPaidTransactionByUserId('cust-123');

      expect(latestPaid, isNull);
    });

    test('1.4. harus bisa mendapatkan semua transaksi milik pelanggan', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.addTransaction(t2);
      await transactionOpFirebase.addTransaction(t3); // Beda pelanggan

      final transactions =
          await transactionOpFirebase.getTransactionsByCustomerId('cust-123');

      expect(transactions.length, 2);
      expect(transactions.any((t) => t.id == t1.id), isTrue);
      expect(transactions.any((t) => t.id == t2.id), isTrue);
    });

    test('1.5. harus bisa menghitung total poin dengan benar', () async {
      // t1: 10 earned, 0 used -> 10
      // t2: 20 earned, 5 used, tapi status UNPAID -> tidak dihitung
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.addTransaction(t2);

      final totalPoints = await transactionOpFirebase.getTotalPoints('cust-123');

      expect(totalPoints, 10);
    });

    test('1.6. harus bisa menghapus transaksi secara permanen', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.deleteTransaction(t1.id);

      final snapshot =
          await fakeFirestore.collection(transactionsCollection).doc(t1.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('1.7. harus bisa melakukan soft delete pada transaksi', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.softDeleteTransaction(t1.id);

      final snapshot =
          await fakeFirestore.collection(transactionsCollection).doc(t1.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![ColumnNames.isDeleted], isTrue);
    });

    test('1.8. harus bisa mendapatkan paket aktif pelanggan', () async {
      await transactionOpFirebase.addTransaction(t1); // Aktif
      await transactionOpFirebase.addTransaction(t2); // Aktif, tapi unpaid
      await transactionOpFirebase.addTransaction(t3); // Kedaluwarsa

      final activePackages =
          await transactionOpFirebase.getPaketAktifCustomer('cust-123');
      
      // getPaketAktifCustomer tidak memfilter berdasarkan paymentStatus
      expect(activePackages.length, 2); 
      expect(activePackages.any((t) => t.id == t1.id), isTrue);
      expect(activePackages.any((t) => t.id == t2.id), isTrue);
    });

     test('1.9. getPaketAktifCustomer harus mengembalikan list kosong jika semua paket kedaluwarsa', () async {
      final expiredTransaction = t1.copyWith(endDate: DateTime.now().subtract(Duration(days: 1)));
      await transactionOpFirebase.addTransaction(expiredTransaction);

      final activePackages =
          await transactionOpFirebase.getPaketAktifCustomer(t1.customerId);
      
      expect(activePackages.isEmpty, isTrue);
    });
  });
}

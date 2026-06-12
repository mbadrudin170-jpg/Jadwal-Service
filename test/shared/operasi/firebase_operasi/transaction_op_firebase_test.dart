// path: test/shared/operasi/firebase_operasi/transaction_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransactionOpFirebase transactionOpFirebase;
  final transactionsCollection = NamaTabel.get(TableName.transactions);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    transactionOpFirebase = TransactionOpFirebase(firestore: fakeFirestore);
  });

  // Data model transaksi untuk digunakan dalam tes
  final t1 = TransactionModel(
    id: 'trx-001',
    customerId: 'cust-123',
    date: DateTime.now(),
    description: 'Pembelian paket 30 hari',
    amount: 100000,
    type: TransactionType.expense, // DIUBAH
    walletId: 'wallet-01',
    categoryId: 'cat-internet',
    paymentStatus: PaymentStatus.paid,
    endDate: DateTime.now().add(const Duration(days: 30)),
    earnedPoints: 10,
  );

  final t2 = TransactionModel(
    id: 'trx-002',
    customerId: 'cust-123',
    date: DateTime.now(),
    description: 'Pembelian paket 60 hari',
    amount: 200000,
    type: TransactionType.expense, // DIUBAH
    walletId: 'wallet-01',
    categoryId: 'cat-internet',
    // paymentStatus default-nya unpaid
    endDate: DateTime.now().add(const Duration(days: 60)),
    earnedPoints: 20,
    usedPoints: 5,
  );

  final t3 = TransactionModel(
    id: 'trx-003',
    customerId: 'cust-456',
    date: DateTime.now(),
    description: 'Paket Kedaluwarsa',
    amount: 50000,
    type: TransactionType.expense, // DIUBAH
    walletId: 'wallet-02',
    categoryId: 'cat-internet',
    paymentStatus: PaymentStatus.paid,
    endDate:
        DateTime.now().subtract(const Duration(days: 1)), // sudah kedaluwarsa
    earnedPoints: 5,
  );

  group('1. Pengujian TransactionOpFirebase', () {
    test('1.1. harus bisa menambahkan transaksi', () async {
      await transactionOpFirebase.addTransaction(t1);

      final snapshot = await fakeFirestore
          .collection(transactionsCollection)
          .doc(t1.id)
          .get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![NamaKolom.customerId], t1.customerId);
    });

    test('1.2. harus bisa mendapatkan transaksi lunas terbaru', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.addTransaction(t2);

      final latestPaid = await transactionOpFirebase
          .getLatestPaidTransactionByUserId('cust-123');

      expect(latestPaid, isNotNull);
      expect(latestPaid!.id, t1.id);
    });

    test('1.3. harus mengembalikan null jika tidak ada transaksi lunas',
        () async {
      await transactionOpFirebase.addTransaction(t2); // Hanya transaksi unpaid

      final latestPaid = await transactionOpFirebase
          .getLatestPaidTransactionByUserId('cust-123');

      expect(latestPaid, isNull);
    });

    test('1.4. harus bisa mendapatkan semua transaksi milik pelanggan',
        () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.addTransaction(t2);
      await transactionOpFirebase.addTransaction(t3); // Beda pelanggan

      final transactions =
          await transactionOpFirebase.getByCustomerId('cust-123');

      expect(transactions.length, 2);
      expect(transactions.any((t) => t.id == t1.id), isTrue);
      expect(transactions.any((t) => t.id == t2.id), isTrue);
    });

    test('1.5. getTotalPoints harus bisa menghitung total poin dengan benar',
        () async {
      // t1: 10 earned, 0 used -> 10
      // t2: 20 earned, 5 used, tapi status UNPAID -> tidak dihitung
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.addTransaction(t2);

      final totalPoints =
          await transactionOpFirebase.getTotalPoints('cust-123');

      expect(totalPoints, 10);
    });

    test(
      '1.6 getTotalPoints harus melakukan perhitungan dengan melakukan sum untuk semua earnedPoints dan dikurangi semua usedPoints pada transaksi yang statusnya lunas dan tidak disoft delete ',
      () async {
        const customerId = 'cust-test-points';

        // Data Transaksi
        // 1. Lunas, tidak dihapus -> Dihitung (100 - 10 = 90)
        final trx1 = TransactionModel(
            id: 'trx-p1',
            customerId: customerId,
            paymentStatus: PaymentStatus.paid,
            earnedPoints: 100,
            usedPoints: 10,
            date: DateTime.now(),
            description: '',
            type: TransactionType.expense,
            amount: 5,
            walletId: '',
            categoryId: '');

        // 2. Lunas, tidak dihapus -> Dihitung (50 - 5 = 45)
        final trx2 = TransactionModel(
            id: 'trx-p2',
            customerId: customerId,
            paymentStatus: PaymentStatus.paid,
            earnedPoints: 50,
            type: TransactionType.expense,
            usedPoints: 5,
            date: DateTime.now(),
            description: '',
            amount: 5,
            walletId: '',
            categoryId: '');

        // 3. Belum lunas -> Diabaikan
        final trx3 = TransactionModel(
            id: 'trx-p3',
            customerId: customerId,
            earnedPoints: 200,
            date: DateTime.now(),
            description: '',
            amount: 5,
            type: TransactionType.expense,
            walletId: '',
            categoryId: '');

        // 4. Lunas, tapi soft deleted -> Diabaikan
        final trx4 = TransactionModel(
            id: 'trx-p4',
            customerId: customerId,
            paymentStatus: PaymentStatus.paid,
            earnedPoints: 75,
            isDeleted: true,
            date: DateTime.now(),
            description: '',
            amount: 5,
            type: TransactionType.expense,
            walletId: '',
            categoryId: '');

        // 5. Lunas, tidak dihapus, tapi beda customer -> Diabaikan
        final trx5 = TransactionModel(
            id: 'trx-p5',
            customerId: 'cust-other',
            paymentStatus: PaymentStatus.paid,
            earnedPoints: 40,
            date: DateTime.now(),
            description: '',
            amount: 5,
            type: TransactionType.expense,
            walletId: '',
            categoryId: '');

        // Menambahkan semua transaksi ke firestore palsu
        await transactionOpFirebase.addTransaction(trx1);
        await transactionOpFirebase.addTransaction(trx2);
        await transactionOpFirebase.addTransaction(trx3);
        await transactionOpFirebase.addTransaction(trx4);
        await transactionOpFirebase.addTransaction(trx5);

        // Aksi: panggil method yang diuji
        final totalPoints =
            await transactionOpFirebase.getTotalPoints(customerId);

        // Aserasi: total poin harus 90 + 45 = 135
        expect(totalPoints, 135);
      },
    );

    test('1.7. harus bisa menghapus transaksi secara permanen', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.deleteTransaction(t1.id);

      final snapshot = await fakeFirestore
          .collection(transactionsCollection)
          .doc(t1.id)
          .get();
      expect(snapshot.exists, isFalse);
    });

    test('1.8. harus bisa melakukan soft delete pada transaksi', () async {
      await transactionOpFirebase.addTransaction(t1);
      await transactionOpFirebase.softDeleteTransaction(t1.id);

      final snapshot = await fakeFirestore
          .collection(transactionsCollection)
          .doc(t1.id)
          .get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![NamaKolom.isDeleted], isTrue);
    });

    test('1.9. harus bisa mendapatkan paket aktif pelanggan', () async {
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

    test(
        '1.10. getPaketAktifCustomer harus mengembalikan list kosong jika semua paket kedaluwarsa',
        () async {
      final expiredTransaction = t1.copyWith(
          endDate: DateTime.now().subtract(const Duration(days: 1)));
      await transactionOpFirebase.addTransaction(expiredTransaction);

      final activePackages =
          await transactionOpFirebase.getPaketAktifCustomer(t1.customerId!);

      expect(activePackages.isEmpty, isTrue);
    });
  });
}

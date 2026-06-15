// path: test/shared/operasi/firebase_operasi/transaction_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransaksiOpFirebase transactionOpFirebase;
  final transactionsCollection = NamaTabel.get(TableName.transactions);

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    transactionOpFirebase = TransaksiOpFirebase(firestore: fakeFirestore);
  });

  // Data model transaksi untuk digunakan dalam tes
  final t1 = TransaksiModel(
    id: 'trx-001',
    idPelanggan: 'cust-123',
    tanggal: DateTime.now(),
    deskripsi: 'Pembelian paket 30 hari',
    jumlah: 100000,
    tipe: TipeTransaksi.expense, // DIUBAH
    idDompet: 'wallet-01',
    idKategori: 'cat-internet',
    statusPembayaran: StatusPembayaran.paid,
    tangglberakhir: DateTime.now().add(const Duration(days: 30)),
    poinDidapat: 10,
  );

  final t2 = TransaksiModel(
    id: 'trx-002',
    idPelanggan: 'cust-123',
    tanggal: DateTime.now(),
    deskripsi: 'Pembelian paket 60 hari',
    jumlah: 200000,
    tipe: TipeTransaksi.expense, // DIUBAH
    idDompet: 'wallet-01',
    idKategori: 'cat-internet',
    // paymentStatus default-nya unpaid
    tangglberakhir: DateTime.now().add(const Duration(days: 60)),
    poinDidapat: 20,
    poinDigunakan: 5,
  );

  final t3 = TransaksiModel(
    id: 'trx-003',
    idPelanggan: 'cust-456',
    tanggal: DateTime.now(),
    deskripsi: 'Paket Kedaluwarsa',
    jumlah: 50000,
    tipe: TipeTransaksi.expense, // DIUBAH
    idDompet: 'wallet-02',
    idKategori: 'cat-internet',
    statusPembayaran: StatusPembayaran.paid,
    tangglberakhir:
        DateTime.now().subtract(const Duration(days: 1)), // sudah kedaluwarsa
    poinDidapat: 5,
  );

  group('1. Pengujian TransactionOpFirebase', () {
    test('1.1. harus bisa menambahkan transaksi', () async {
      await transactionOpFirebase.addTransaction(t1);

      final snapshot = await fakeFirestore
          .collection(transactionsCollection)
          .doc(t1.id)
          .get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()![NamaKolom.idPelanggan], t1.idPelanggan);
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
        final trx1 = TransaksiModel(
            id: 'trx-p1',
            idPelanggan: customerId,
            statusPembayaran: StatusPembayaran.paid,
            poinDidapat: 100,
            poinDigunakan: 10,
            tanggal: DateTime.now(),
            deskripsi: '',
            tipe: TipeTransaksi.expense,
            jumlah: 5,
            idDompet: '',
            idKategori: '');

        // 2. Lunas, tidak dihapus -> Dihitung (50 - 5 = 45)
        final trx2 = TransaksiModel(
            id: 'trx-p2',
            idPelanggan: customerId,
            statusPembayaran: StatusPembayaran.paid,
            poinDidapat: 50,
            tipe: TipeTransaksi.expense,
            poinDigunakan: 5,
            tanggal: DateTime.now(),
            deskripsi: '',
            jumlah: 5,
            idDompet: '',
            idKategori: '');

        // 3. Belum lunas -> Diabaikan
        final trx3 = TransaksiModel(
            id: 'trx-p3',
            idPelanggan: customerId,
            poinDidapat: 200,
            tanggal: DateTime.now(),
            deskripsi: '',
            jumlah: 5,
            tipe: TipeTransaksi.expense,
            idDompet: '',
            idKategori: '');

        // 4. Lunas, tapi soft deleted -> Diabaikan
        final trx4 = TransaksiModel(
            id: 'trx-p4',
            idPelanggan: customerId,
            statusPembayaran: StatusPembayaran.paid,
            poinDidapat: 75,
            diHapus: true,
            tanggal: DateTime.now(),
            deskripsi: '',
            jumlah: 5,
            tipe: TipeTransaksi.expense,
            idDompet: '',
            idKategori: '');

        // 5. Lunas, tidak dihapus, tapi beda customer -> Diabaikan
        final trx5 = TransaksiModel(
            id: 'trx-p5',
            idPelanggan: 'cust-other',
            statusPembayaran: StatusPembayaran.paid,
            poinDidapat: 40,
            tanggal: DateTime.now(),
            deskripsi: '',
            jumlah: 5,
            tipe: TipeTransaksi.expense,
            idDompet: '',
            idKategori: '');

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
      expect(snapshot.data()![NamaKolom.diHapus], isTrue);
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
          await transactionOpFirebase.getPaketAktifCustomer(t1.idPelanggan!);

      expect(activePackages.isEmpty, isTrue);
    });
  });
}

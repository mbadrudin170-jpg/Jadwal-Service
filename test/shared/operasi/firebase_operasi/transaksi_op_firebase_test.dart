// path: test/shared/operasi/firebase_operasi/transaksi_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';

void main() {
  group('TransaksiOpFirebase', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TransaksiOpFirebase transaksiOpFirebase;

    // Data dummy untuk pengujian
    final waktuSekarang = DateTime.now();
    const pelangganId1 = 'pelanggan_1';
    const pelangganId2 = 'pelanggan_2';

    final transaksi1 = TransactionModel(
      id: 'transaksi_1',
      idPelanggan: pelangganId1,
      tanggal: waktuSekarang,
      jumlah: 100000,
      tipe: TipeTransaksiEnum.pengeluaran,
      keterangan: 'Langganan Paket A',
      idDompet: 'dompet_1',
      idKategori: 'kategori_1',
    );

    final transaksi2 = TransactionModel(
      id: 'transaksi_2',
      idPelanggan: pelangganId1,
      tanggal: waktuSekarang.subtract(const Duration(days: 30)),
      jumlah: 95000,
      tipe: TipeTransaksiEnum.pengeluaran,
      keterangan: 'Perpanjangan Paket A',
      idDompet: 'dompet_1',
      idKategori: 'kategori_1',
    );

    // Transaksi untuk pelanggan lain, untuk memastikan filter berfungsi
    final transaksi3 = TransactionModel(
      id: 'transaksi_3',
      idPelanggan: pelangganId2,
      tanggal: waktuSekarang,
      jumlah: 150000,
      tipe: TipeTransaksiEnum.pengeluaran,
      keterangan: 'Langganan Paket B',
      idDompet: 'dompet_2',
      idKategori: 'kategori_2',
    );

    setUp(() async {
      // Inisialisasi Firestore palsu dan kelas operasi sebelum setiap tes
      fakeFirestore = FakeFirebaseFirestore();
      transaksiOpFirebase = TransaksiOpFirebase(firestore: fakeFirestore);

      // Menambahkan data dummy ke koleksi 'transaksi' di Firestore palsu
      await fakeFirestore
          .collection('transaksi')
          .doc(transaksi1.id)
          .set(transaksi1.toFirebase());
      await fakeFirestore
          .collection('transaksi')
          .doc(transaksi2.id)
          .set(transaksi2.toFirebase());
      await fakeFirestore
          .collection('transaksi')
          .doc(transaksi3.id)
          .set(transaksi3.toFirebase());
    });

    group('ambilRiwayatLangganan', () {
      test(
          'harus mengembalikan daftar transaksi yang benar dan terurut untuk pelanggan',
          () async {
        // Act: Panggil fungsi yang diuji
        final hasil =
            await transaksiOpFirebase.ambilRiwayatLangganan(pelangganId1);

        // Assert: Verifikasi hasilnya
        expect(hasil, isA<List<TransactionModel>>());
        expect(
          hasil.length,
          2,
          reason: 'Harusnya ada 2 transaksi untuk pelanggan 1',
        );

        // Verifikasi urutan (tanggal terbaru di awal)
        expect(
          hasil.first.id,
          transaksi1.id,
          reason: 'Transaksi terbaru harusnya yang pertama',
        );
        expect(
          hasil.last.id,
          transaksi2.id,
          reason: 'Transaksi lebih lama harusnya yang terakhir',
        );

        // Pastikan semua transaksi yang dikembalikan milik pelanggan yang benar
        expect(hasil.every((final t) => t.idPelanggan == pelangganId1), isTrue);
      });

      test(
          'harus mengembalikan daftar kosong jika pelanggan tidak memiliki transaksi',
          () async {
        // Act: Panggil fungsi dengan ID pelanggan yang tidak punya transaksi
        final hasil =
            await transaksiOpFirebase.ambilRiwayatLangganan('pelanggan_X');

        // Assert: Verifikasi hasilnya
        expect(hasil, isA<List<TransactionModel>>());
        expect(
          hasil,
          isEmpty,
          reason: 'Daftar harusnya kosong untuk pelanggan tanpa transaksi',
        );
      });
    });

    group('ambilRiwayatLanggananLengkap', () {
      test('harus mengembalikan hasil yang sama dengan ambilRiwayatLangganan',
          () async {
        // Act: Panggil kedua fungsi
        final hasilLengkap = await transaksiOpFirebase
            .ambilRiwayatLanggananLengkap(pelangganId1);
        final hasilBiasa =
            await transaksiOpFirebase.ambilRiwayatLangganan(pelangganId1);

        // Assert: Verifikasi bahwa hasilnya identik
        expect(hasilLengkap.length, hasilBiasa.length);
        expect(hasilLengkap.first.id, hasilBiasa.first.id);
        expect(hasilLengkap.last.id, hasilBiasa.last.id);
      });

      test(
          'harus mengembalikan daftar kosong untuk pelanggan tanpa riwayat lengkap',
          () async {
        // Act
        final hasil = await transaksiOpFirebase
            .ambilRiwayatLanggananLengkap('pelanggan_Y');

        // Assert
        expect(hasil, isEmpty);
      });
    });
  });
}

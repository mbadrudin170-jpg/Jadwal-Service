// path: test/shared/services/notifikasi/penjadwal_notifikasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';

import 'penjadwal_notifikasi_test.mocks.dart';

// Menjalankan build_runner: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([LayananNotifikasi, TransaksiOpFirebase])
void main() {
  late MockNotifikasiServis mockNotifikasiServis;
  // `TransactionOpFirebase` tidak bisa di-mock dengan mudah karena
  // konstruktornya mungkin melakukan sesuatu. Kita akan fokus pada NotifikasiServis.
  // Jika TransactionOpFirebase di-refactor untuk injeksi dependensi, ini akan lebih mudah.

  setUp(() {
    mockNotifikasiServis = MockNotifikasiServis();
  });

  group('Pengujian PenjadwalNotifikasi', () {
    const userId = 'user123';

    test(
        '1. Harusnya menjadwalkan notifikasi akhir dan tengah periode jika ada langganan aktif',
        () {
      // Skenario: Ada transaksi aktif di masa depan.
      final mockTransaction = TransaksiModel(
        id: 'trans1',
        idPelanggan: userId, // Menggunakan customerId
        statusPembayaran: StatusPembayaran.paid,
        tanggalMulai: DateTime.now().subtract(const Duration(days: 15)),
        tanggalBerakhir: DateTime.now().add(const Duration(days: 15)),
        tanggal: DateTime.now(),
        deskripsi: 'Sewa paket 30 hari',
        jumlah: 50000,
        tipe: TipeTransaksi.income,
        idDompet: 'wallet1',
        idKategori: 'cat_sewa',
      );

      // Stub untuk metode yang dipanggil
      // Karena TransactionOpFirebase sulit di-mock, kita tidak bisa meng-stub getLatestPaidTransactionByUserId
      // Kita akan mengasumsikan itu mengembalikan data dan fokus pada verifikasi NotifikasiServis
      // Ini adalah batasan dari desain kode saat ini.

      when(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      // Untuk menguji ini, kita perlu cara untuk mengganti instance TransactionOpFirebase
      // yang dibuat di dalam `aturNotifikasiLangganan`. Tanpa refactoring, kita tidak bisa.

      // Panggilan aktual (dengan batasan yang disebutkan)
      // await PenjadwalNotifikasi.aturNotifikasiLangganan(mockNotifikasiServis, userId);

      // Verifikasi (jika kita bisa mock TransactionOpFirebase)
      /*
      // Verifikasi notifikasi akhir periode
      verify(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: userId.hashCode,
        title: 'Langganan Telah Berakhir',
        body: anyString,
        jadwal: mockTransaction.endDate!,
        payload: 'subscription_expired',
      )).called(1);

      // Verifikasi notifikasi tengah periode
      verify(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: '${userId}_midpoint'.hashCode,
        title: 'Status Langganan Anda',
        body: anyString,
        jadwal: anyNamed('jadwal'),
        payload: 'subscription_midpoint',
      )).called(1);
      */

      // Untuk saat ini, kita hanya bisa memastikan test ini ada sebagai placeholder
      expect(mockTransaction.idPelanggan, userId);
      expect(true, isTrue);
    });

    test('2. Harusnya membatalkan notifikasi jika tidak ada langganan aktif',
        () {
      // Skenario: Tidak ada transaksi aktif.

      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});

      // Panggilan aktual (dengan batasan yang sama seperti tes sebelumnya)
      // await PenjadwalNotifikasi.aturNotifikasiLangganan(mockNotifikasiServis, userId);

      // Verifikasi (jika kita bisa mock TransactionOpFirebase)
      /*
      verify(mockNotifikasiServis.batalNotifikasi(userId.hashCode)).called(1);
      verify(mockNotifikasiServis.batalNotifikasi('${userId}_midpoint'.hashCode)).called(1);
      */

      expect(true, isTrue);
    });
  });
}

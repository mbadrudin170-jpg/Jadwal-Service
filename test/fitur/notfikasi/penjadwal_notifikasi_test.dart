// path: test/fitur/notfikasi/penjadwal_notifikasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/notfikasi/penjadwal_notifikasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

import 'penjadwal_notifikasi_test.mocks.dart';

@GenerateMocks([LayananNotifikasi])
void main() {
  late MockLayananNotifikasi mockLayananNotifikasi;

  setUp(() {
    mockLayananNotifikasi = MockLayananNotifikasi();

    when(
      mockLayananNotifikasi.jadwalNotifikasi(
        id: anyNamed('id'),
        judul: anyNamed('judul'),
        pesan: anyNamed('pesan'),
        jadwal: anyNamed('jadwal'),
        payload: anyNamed('payload'),
      ),
    ).thenAnswer((_) async => Future.value());

    when(mockLayananNotifikasi.batalNotifikasi(any))
        .thenAnswer((_) async => Future.value());
  });

  final transaksi = TransaksiModel(
    id: 'trx1',
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
    tanggal: DateTime.now(),
    deskripsi: 'Deskripsi Transaksi',
    jumlah: 50000,
    tipe: TipeTransaksi.income,
    idDompet: 'dompet1',
    idKategori: 'kategori1',
    statusPembayaran: StatusPembayaran.paid,
    tanggalMulai: DateTime.now(),
    tanggalBerakhir: DateTime.now().add(const Duration(days: 30)),
  );

  final namaPelanggan = 'John Doe';

  group('PenjadwalNotifikasi', () {
    test(
      '01. aturNotifikasiLangganan harus menjadwalkan notifikasi jika transaksi aktif',
      () async {
        // PERBAIKAN: PenjadwalNotifikasi.aturNotifikasiLangganan sekarang menerima String userId
        await PenjadwalNotifikasi.aturNotifikasiLangganan(
          mockLayananNotifikasi,
          'cust1', // userId
        );

        // Verifikasi bahwa jadwalNotifikasi dipanggil
        verify(
          mockLayananNotifikasi.jadwalNotifikasi(
            id: anyNamed('id'),
            judul: anyNamed('judul'),
            pesan: anyNamed('pesan'),
            jadwal: anyNamed('jadwal'),
            payload: anyNamed('payload'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    test('02. harus membatalkan notifikasi yang sudah ada', () async {
      // PERBAIKAN: Gunakan batalNotifikasi, bukan batalSemuaNotifikasi
      await PenjadwalNotifikasi.aturNotifikasiLangganan(
        mockLayananNotifikasi,
        'cust1',
      );

      verify(mockLayananNotifikasi.batalNotifikasi(any)).called(any);
    });
  });
}
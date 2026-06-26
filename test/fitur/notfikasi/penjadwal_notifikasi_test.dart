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
  late PenjadwalNotifikasi penjadwalNotifikasi;

  setUp(() {
    mockLayananNotifikasi = MockLayananNotifikasi();
    penjadwalNotifikasi = PenjadwalNotifikasi(
      mockLayananNotifikasi,
    );

    // Stubbing default behavior
    when(
      mockLayananNotifikasi.jadwalNotifikasi(
        id: anyNamed('id'),
        judul: anyNamed('judul'),
        pesan: anyNamed('pesan'),
        jadwal: anyNamed('jadwal'),
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

  group('scheduleJatuhTempoNotification', () {
    test(
      '01. harus menjadwalkan notifikasi jika tanggal berakhir tidak null',
      () async {
        final jadwal = transaksi.tanggalBerakhir!;
        final expectedId = '${transaksi.id.hashCode}-jatuh-tempo'.hashCode;

        await penjadwalNotifikasi.scheduleJatuhTempoNotification(
          transaksi: transaksi,
          namaPelanggan: namaPelanggan,
        );

        final captured = verify(
          mockLayananNotifikasi.jadwalNotifikasi(
            id: captureAnyNamed('id'),
            judul: captureAnyNamed('judul'),
            pesan: captureAnyNamed('pesan'),
            jadwal: captureAnyNamed('jadwal'),
          ),
        ).captured;

        expect(captured[0], expectedId);
        expect(captured[1], 'Peringatan Jatuh Tempo');
        expect(captured[2], 'Langganan atas nama John Doe akan berakhir besok.');
        expect(captured[3], jadwal.subtract(const Duration(days: 1)));
      },
    );

    test('02. tidak melakukan apa-apa jika tanggal berakhir null', () async {
      final transaksiTanpaTanggal = transaksi.copyWith(tanggalBerakhir: null);

      await penjadwalNotifikasi.scheduleJatuhTempoNotification(
        transaksi: transaksiTanpaTanggal,
        namaPelanggan: namaPelanggan,
      );

      verifyNever(
        mockLayananNotifikasi.jadwalNotifikasi(
          id: anyNamed('id'),
          judul: anyNamed('judul'),
          pesan: anyNamed('pesan'),
          jadwal: anyNamed('jadwal'),
        ),
      );
    });
  });

  group('cancelJatuhTempoNotification', () {
    test(
      '03. harus membatalkan notifikasi jatuh tempo dengan ID yang benar',
      () async {
        final expectedId = '${transaksi.id.hashCode}-jatuh-tempo'.hashCode;

        await penjadwalNotifikasi.cancelJatuhTempoNotification(transaksi.id);

        verify(mockLayananNotifikasi.batalNotifikasi(expectedId)).called(1);
      },
    );
  });

  group('schedulePembayaranNotification', () {
    test(
      '04. harus menjadwalkan notifikasi jika tanggal mulai tidak null',
      () async {
        final jadwal = transaksi.tanggalMulai!;
        final expectedId = '${transaksi.id.hashCode}-pembayaran'.hashCode;

        await penjadwalNotifikasi.schedulePembayaranNotification(
          transaksi: transaksi,
          namaPelanggan: namaPelanggan,
        );

        final captured = verify(
          mockLayananNotifikasi.jadwalNotifikasi(
            id: captureAnyNamed('id'),
            judul: captureAnyNamed('judul'),
            pesan: anyNamed('pesan'),
            jadwal: captureAnyNamed('jadwal'),
          ),
        ).captured;

        expect(captured[0], expectedId);
        expect(captured[1], 'Aktivasi Paket Berhasil');
        expect(captured[3], jadwal);
      },
    );

    test('05. tidak melakukan apa-apa jika tanggal mulai null', () async {
      final transaksiTanpaTanggal = transaksi.copyWith(tanggalMulai: null);

      await penjadwalNotifikasi.schedulePembayaranNotification(
        transaksi: transaksiTanpaTanggal,
        namaPelanggan: namaPelanggan,
      );

      verifyNever(
        mockLayananNotifikasi.jadwalNotifikasi(
          id: anyNamed('id'),
          judul: anyNamed('judul'),
          pesan: anyNamed('pesan'),
          jadwal: anyNamed('jadwal'),
        ),
      );
    });
  });

  group('cancelPembayaranNotification', () {
    test(
      '06. harus membatalkan notifikasi pembayaran dengan ID yang benar',
      () async {
        final expectedId = '${transaksi.id.hashCode}-pembayaran'.hashCode;

        await penjadwalNotifikasi.cancelPembayaranNotification(transaksi.id);

        verify(mockLayananNotifikasi.batalNotifikasi(expectedId)).called(1);
      },
    );
  });
}

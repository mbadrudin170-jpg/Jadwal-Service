// path: test/admin/providers/riwayat_aktivasi_paket_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/riwayat_aktivasi/provider/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

import 'riwayat_aktivasi_paket_provider_test.mocks.dart';

@GenerateMocks([TransaksiOpSqlite, PelangganOpSqlite])
void main() {
  late MockTransaksiOpSqlite mockTransaksiOp;
  late MockPelangganOpSqlite mockPelangganOp;
  late ProviderContainer container;

  final now = DateTime.now();
  final listTransaksi = [
    TransaksiModel(
      id: '1',
      idPelanggan: 'p1',
      idPaket: 'pkt1',
      tanggal: now,
      statusPembayaran: StatusPembayaran.paid,
      deskripsi: 'test',
      idDompet: 'd1',
      idKategori: 'k1',
      jumlah: 100,
      tanggalBerakhir: now,
      tanggalMulai: now,
      tipe: TipeTransaksi.expense,
    ),
    TransaksiModel(
      id: '2',
      idPelanggan: 'p2',
      idPaket: 'pkt2',
      tanggal: now.subtract(const Duration(days: 1)),
      // PERBAIKAN: Ganti StatusPembayaran.pending dengan StatusPembayaran.unpaid
      statusPembayaran: StatusPembayaran.unpaid,
      deskripsi: 'test2',
      idDompet: 'd2',
      idKategori: 'k2',
      jumlah: 200,
      tanggalBerakhir: now,
      tanggalMulai: now,
      tipe: TipeTransaksi.expense,
    ),
  ];

  final listPelanggan = [
    const PelangganModel(
      id: 'p1',
      nama: 'Pelanggan Satu',
      telepon: '08123456789',
      alamat: 'Jl. Satu',
      kataSandi: 'pass1',
      macAddress: '00:00:00:00:00:01',
    ),
    const PelangganModel(
      id: 'p2',
      nama: 'Pelanggan Dua',
      telepon: '08123456780',
      alamat: 'Jl. Dua',
      kataSandi: 'pass2',
      macAddress: '00:00:00:00:00:02',
    ),
  ];

  setUp(() {
    mockTransaksiOp = MockTransaksiOpSqlite();
    mockPelangganOp = MockPelangganOpSqlite();

    container = ProviderContainer(
      overrides: [
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOp),
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOp),
      ],
    );

    // Stub default untuk pelanggan
    when(mockPelangganOp.ambilSemua()).thenAnswer((_) async => listPelanggan);
  });

  tearDown(() {
    container.dispose();
  });

  group('RiwayatAktivasiPaket Provider', () {
    test(
      '01. build harus memuat data transaksi aktivasi dengan status pembayaran yang benar',
      () async {
        // PERBAIKAN: Gunakan ambilBerdasarkanStatusAktivasi
        when(mockTransaksiOp.ambilBerdasarkanStatusAktivasi())
            .thenAnswer((_) async => listTransaksi);

        final state = await container.read(
          riwayatAktivasiPaketProvider.future,
        );

        expect(state.items.length, 2);
        // Pastikan data pelanggan termuat
        expect(state.items.first.namaPelanggan, 'Pelanggan Satu');
        expect(state.items.last.namaPelanggan, 'Pelanggan Dua');
      },
    );

    test('02. changeSort harus mengubah urutan data', () async {
      when(mockTransaksiOp.ambilBerdasarkanStatusAktivasi())
          .thenAnswer((_) async => listTransaksi);

      // Tunggu build selesai
      await container.read(riwayatAktivasiPaketProvider.future);

      // Ubah urutan ke namaAZ
      final notifier = container.read(
        riwayatAktivasiPaketProvider.notifier,
      );
      notifier.changeSort(OpsiUrutan.namaAZ);

      final state = container.read(riwayatAktivasiPaketProvider).value;
      expect(state, isNotNull);
      expect(state?.sortBy, OpsiUrutan.namaAZ);
    });

    test('03. harus mengembalikan list kosong jika tidak ada transaksi aktivasi', () async {
      when(mockTransaksiOp.ambilBerdasarkanStatusAktivasi())
          .thenAnswer((_) async => []);

      final state = await container.read(
        riwayatAktivasiPaketProvider.future,
      );

      expect(state.items, isEmpty);
    });

    test('04. harus menangani data pelanggan yang tidak ditemukan', () async {
      // Simulasi transaksi dengan idPelanggan yang tidak ada di daftar pelanggan
      final transaksiTanpaPelanggan = [
        TransaksiModel(
          id: '3',
          idPelanggan: 'p99',
          idPaket: 'pkt3',
          tanggal: now,
          statusPembayaran: StatusPembayaran.paid,
          deskripsi: 'test3',
          idDompet: 'd3',
          idKategori: 'k3',
          jumlah: 300,
          tanggalBerakhir: now,
          tanggalMulai: now,
          tipe: TipeTransaksi.expense,
        ),
      ];

      when(mockTransaksiOp.ambilBerdasarkanStatusAktivasi())
          .thenAnswer((_) async => transaksiTanpaPelanggan);

      final state = await container.read(
        riwayatAktivasiPaketProvider.future,
      );

      expect(state.items.length, 1);
      expect(state.items.first.namaPelanggan, 'Tidak diketahui');
    });
  });
}
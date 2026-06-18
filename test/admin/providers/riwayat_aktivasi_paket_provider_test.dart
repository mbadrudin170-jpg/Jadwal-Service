
// path: test/admin/providers/riwayat_aktivasi_paket_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';

import 'riwayat_aktivasi_paket_provider_test.mocks.dart';

@GenerateMocks([TransaksiOpSqlite, PelangganOpSqlite])
void main() {
  group('RiwayatAktivasiPaket Notifier', () {
    late MockTransaksiOpSqlite mockTransaksiOpSqlite;
    late MockPelangganOpSqlite mockPelangganOpSqlite;
    late ProviderContainer container;

    setUp(() {
      mockTransaksiOpSqlite = MockTransaksiOpSqlite();
      mockPelangganOpSqlite = MockPelangganOpSqlite();

      container = ProviderContainer(
        overrides: [
          transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpSqlite),
          pelangganOpSqliteProvider.overrideWithValue(mockPelangganOpSqlite),
        ],
      );
    });

    final now = DateTime.now();
    final pelanggan1 = PelangganModel(
      id: 'cust1',
      nama: 'Beta',
      alamat: 'Alamat 1',
      telepon: '08123',
      macAddress: 'mac1',
      kataSandi: 'pass1',
    );
    final pelanggan2 = PelangganModel(
      id: 'cust2',
      nama: 'Alpha',
      alamat: 'Alamat 2',
      telepon: '08456',
      macAddress: 'mac2',
      kataSandi: 'pass2',
    );

    final transaksiList = [
      TransaksiModel(
        id: 'trx1',
        idPelanggan: 'cust1',
        idPaket: 'pkg1',
        namaPelanggan: 'Beta',
        namaPaket: 'Paket 1',
        hargaPaket: 50000,
        tanggal: now.subtract(const Duration(days: 5)),
        tanggalBerakhir: now.add(const Duration(days: 25)),
        statusPembayaran: StatusPembayaran.lunas,
        metodePembayaran: 'cash',
        tipeTransaksi: TipeTransaksi.baru,
        diperbaruiPada: now.subtract(const Duration(days: 1)),
      ),
      TransaksiModel(
        id: 'trx2',
        idPelanggan: 'cust2',
        idPaket: 'pkg2',
        namaPelanggan: 'Alpha',
        namaPaket: 'Paket 2',
        hargaPaket: 75000,
        tanggal: now.subtract(const Duration(days: 10)),
        tanggalBerakhir: now.add(const Duration(days: 20)),
        statusPembayaran: StatusPembayaran.belumLunas,
        metodePembayaran: 'cash',
        tipeTransaksi: TipeTransaksi.perpanjang,
        diperbaruiPada: now,
      ),
      TransaksiModel(
        id: 'trx3',
        idPelanggan: 'cust1',
        idPaket: 'pkg1',
        namaPelanggan: 'Beta',
        namaPaket: 'Paket 1',
        hargaPaket: 50000,
        tanggal: now.subtract(const Duration(days: 2)),
        tanggalBerakhir: now, // Berakhir hari ini
        statusPembayaran: StatusPembayaran.lunas,
        metodePembayaran: 'cash',
        tipeTransaksi: TipeTransaksi.baru,
        diperbaruiPada: now.subtract(const Duration(days: 2)),
      ),
    ];

    final pelangganList = [pelanggan1, pelanggan2];

    test('01. build should load and sort data by endDate by default', () async {
      when(mockTransaksiOpSqlite.ambilBerdasarkanStatusAktivasi())
          .thenAnswer((_) async => transaksiList);
      when(mockPelangganOpSqlite.ambilSemua())
          .thenAnswer((_) async => pelangganList);

      final result = await container.read(riwayatAktivasiPaketProvider.future);

      expect(result.items.length, 3);
      expect(result.sortBy, SortOption.endDate);
      // trx1 (25 hari lagi) > trx2 (20 hari lagi) > trx3 (hari ini)
      expect(result.items.map((e) => e.transaksi.id).toList(),
          ['trx2', 'trx1', 'trx3']);
    });

    test('02. changeSort should re-sort the list', () async {
      // Initial load
      when(mockTransaksiOpSqlite.ambilBerdasarkanStatusAktivasi())
          .thenAnswer((_) async => transaksiList);
      when(mockPelangganOpSqlite.ambilSemua())
          .thenAnswer((_) async => pelangganList);

      await container.read(riwayatAktivasiPaketProvider.future);

      // Change sort to Name A-Z
      container
          .read(riwayatAktivasiPaketProvider.notifier)
          .changeSort(SortOption.nameAZ);

      final newState = container.read(riwayatAktivasiPaketProvider).value!;
      expect(newState.sortBy, SortOption.nameAZ);
      // Alpha (trx2) < Beta (trx1) < Beta (trx3)
      expect(newState.items.map((e) => e.transaksi.id).toList(),
          ['trx2', 'trx1', 'trx3']);
    });
  });
}

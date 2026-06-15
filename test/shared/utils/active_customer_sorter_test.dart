// path: test/shared/utils/active_customer_sorter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/utils/active_customer_sorter.dart';

void main() {
  // Data referensi untuk pengujian
  final now = DateTime.now();

  final customer1 = DetailPelangganAktifModel(
    namaPelanggan: 'Charlie',
    namaPaket: 'Bulanan',
    pelangganAktif: PelangganAktifModel(
      id: '1',
      idPelanggan: 'c1',
      idPaket: 'p1',
      tanggalMulai: now.subtract(const Duration(days: 20)),
      tangglberakhir: now.add(const Duration(days: 10)), // Aktif, sisa 10 hari
      status: StatusPembayaran.paid,
      diperbaruiPada: now.subtract(const Duration(hours: 5)),
    ),
  );

  final customer2 = DetailPelangganAktifModel(
    namaPelanggan: 'Alice',
    namaPaket: 'Mingguan',
    pelangganAktif: PelangganAktifModel(
      id: '2',
      idPelanggan: 'c2',
      idPaket: 'p2',
      tanggalMulai: now.subtract(const Duration(days: 5)),
      tangglberakhir: now.add(const Duration(days: 2)), // Aktif, sisa 2 hari
      status: StatusPembayaran.unpaid, // Belum Lunas
      diperbaruiPada: now.subtract(const Duration(hours: 1)), // Paling baru
    ),
  );

  final customer3 = DetailPelangganAktifModel(
    namaPelanggan: 'Bob',
    namaPaket: 'Harian',
    pelangganAktif: PelangganAktifModel(
      id: '3',
      idPelanggan: 'c3',
      idPaket: 'p3',
      tanggalMulai: now.subtract(const Duration(days: 2)),
      tangglberakhir: now.subtract(const Duration(days: 1)), // Tidak Aktif
      status: StatusPembayaran.paid,
      diperbaruiPada: now.subtract(const Duration(hours: 10)),
    ),
  );

  final customer4 = DetailPelangganAktifModel(
    namaPelanggan: 'Zebra',
    namaPaket: 'Harian',
    pelangganAktif: PelangganAktifModel(
      id: '4',
      idPelanggan: 'c4',
      idPaket: 'p4',
      tanggalMulai: now.subtract(const Duration(days: 1)),
      tangglberakhir: now.add(const Duration(days: 20)), // Aktif, sisa 20 hari
      status: StatusPembayaran.unpaid, // Belum Lunas
      diperbaruiPada: now.subtract(const Duration(hours: 2)),
    ),
  );

  final List<DetailPelangganAktifModel> customers = [
    customer1, // Charlie, End: +10d, Start: -20d, Paid, Updated: -5h, Aktif
    customer2, // Alice,   End: +2d,  Start: -5d,  Unpaid, Updated: -1h, Aktif
    customer3, // Bob,     End: -1d,  Start: -2d,  Paid, Updated: -10h, Inaktif
    customer4, // Zebra,   End: +20d, Start: -1d,  Unpaid, Updated: -2h, Aktif
  ];

  group('ActiveCustomerSorter', () {
    test('harus mengurutkan berdasarkan nama A-Z (nameAZ)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.namaAZ);
      expect(sorted.map((c) => c.namaPelanggan).toList(),
          ['Alice', 'Bob', 'Charlie', 'Zebra']);
    });

    test('harus mengurutkan berdasarkan nama Z-A (nameZA)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.namaZA);
      expect(sorted.map((c) => c.namaPelanggan).toList(),
          ['Zebra', 'Charlie', 'Bob', 'Alice']);
    });

    test('harus mengurutkan berdasarkan tanggal berakhir terdekat (endDate)',
        () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.tanggalBerakhir);
      // Bob (-1d), Alice (+2d), Charlie (+10d), Zebra (+20d)
      expect(sorted.map((c) => c.pelangganAktif.id).toList(),
          ['3', '2', '1', '4']);
    });

    test('harus mengurutkan berdasarkan tanggal mulai terlama (startDate)', () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.tanggalMulai);
      // Charlie (-20d), Alice (-5d), Bob (-2d), Zebra (-1d)
      expect(sorted.map((c) => c.pelangganAktif.id).toList(),
          ['1', '2', '3', '4']);
    });

    test('harus mengurutkan berdasarkan pembaruan terakhir (lastUpdated)', () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.terakhirDiperbarui);
      // Alice (-1h), Zebra (-2h), Charlie (-5h), Bob (-10h)
      expect(sorted.map((c) => c.pelangganAktif.id).toList(),
          ['2', '4', '1', '3']);
    });

    test('harus mengurutkan dengan yang Lunas di atas (paid)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.lunas);
      // Paid: Bob, Charlie. Unpaid: Alice, Zebra.
      // Secondary sort: endDate. Bob(-1d), Charlie(+10d)
      // Alice(+2d), Zebra(+20d)
      final statuses = sorted.map((c) => c.pelangganAktif.status).toList();
      expect(statuses, [
        StatusPembayaran.paid,
        StatusPembayaran.paid,
        StatusPembayaran.unpaid,
        StatusPembayaran.unpaid
      ]);
      // Cek urutan sekunder (endDate)
      expect(sorted.map((c) => c.namaPelanggan).toList(),
          ['Bob', 'Charlie', 'Alice', 'Zebra']);
    });

    test('harus mengurutkan dengan yang Belum Lunas di atas (unpaid)', () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.belumLunas);
      // Unpaid: Alice, Zebra. Paid: Bob, Charlie.
      // Secondary sort: endDate. Alice(+2d), Zebra(+20d)
      // Bob(-1d), Charlie(+10d)
      final statuses = sorted.map((c) => c.pelangganAktif.status).toList();
      expect(statuses, [
        StatusPembayaran.unpaid,
        StatusPembayaran.unpaid,
        StatusPembayaran.paid,
        StatusPembayaran.paid
      ]);
      // Cek urutan sekunder (endDate)
      expect(sorted.map((c) => c.namaPelanggan).toList(),
          ['Alice', 'Zebra', 'Bob', 'Charlie']);
    });

    test('harus mengurutkan dengan paket Aktif di atas (activePackage)', () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.paketAktif);
      // Active: Alice, Charlie, Zebra. Inactive: Bob.
      // Secondary sort: endDate. Alice(+2d), Charlie(+10d), Zebra(+20d)
      final ids = sorted.map((c) => c.pelangganAktif.id).toList();
      expect(ids, ['2', '1', '4', '3']);
      // Pastikan Bob (inaktif) ada di paling akhir
      expect(sorted.last.namaPelanggan, 'Bob');
    });

    test('harus mengurutkan dengan paket Tidak Aktif di atas (inactivePackage)',
        () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.inactivePackage);
      // Inactive: Bob. Active: Alice, Charlie, Zebra.
      // Secondary sort: endDate. Alice(+2d), Charlie(+10d), Zebra(+20d)
      final ids = sorted.map((c) => c.pelangganAktif.id).toList();
      expect(ids, ['3', '2', '1', '4']);
      // Pastikan Bob (inaktif) ada di paling awal
      expect(sorted.first.namaPelanggan, 'Bob');
    });
  });
}

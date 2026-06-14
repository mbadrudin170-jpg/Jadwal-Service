// path: test/shared/utils/active_customer_sorter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/utils/active_customer_sorter.dart';

void main() {
  // Data referensi untuk pengujian
  final now = DateTime.now();

  final customer1 = DetailPelangganAktifModel(
    customerName: 'Charlie',
    packageName: 'Bulanan',
    pelangganAktif: PelangganAktifModel(
      id: '1',
      idPelanggan: 'c1',
      packageId: 'p1',
      startDate: now.subtract(const Duration(days: 20)),
      endDate: now.add(const Duration(days: 10)), // Aktif, sisa 10 hari
      status: PaymentStatus.paid,
      updatedAt: now.subtract(const Duration(hours: 5)),
    ),
  );

  final customer2 = DetailPelangganAktifModel(
    customerName: 'Alice',
    packageName: 'Mingguan',
    pelangganAktif: PelangganAktifModel(
      id: '2',
      idPelanggan: 'c2',
      packageId: 'p2',
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 2)), // Aktif, sisa 2 hari
      status: PaymentStatus.unpaid, // Belum Lunas
      updatedAt: now.subtract(const Duration(hours: 1)), // Paling baru
    ),
  );

  final customer3 = DetailPelangganAktifModel(
    customerName: 'Bob',
    packageName: 'Harian',
    pelangganAktif: PelangganAktifModel(
      id: '3',
      idPelanggan: 'c3',
      packageId: 'p3',
      startDate: now.subtract(const Duration(days: 2)),
      endDate: now.subtract(const Duration(days: 1)), // Tidak Aktif
      status: PaymentStatus.paid,
      updatedAt: now.subtract(const Duration(hours: 10)),
    ),
  );

  final customer4 = DetailPelangganAktifModel(
    customerName: 'Zebra',
    packageName: 'Harian',
    pelangganAktif: PelangganAktifModel(
      id: '4',
      idPelanggan: 'c4',
      packageId: 'p4',
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 20)), // Aktif, sisa 20 hari
      status: PaymentStatus.unpaid, // Belum Lunas
      updatedAt: now.subtract(const Duration(hours: 2)),
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
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.nameAZ);
      expect(sorted.map((c) => c.customerName).toList(),
          ['Alice', 'Bob', 'Charlie', 'Zebra']);
    });

    test('harus mengurutkan berdasarkan nama Z-A (nameZA)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.nameZA);
      expect(sorted.map((c) => c.customerName).toList(),
          ['Zebra', 'Charlie', 'Bob', 'Alice']);
    });

    test('harus mengurutkan berdasarkan tanggal berakhir terdekat (endDate)',
        () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.endDate);
      // Bob (-1d), Alice (+2d), Charlie (+10d), Zebra (+20d)
      expect(sorted.map((c) => c.pelangganAktif.id).toList(),
          ['3', '2', '1', '4']);
    });

    test('harus mengurutkan berdasarkan tanggal mulai terlama (startDate)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.startDate);
      // Charlie (-20d), Alice (-5d), Bob (-2d), Zebra (-1d)
      expect(sorted.map((c) => c.pelangganAktif.id).toList(),
          ['1', '2', '3', '4']);
    });

    test('harus mengurutkan berdasarkan pembaruan terakhir (lastUpdated)', () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.lastUpdated);
      // Alice (-1h), Zebra (-2h), Charlie (-5h), Bob (-10h)
      expect(sorted.map((c) => c.pelangganAktif.id).toList(),
          ['2', '4', '1', '3']);
    });

    test('harus mengurutkan dengan yang Lunas di atas (paid)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.paid);
      // Paid: Bob, Charlie. Unpaid: Alice, Zebra.
      // Secondary sort: endDate. Bob(-1d), Charlie(+10d)
      // Alice(+2d), Zebra(+20d)
      final statuses = sorted.map((c) => c.pelangganAktif.status).toList();
      expect(statuses, [
        PaymentStatus.paid,
        PaymentStatus.paid,
        PaymentStatus.unpaid,
        PaymentStatus.unpaid
      ]);
      // Cek urutan sekunder (endDate)
      expect(sorted.map((c) => c.customerName).toList(),
          ['Bob', 'Charlie', 'Alice', 'Zebra']);
    });

    test('harus mengurutkan dengan yang Belum Lunas di atas (unpaid)', () {
      final sorted = ActiveCustomerSorter.sort(customers, SortOption.unpaid);
      // Unpaid: Alice, Zebra. Paid: Bob, Charlie.
      // Secondary sort: endDate. Alice(+2d), Zebra(+20d)
      // Bob(-1d), Charlie(+10d)
      final statuses = sorted.map((c) => c.pelangganAktif.status).toList();
      expect(statuses, [
        PaymentStatus.unpaid,
        PaymentStatus.unpaid,
        PaymentStatus.paid,
        PaymentStatus.paid
      ]);
      // Cek urutan sekunder (endDate)
      expect(sorted.map((c) => c.customerName).toList(),
          ['Alice', 'Zebra', 'Bob', 'Charlie']);
    });

    test('harus mengurutkan dengan paket Aktif di atas (activePackage)', () {
      final sorted =
          ActiveCustomerSorter.sort(customers, SortOption.activePackage);
      // Active: Alice, Charlie, Zebra. Inactive: Bob.
      // Secondary sort: endDate. Alice(+2d), Charlie(+10d), Zebra(+20d)
      final ids = sorted.map((c) => c.pelangganAktif.id).toList();
      expect(ids, ['2', '1', '4', '3']);
      // Pastikan Bob (inaktif) ada di paling akhir
      expect(sorted.last.customerName, 'Bob');
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
      expect(sorted.first.customerName, 'Bob');
    });
  });
}

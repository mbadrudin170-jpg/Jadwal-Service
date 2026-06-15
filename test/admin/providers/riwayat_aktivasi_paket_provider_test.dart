// path: test/admin/providers/riwayat_aktivasi_paket_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/providers/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

// 1. Buat mock class menggunakan mocktail
class MockTransaksiOpsqlite extends Mock implements TransaksiOpsqlite {}

class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

void main() {
  // 2. Definisikan data dummy yang valid
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, now.hour, now.minute);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  // Customer dummies
  final c1 = PelangganModel(
    id: 'c1',
    name: 'Charlie',
    phone: '',
    address: '',
    password: '',
    registrationDate: now,
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: now,
  );
  final c2 = PelangganModel(
    id: 'c2',
    name: 'Alpha',
    phone: '',
    address: '',
    password: '',
    registrationDate: now,
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: now,
  );
  final c3 = PelangganModel(
    id: 'c3',
    name: 'Bravo',
    phone: '',
    address: '',
    password: '',
    registrationDate: now,
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: now,
  );

  // Transaction dummies
  final t1 = TransaksiModel(
    id: '1',
    idPelanggan: 'c1',
    tanggal: yesterday,
    tangglberakhir: today,
    statusPembayaran: StatusPembayaran.paid,
    deskripsi: '',
    jumlah: 0,
    tipe: TipeTransaksi.income,
    idDompet: '',
    idKategori: '',
  );
  final t2 = TransaksiModel(
      id: '2',
      idPelanggan: 'c2',
      tanggal: today,
      tangglberakhir: tomorrow,
      deskripsi: '',
      jumlah: 0,
      tipe: TipeTransaksi.income,
      idDompet: '',
      idKategori: '');
  final t3 = TransaksiModel(
    id: '3',
    idPelanggan: 'c3',
    tanggal: yesterday.subtract(const Duration(days: 1)),
    tangglberakhir: yesterday,
    statusPembayaran: StatusPembayaran.paid,
    deskripsi: '',
    jumlah: 0,
    tipe: TipeTransaksi.income,
    idDompet: '',
    idKategori: '',
  );
  // Transaksi tanpa customerId yang cocok untuk menguji kasus 'Tidak diketahui'
  final t4 = TransaksiModel(
    id: '4',
    idPelanggan: 'c4-nonexistent',
    tanggal: today.subtract(const Duration(days: 2)),
    deskripsi: '',
    jumlah: 0,
    tipe: TipeTransaksi.income,
    idDompet: '',
    idKategori: '',
    // Waktu sama, menit berbeda
  );

  final mockTransactions = [t1, t2, t3, t4];
  final mockCustomers = [c1, c2, c3];

  // 3. Buat mock untuk semua dependensi
  late MockTransaksiOpsqlite mockTransaksiOpsqlite;
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late ProviderContainer container;

  // 4. Atur setup untuk setiap test
  setUp(() {
    mockTransaksiOpsqlite = MockTransaksiOpsqlite();
    mockPelangganOpSqlite = MockPelangganOpSqlite();

    container = ProviderContainer(
      overrides: [
        // Gunakan provider yang benar dari operasi_sqlite_provider.dart
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpsqlite),
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOpSqlite),
      ],
    );

    // Atur mock untuk mengembalikan data dummy menggunakan syntax mocktail
    when(() => mockTransaksiOpsqlite.ambilTransaksiAktivasiPaket())
        .thenAnswer((_) async => List.from(mockTransactions));
    when(() => mockPelangganOpSqlite.ambilSemuaPelanggan())
        .thenAnswer((_) async => List.from(mockCustomers));
  });

  tearDown(() {
    container.dispose();
  });

  group('PackageActivationHistory Provider Sorting Tests', () {
    test('01. endDate harus mengurutkan list berdasarkan endDate descending',
        () async {
      // Tunggu provider untuk inisialisasi
      final state = await container.read(riwayatAktivasiPaketProvider.future);

      // Verifikasi urutan default adalah berdasarkan endDate descending (null di akhir)
      expect(state.items.map((item) => item.transaksi.id).toList(),
          ['2', '1', '3', '4']);
      expect(state.sortBy, SortOption.endDate);
    });

    test('02. nameAZ harus mengurutkan list berdasarkan nama A-Z', () async {
      // Inisialisasi dulu
      await container.read(riwayatAktivasiPaketProvider.future);

      // Panggil changeSort
      container
          .read(riwayatAktivasiPaketProvider.notifier)
          .changeSort(SortOption.nameAZ);

      final state = container.read(riwayatAktivasiPaketProvider).value!;

      // Verifikasi urutan berdasarkan nama A-Z, customer tidak diketahui paling akhir
      expect(state.items.map((item) => item.customerName).toList(),
          ['Alpha', 'Bravo', 'Charlie', 'Tidak diketahui']);
      expect(state.sortBy, SortOption.nameAZ);
    });

    test('03. namaZA harus mengurutkan list berdasarkan nama Z-A', () async {
      await container.read(riwayatAktivasiPaketProvider.future);
      container
          .read(riwayatAktivasiPaketProvider.notifier)
          .changeSort(SortOption.nameZA);

      final state = container.read(riwayatAktivasiPaketProvider).value!;

      // Verifikasi urutan berdasarkan nama Z-A
      expect(state.items.map((item) => item.customerName).toList(),
          ['Tidak diketahui', 'Charlie', 'Bravo', 'Alpha']);
      expect(state.sortBy, SortOption.nameZA);
    });

    // test(
    //     '04. newest harus mengurutkan list updateAt yang terbaru ke yang terlama',
    //     () async {
    //   await container.read(riwayatAktivasiPaketProvider.future);
    //   container
    //       .read(riwayatAktivasiPaketProvider.notifier)
    //       .changeSort(SortOption.updatedAtAZ);

    //   final state = container.read(riwayatAktivasiPaketProvider).value!;

    //   // Verifikasi urutan berdasarkan tanggal terbaru: t2, t4, t1, t3
    //   expect(state.items.map((item) => item.transaksi.id).toList(),
    //       ['2', '4', '1', '3']);
    //   expect(state.sortBy, SortOption.updatedAtAZ);
    // });

    // test(
    //     '05. oldest harus mengurutkan list updateAt yang terlama ke yang terbaru',
    //     () async {
    //   await container.read(riwayatAktivasiPaketProvider.future);
    //   container
    //       .read(riwayatAktivasiPaketProvider.notifier)
    //       .changeSort(SortOption.updatedAtZA);

    //   final state = container.read(riwayatAktivasiPaketProvider).value!;

    //   // Verifikasi urutan berdasarkan tanggal terlama: t3, t1, t4, t2
    //   expect(state.items.map((item) => item.transaksi.id).toList(),
    //       ['3', '1', '4', '2']);
    //   expect(state.sortBy, SortOption.updatedAtZA);
    // });

    test(
        '06. endingToday harus mengurutkan list yang berakhir hari ini ke paling lama',
        () async {
      await container.read(riwayatAktivasiPaketProvider.future);
      container
          .read(riwayatAktivasiPaketProvider.notifier)
          .changeSort(SortOption.endingToday);

      final state = container.read(riwayatAktivasiPaketProvider).value!;

      // Verifikasi: t1 (berakhir hari ini) harus di paling atas
      expect(state.items.first.transaksi.id, '1');
      expect(state.sortBy, SortOption.endingToday);
    });

    test('07. paid harus mengurutkan list dari yang lunas ke yang belum lunas',
        () async {
      await container.read(riwayatAktivasiPaketProvider.future);
      container
          .read(riwayatAktivasiPaketProvider.notifier)
          .changeSort(SortOption.paid);

      final state = container.read(riwayatAktivasiPaketProvider).value!;

      // Verifikasi: yang lunas (t1, t3) di atas, diurutkan berdasarkan tanggal terbaru
      final ids = state.items.map((item) => item.transaksi.id).toList();
      expect(ids, ['1', '3', '2', '4']);
      expect(state.items[0].transaksi.statusPembayaran, StatusPembayaran.paid);
      expect(state.items[1].transaksi.statusPembayaran, StatusPembayaran.paid);
      expect(state.sortBy, SortOption.paid);
    });

    test(
        '08. unpaid harus mengurutkan list dari yang belum lunas ke yang lunas',
        () async {
      await container.read(riwayatAktivasiPaketProvider.future);
      container
          .read(riwayatAktivasiPaketProvider.notifier)
          .changeSort(SortOption.unpaid);

      final state = container.read(riwayatAktivasiPaketProvider).value!;

      // Verifikasi: yang belum lunas (t2, t4) di atas, diurutkan berdasarkan tanggal terbaru
      final ids = state.items.map((item) => item.transaksi.id).toList();
      expect(ids, ['2', '4', '1', '3']);
      expect(
          state.items[0].transaksi.statusPembayaran, StatusPembayaran.unpaid);
      expect(
          state.items[1].transaksi.statusPembayaran, StatusPembayaran.unpaid);
      expect(state.items[2].transaksi.statusPembayaran, StatusPembayaran.paid);
      expect(state.items[3].transaksi.statusPembayaran, StatusPembayaran.paid);

      expect(state.sortBy, SortOption.unpaid);
    });
  });
}

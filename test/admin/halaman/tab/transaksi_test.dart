// path: test/admin/halaman/tab/transaksi_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/tab/transaksi.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';

import 'transaksi_test.mocks.dart';

// Menghasilkan mock untuk TransaksiOperasi
@GenerateMocks([TransaksiOperasi])
void main() {
  // Deklarasi variabel mock
  late MockTransaksiOperasi mockTransaksiOperasi;

  // Inisialisasi data lokal untuk format tanggal sebelum semua tes berjalan.
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  // Inisialisasi mock sebelum setiap tes
  setUp(() {
    mockTransaksiOperasi = MockTransaksiOperasi();
  });

  // Fungsi helper untuk membuat widget yang akan diuji
  Widget createTestableWidget() {
    return MaterialApp(
      home: ScaffoldMessenger(
        child: TransaksiPage(transaksiOperasi: mockTransaksiOperasi),
      ),
    );
  }

  // Data transaksi dummy untuk pengujian
  final List<TransaksiModel> dummyTransaksiList = [
    TransaksiModel(
      id: '1',
      keterangan: 'Gaji Bulan Mei',
      jumlah: 5000000,
      tipe: TipeTransaksi.pemasukan,
      tanggal: DateTime(2024, 5, 25),
      idDompet: 'dompet1',
      idKategori: 'gaji',
    ),
    TransaksiModel(
      id: '2',
      keterangan: 'Bayar Listrik',
      jumlah: 350000,
      tipe: TipeTransaksi.pengeluaran,
      tanggal: DateTime(2024, 5, 26),
      idDompet: 'dompet1',
      idKategori: 'tagihan',
    ),
  ];

  // Fungsi helper untuk mock pemanggilan data
  void mockGetData({
    final List<TransaksiModel> transaksi = const [],
    final double pemasukan = 0.0,
    final double pengeluaran = 0.0,
    final double total = 0.0,
  }) {
    when(mockTransaksiOperasi.ambilSemuaTransaksi())
        .thenAnswer((final _) async => transaksi);
    when(mockTransaksiOperasi.getTotalPemasukan())
        .thenAnswer((final _) async => pemasukan);
    when(mockTransaksiOperasi.getTotalPengeluaran())
        .thenAnswer((final _) async => pengeluaran);
    when(mockTransaksiOperasi.getNetTotal())
        .thenAnswer((final _) async => total);
  }

  // Fungsi helper untuk mock kegagalan
  void mockGetDataFailure(final Exception error) {
    when(mockTransaksiOperasi.ambilSemuaTransaksi()).thenThrow(error);
    when(mockTransaksiOperasi.getTotalPemasukan()).thenThrow(error);
    when(mockTransaksiOperasi.getTotalPengeluaran()).thenThrow(error);
    when(mockTransaksiOperasi.getNetTotal()).thenThrow(error);
  }

  group('Render Awal', () {
    testWidgets('1. Harus menampilkan data saat berhasil dimuat',
        (final tester) async {
      mockGetData(
        transaksi: dummyTransaksiList,
        pemasukan: 5000000,
        pengeluaran: 350000,
        total: 4650000,
      );
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RingkasanTransaksi), findsOneWidget);
      expect(find.text('Gaji Bulan Mei'), findsOneWidget);
      expect(find.text('Bayar Listrik'), findsOneWidget);
    });

    testWidgets('2. Harus menampilkan pesan saat tidak ada transaksi',
        (final tester) async {
      mockGetData(); // Default empty
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada transaksi ditemukan.'), findsOneWidget);
    });

    testWidgets('3. Harus menampilkan pesan error ketika Future gagal',
        (final tester) async {
      final exception = Exception('Database Error');
      mockGetDataFailure(exception);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Terjadi Kesalahan: $exception'), findsOneWidget);
    });
  });

  group('Aksi Hapus Semua', () {
    testWidgets('4. Harus menghapus semua transaksi setelah konfirmasi',
        (final tester) async {
      // 1. Atur keadaan awal
      mockGetData(
        transaksi: dummyTransaksiList,
      );
      when(mockTransaksiOperasi.hapusSemuaTransaksi())
          .thenAnswer((final _) async {});

      // 2. Bangun UI awal dan verifikasi
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      expect(find.text('Gaji Bulan Mei'), findsOneWidget);

      // 3. Buka dialog
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      // 4. SIAPKAN MOCK UNTUK KEADAAN SETELAH AKSI
      //    Ini akan dipanggil oleh FutureBuilder setelah setState dipicu oleh hapus.
      mockGetData(); // Atur agar pemanggilan selanjutnya mengembalikan list kosong.

      // 5. Picu aksi hapus dan biarkan UI menyelesaikan semua proses
      await tester.tap(find.text('Hapus'));
      await tester
          .pumpAndSettle(); // Selesaikan hapus, SnackBar, dan rebuild FutureBuilder

      // 6. Verifikasi keadaan akhir
      expect(find.text('Semua transaksi berhasil dihapus.'), findsOneWidget);
      expect(find.text('Tidak ada transaksi ditemukan.'), findsOneWidget);
      expect(find.text('Gaji Bulan Mei'), findsNothing);
    });

    testWidgets('5. Tidak boleh menghapus jika dialog dibatalkan',
        (final tester) async {
      mockGetData(transaksi: dummyTransaksiList);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      verifyNever(mockTransaksiOperasi.hapusSemuaTransaksi());
      expect(find.text('Gaji Bulan Mei'), findsOneWidget);
    });
  });
}

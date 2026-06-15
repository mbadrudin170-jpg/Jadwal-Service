// path: test/admin/halaman/lainnya/riwayat_aktivasi_paket_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/riwayat_aktivasi/page/detail_riwayat_aktivasi.dart';
import 'package:wifi/admin/halaman/lainnya/riwayat_aktivasi_paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

class MockTransaksiOpsqlite extends Mock implements TransaksiOpsqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

void main() {
  late MockTransaksiOpsqlite mockTransactionOp;
  late MockPaketOpSqlite mockPackageOp;
  late MockPelangganOpSqlite mockCustomerOp;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    mockTransactionOp = MockTransaksiOpsqlite();
    mockPackageOp = MockPaketOpSqlite();
    mockCustomerOp = MockPelangganOpSqlite();
  });

  final t1 = TransaksiModel(
    id: 't1',
    idPelanggan: 'c1',
    idPaket: 'p1',
    tanggal: DateTime(2023, 1, 1),
    tanggalMulai: DateTime(2023, 1, 1),
    tangglberakhir: DateTime(2023, 2, 1),
    jumlah: 50000,
    tipe: TipeTransaksi.income,
    idDompet: 'w1',
    statusPembayaran: StatusPembayaran.paid,
    idKategori: 'cat1',
    deskripsi: 'Pembayaran Paket',
  );

  final c1 = PelangganModel(
    id: 'c1',
    name: 'Budi Utomo',
    phone: '08123',
    address: 'Alamat',
    password: 'pwd',
    registrationDate: DateTime.now(),
    fcmToken: '',
    appVersion: '',
    platform: '',
    lastActive: DateTime.now(),
  );

  final p1 = PaketModel(
    id: 'p1',
    nama: 'Paket Bulanan',
    harga: 50000,
    durasi: 30,
    durationType: TipeDurasiPaket.days,
    statusPublik: true,
    poinHadiah: 10,
  );

  Widget buatWidgetTes() {
    return ProviderScope(
      overrides: [
        transaksiOpSqliteProvider.overrideWithValue(mockTransactionOp),
        paketOpSqliteProvider.overrideWithValue(mockPackageOp),
        pelangganOpSqliteProvider.overrideWithValue(mockCustomerOp),
      ],
      child: const MaterialApp(
        home: RiwayatAktivasiPaket(),
      ),
    );
  }

  testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat memuat data',
      (tester) async {
    when(() => mockTransactionOp.ambilTransaksiAktivasiPaket())
        .thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return [];
    });
    when(() => mockCustomerOp.ambilSemuaPelanggan())
        .thenAnswer((_) async => []);

    await tester.pumpWidget(buatWidgetTes());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('02. harus menampilkan pesan error jika gagal memuat data',
      (tester) async {
    when(() => mockTransactionOp.ambilTransaksiAktivasiPaket())
        .thenThrow(Exception('Gagal memuat'));
    when(() => mockCustomerOp.ambilSemuaPelanggan())
        .thenAnswer((_) async => []);

    await tester.pumpWidget(buatWidgetTes());
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Error: Exception: Gagal memuat'), findsOneWidget);
  });

  testWidgets(
      '03. harus menampilkan pesan jika tidak ada data riwayat langganan',
      (tester) async {
    when(() => mockTransactionOp.ambilTransaksiAktivasiPaket())
        .thenAnswer((_) async => []);
    when(() => mockCustomerOp.ambilSemuaPelanggan())
        .thenAnswer((_) async => []);

    await tester.pumpWidget(buatWidgetTes());
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada riwayat langganan ditemukan.'), findsOneWidget);
  });

  testWidgets('04. harus menampilkan daftar riwayat langganan dengan benar',
      (tester) async {
    when(() => mockTransactionOp.ambilTransaksiAktivasiPaket())
        .thenAnswer((_) async => [t1]);
    when(() => mockCustomerOp.ambilSemuaPelanggan())
        .thenAnswer((_) async => [c1]);
    when(() => mockPackageOp.ambilBerdasarkanId('p1'))
        .thenAnswer((_) async => p1);

    await tester.pumpWidget(buatWidgetTes());
    await tester.pumpAndSettle();

    expect(find.text('Budi Utomo'), findsOneWidget);
    expect(find.text('Status: Lunas'), findsOneWidget);
    expect(
        find.textContaining('Aktif: 1 Jan 2023 - 1 Feb 2023'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets(
      '05. harus navigasi ke DetailRiwayatAktivasi saat ListTile di-tap',
      (tester) async {
    when(() => mockTransactionOp.ambilTransaksiAktivasiPaket())
        .thenAnswer((_) async => [t1]);
    when(() => mockCustomerOp.ambilSemuaPelanggan())
        .thenAnswer((_) async => [c1]);
    when(() => mockPackageOp.ambilBerdasarkanId('p1'))
        .thenAnswer((_) async => p1);

    await tester.pumpWidget(buatWidgetTes());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.byType(DetailRiwayatAktivasi), findsOneWidget);
  });

  testWidgets('06. harus menampilkan dialog urutan saat tombol filter ditekan',
      (tester) async {
    when(() => mockTransactionOp.ambilTransaksiAktivasiPaket())
        .thenAnswer((_) async => [t1]);
    when(() => mockCustomerOp.ambilSemuaPelanggan())
        .thenAnswer((_) async => [c1]);
    when(() => mockPackageOp.ambilBerdasarkanId('p1'))
        .thenAnswer((_) async => p1);

    await tester.pumpWidget(buatWidgetTes());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(TIcons.filter));
    await tester.pumpAndSettle();

    expect(find.text('Urutkan Berdasarkan'), findsOneWidget);
    expect(find.text('Nama A-Z'), findsOneWidget);
    expect(find.text('Tanggal Berakhir'), findsOneWidget);
  });
}

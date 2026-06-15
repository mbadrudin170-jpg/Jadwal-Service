
// path: test/fitur/transaksi/page/form_transaksi_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

// Mocks
class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}
class MockKategoriOpSqlite extends Mock implements KategoriOpSqlite {}
class MockTransaksiOpSqlite extends Mock implements TransaksiOpsqlite {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}
class MockLayananCekSinkronisasi extends Mock implements LayananCekSinkronisasi {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Data Mocks
  final dompet1 = DompetModel(id: 'd1', nama: 'Dompet A', saldo: 100000);
  final dompet2 = DompetModel(id: 'd2', nama: 'Dompet B', saldo: 50000);
  final kategoriPemasukan = KategoriModel(id: 'kp1', nama: 'Gaji', tipe: TipeKategori.income);
  final kategoriPengeluaran = KategoriModel(id: 'kl1', nama: 'Makan', tipe: TipeKategori.expense);
  final mockTransaksi = TransaksiModel(
      id: 't1', 
      deskripsi: 'Makan Siang', 
      jumlah: 50000, 
      tanggal: DateTime.now(),
      idDompet: 'd1', 
      idKategori: 'kl1');

  late MockDompetOpSqlite mockDompetOp;
  late MockKategoriOpSqlite mockKategoriOp;
  late MockTransaksiOpSqlite mockTransaksiOp;
  late MockKoneksiInternetService mockKoneksiService;
  late MockLayananCekSinkronisasi mockSinkronisasiService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockDompetOp = MockDompetOpSqlite();
    mockKategoriOp = MockKategoriOpSqlite();
    mockTransaksiOp = MockTransaksiOpSqlite();
    mockKoneksiService = MockKoneksiInternetService();
    mockSinkronisasiService = MockLayananCekSinkronisasi();
    mockNavigatorObserver = MockNavigatorObserver();

    // Default behaviors
    when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => [dompet1, dompet2]);
    when(() => mockKategoriOp.ambilSemua()).thenAnswer((_) async => [kategoriPemasukan, kategoriPengeluaran]);
    when(() => mockTransaksiOp.tambahTransaksi(any())).thenAnswer((_) async => 1);
    when(() => mockTransaksiOp.updateTransaction(any(), any())).thenAnswer((_) async => 1);
    when(() => mockKoneksiService.cekKoneksiLokal()).thenAnswer((_) async => true);
    when(() => mockSinkronisasiService.jalankanCekSinkronisasi()).thenAnswer((_) async {});

    registerFallbackValue(const TransaksiModel(id: '', deskripsi: '', jumlah: 0, tanggal: null, idDompet: ''));
  });

  Widget createWidgetUnderTest({TransaksiModel? transaksi}) {
    return ProviderScope(
      overrides: [
        dompetOpSqliteProvider.overrideWithValue(mockDompetOp),
        kategoriOpSqliteProvider.overrideWithValue(mockKategoriOp),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOp),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiService),
        layananCekSinkronisasiProvider.overrideWithValue(mockSinkronisasiService),
      ],
      child: MaterialApp(
        home: FormTransaksi(transaksi: transaksi),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Inisialisasi & Rendering', () {
    testWidgets('01. Mode Tambah: Harus merender judul "Tambah Transaksi" dan form kosong', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Tambah Transaksi'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('02. Mode Edit: Harus merender judul "Edit Transaksi" dan mengisi form', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(transaksi: mockTransaksi));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Edit Transaksi'), findsOneWidget);
      expect(find.text('Makan Siang'), findsOneWidget);
      expect(find.text('50000'), findsOneWidget);
      expect(find.text('Dompet A'), findsOneWidget);
      expect(find.text('Makan'), findsOneWidget);
    });

    testWidgets('03. Harus menampilkan CircularProgressIndicator saat loading data', (tester) async {
      when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return [dompet1];
      });

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('04. Harus menampilkan pesan error jika gagal memuat data awal', (tester) async {
      when(() => mockDompetOp.ambilSemua()).thenThrow(Exception('Database error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat data penting'), findsOneWidget);
    });
  });

  group('Interaksi Form & Validasi', () {
    testWidgets('06. Harus menampilkan pesan error validasi jika field wajib kosong', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Keterangan tidak boleh kosong'), findsOneWidget);
      expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);
      expect(find.text('Dompet harus dipilih'), findsOneWidget);
    });

    testWidgets('07. Harus menampilkan dropdown Dompet Tujuan saat tipe Transfer dipilih', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Dompet Tujuan'), findsNothing);

      await tester.tap(find.text('TRANSFER'));
      await tester.pumpAndSettle();

      expect(find.text('Dompet Tujuan'), findsOneWidget);
    });

     testWidgets('08. Transfer: Harus error jika dompet tujuan sama dengan dompet asal', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('TRANSFER'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keterangan').first);
      await tester.enterText(find.byType(TextFormField).first, 'Transfer Gaji');
      await tester.enterText(find.byType(TextFormField).last, '50000');

      // Pilih dompet asal
      await tester.tap(find.text('Dompet').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet A').last);
      await tester.pumpAndSettle();
      
      // Pilih dompet tujuan yang sama
      await tester.tap(find.text('Dompet Tujuan').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet A').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Dompet tidak boleh sama'), findsOneWidget);
    });

    testWidgets('09. Harus memfilter kategori saat tipe transaksi diubah', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Awalnya Pemasukan, Gaji harus ada
      await tester.tap(find.text('Kategori').last);
      await tester.pumpAndSettle();
      expect(find.text('Gaji'), findsOneWidget);
      expect(find.text('Makan'), findsNothing);
      await tester.tap(find.text('Gaji').last); // close dropdown
      await tester.pumpAndSettle();

      // Ubah ke Pengeluaran
      await tester.tap(find.text('EXPENSE'));
      await tester.pumpAndSettle();

      // Sekarang Makan harus ada
      await tester.tap(find.text('Kategori').last);
      await tester.pumpAndSettle();
      expect(find.text('Gaji'), findsNothing);
      expect(find.text('Makan'), findsOneWidget);
    });
  });

  group('Proses Penyimpanan', () {
    testWidgets('11. Mode Tambah: Harus berhasil simpan & sinkronisasi saat online', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Gaji Bulanan');
      await tester.enterText(find.byType(TextFormField).last, '5000000');
      await tester.tap(find.text('Dompet').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet A').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() => mockTransaksiOp.tambahTransaksi(any())).called(1);
      verify(() => mockKoneksiService.cekKoneksiLokal()).called(1);
      verify(() => mockSinkronisasiService.jalankanCekSinkronisasi()).called(1);
      expect(find.text('Transaksi berhasil disimpan dan disinkronkan.'), findsOneWidget);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('12. Mode Tambah: Harus berhasil simpan lokal saat offline', (tester) async {
      when(() => mockKoneksiService.cekKoneksiLokal()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Gaji Bulanan');
      await tester.enterText(find.byType(TextFormField).last, '5000000');
      await tester.tap(find.text('Dompet').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet A').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() => mockTransaksiOp.tambahTransaksi(any())).called(1);
      verifyNever(() => mockSinkronisasiService.jalankanCekSinkronisasi());
      expect(find.text('Transaksi disimpan lokal. Sinkronisasi akan dilakukan saat online.'), findsOneWidget);
    });

    testWidgets('13. Mode Edit: Harus berhasil memperbarui transaksi', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(transaksi: mockTransaksi));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Makan Malam');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() => mockTransaksiOp.updateTransaction(mockTransaksi.id, any(that: isA<TransaksiModel>()..having((t) => t.deskripsi, 'deskripsi', 'Makan Malam')))).called(1);
    });

    testWidgets('14. Harus menampilkan toast error jika penyimpanan gagal', (tester) async {
      when(() => mockTransaksiOp.tambahTransaksi(any())).thenThrow(Exception('DB write error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Gaji Bulanan');
      await tester.enterText(find.byType(TextFormField).last, '5000000');
      await tester.tap(find.text('Dompet').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet A').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal menyimpan transaksi'), findsOneWidget);
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });
  });
}

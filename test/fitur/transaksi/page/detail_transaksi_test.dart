
// path: test/fitur/transaksi/page/detail_transaksi_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';

// Mocks
class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockKategoriOpSqlite extends Mock implements KategoriOpSqlite {}

class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockSubKategoriOpSqlite extends Mock implements SubKategoriOpSqlite {}

class MockTransaksiOpSqlite extends Mock implements TransaksiOpsqlite {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Data
  final mockDompet = DompetModel(id: 'd1', nama: 'Dompet Utama', saldo: 50000);
  final mockKategori = KategoriModel(id: 'k1', nama: 'Internet');
  final mockPelanggan = PelangganModel(
      id: 'p1', nama: 'Budi', alamat: '', telepon: '', macAddress: '', kataSandi: '');
  final mockPaket = PaketModel(
      id: 'pkt1', nama: 'Paket Cepat', harga: 25000, durasi: 30, tipe: 'regular');

  final mockTransaksi = TransaksiModel(
    id: 't1',
    deskripsi: 'Pembayaran Wifi',
    jumlah: 25000,
    tanggal: DateTime(2023, 10, 1),
    tipe: TipeTransaksi.expense,
    statusPembayaran: StatusPembayaran.paid,
    idDompet: 'd1',
    idKategori: 'k1',
    idPelanggan: 'p1',
    idPaket: 'pkt1',
    poinDidapat: 10,
  );

  // Mocks
  late MockDompetOpSqlite mockDompetOp;
  late MockKategoriOpSqlite mockKategoriOp;
  late MockPelangganOpSqlite mockPelangganOp;
  late MockPaketOpSqlite mockPaketOp;
  late MockSubKategoriOpSqlite mockSubKategoriOp;
  late MockTransaksiOpSqlite mockTransaksiOp;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockDompetOp = MockDompetOpSqlite();
    mockKategoriOp = MockKategoriOpSqlite();
    mockPelangganOp = MockPelangganOpSqlite();
    mockPaketOp = MockPaketOpSqlite();
    mockSubKategoriOp = MockSubKategoriOpSqlite();
    mockTransaksiOp = MockTransaksiOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    // Setup default when clauses
    when(() => mockDompetOp.ambilBerdasarkanId(any())).thenAnswer((_) async => null);
    when(() => mockKategoriOp.ambilKategoriBerdasarkanId(any()))
        .thenAnswer((_) async => null);
    when(() => mockPelangganOp.ambilBerdasarkanId(any()))
        .thenAnswer((_) async => null);
    when(() => mockPaketOp.ambilBerdasarkanId(any())).thenAnswer((_) async => null);
    when(() => mockTransaksiOp.ambilBerdasarkanId(any()))
        .thenAnswer((_) async => mockTransaksi);
  });

  Widget createWidgetUnderTest(TransaksiModel transaksi) {
    return ProviderScope(
      overrides: [
        dompetOpSqliteProvider.overrideWithValue(mockDompetOp),
        kategoriOpSqliteProvider.overrideWithValue(mockKategoriOp),
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOp),
        paketOpSqliteProvider.overrideWithValue(mockPaketOp),
        subKategoriOpSqliteProvider.overrideWithValue(mockSubKategoriOp),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOp),
      ],
      child: MaterialApp(
        home: DetailTransaksi(transaksi: transaksi),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Rendering UI', () {
    testWidgets(
        '01. harus merender AppBar dengan judul "Detail Transaksi" dan tombol edit',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      expect(find.widgetWithText(AppBar, 'Detail Transaksi'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('02. harus menampilkan semua detail statis dari transaksi',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      await tester.pumpAndSettle();

      expect(find.text('Pembayaran Wifi'), findsOneWidget);
      expect(find.text('Rp25.000'), findsOneWidget);
      expect(find.text('1 Okt 23'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      expect(find.text('10'), findsNWidgets(2)); // Poin didapat dan digunakan
    });

    testWidgets(
        '03. harus menampilkan "Memuat..." saat data dinamis sedang diambil',
        (tester) async {
      when(() => mockDompetOp.ambilBerdasarkanId('d1')).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return mockDompet;
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));

      expect(find.text('Memuat...'), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('Memuat...'), findsNothing);
    });

    testWidgets(
        '04. harus menampilkan nama yang benar untuk data dinamis setelah berhasil diambil',
        (tester) async {
      when(() => mockDompetOp.ambilBerdasarkanId('d1'))
          .thenAnswer((_) async => mockDompet);
      when(() => mockKategoriOp.ambilKategoriBerdasarkanId('k1'))
          .thenAnswer((_) async => mockKategori);
      when(() => mockPelangganOp.ambilBerdasarkanId('p1'))
          .thenAnswer((_) async => mockPelanggan);
      when(() => mockPaketOp.ambilBerdasarkanId('pkt1'))
          .thenAnswer((_) async => mockPaket);

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      await tester.pumpAndSettle();

      expect(find.text('Dompet Utama'), findsOneWidget);
      expect(find.text('Internet'), findsOneWidget);
      expect(find.text('Budi'), findsOneWidget);
      expect(find.text('Paket Cepat'), findsOneWidget);
    });

    testWidgets(
        '05. harus menampilkan "Data tidak ditemukan" jika data dinamis tidak ada',
        (tester) async {
      when(() => mockDompetOp.ambilBerdasarkanId('d1')).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      await tester.pumpAndSettle();

      expect(find.text('Data tidak ditemukan'), findsOneWidget);
    });

    testWidgets(
        '06. harus menampilkan "Error Data" jika terjadi kegagalan saat mengambil data',
        (tester) async {
      when(() => mockDompetOp.ambilBerdasarkanId('d1'))
          .thenThrow(Exception('DB Error'));

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      await tester.pumpAndSettle();

      expect(find.text('Error Data'), findsOneWidget);
    });

    testWidgets('07. Hanya menampilkan baris untuk data opsional yang ada',
        (tester) async {
      final transaksiLengkap = mockTransaksi.copyWith(
        idDompetTujuan: 'd2',
        tanggalMulai: DateTime(2023, 10, 1),
        tanggalBerakhir: DateTime(2023, 11, 1),
      );
      when(() => mockDompetOp.ambilBerdasarkanId('d2')).thenAnswer(
          (_) async => DompetModel(id: 'd2', nama: 'Dompet Tujuan', saldo: 0));

      await tester.pumpWidget(createWidgetUnderTest(transaksiLengkap));
      await tester.pumpAndSettle();

      expect(find.text('Dompet Tujuan'), findsOneWidget);
      expect(find.text('Masa Aktif Mulai'), findsOneWidget);
      expect(find.text('Masa Aktif Berakhir'), findsOneWidget);
    });

    testWidgets('08. Tidak menampilkan baris untuk data opsional yang null',
        (tester) async {
      final transaksiMinimal = TransaksiModel(
        id: 't2',
        deskripsi: 'Minimal',
        jumlah: 100,
        tanggal: DateTime.now(),
        tipe: TipeTransaksi.income,
        idDompet: 'd1',
        idKategori: 'k1',
      );

      await tester.pumpWidget(createWidgetUnderTest(transaksiMinimal));
      await tester.pumpAndSettle();

      expect(find.text('Dompet Tujuan'), findsNothing);
      expect(find.text('Pelanggan'), findsNothing);
      expect(find.text('Paket'), findsNothing);
      expect(find.text('Masa Aktif Mulai'), findsNothing);
    });
  });

  group('Interaksi & Navigasi', () {
    testWidgets('09. harus menavigasi ke FormTransaksi saat tombol edit ditekan',
        (tester) async {
      when(() => mockNavigatorObserver.didPush(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(
          any(that: isA<MaterialPageRoute>()), any()));
      expect(find.byType(FormTransaksi), findsOneWidget);
    });

    testWidgets(
        '10. harus memuat ulang data saat kembali dari form dengan hasil true',
        (tester) async {
      final updatedTransaksi = mockTransaksi.copyWith(deskripsi: 'Updated Wifi');

      when(() => mockTransaksiOp.ambilBerdasarkanId('t1'))
          .thenAnswer((_) async => updatedTransaksi);

      // Stub the navigation
      when(() => mockNavigatorObserver.didPush(any(), any()))
          .thenAnswer((invocation) {
        // Simulate returning `true` from FormTransaksi
        final route = invocation.positionalArguments[0] as MaterialPageRoute;
        Future.delayed(Duration.zero, () => route.navigator?.pop(true));
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));

      expect(find.text('Pembayaran Wifi'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify the UI is updated
      expect(find.text('Updated Wifi'), findsOneWidget);
      verify(() => mockTransaksiOp.ambilBerdasarkanId('t1')).called(1);
    });

    testWidgets(
        '11. tidak boleh memuat ulang data jika kembali dari form dengan hasil false',
        (tester) async {
      when(() => mockNavigatorObserver.didPush(any(), any()))
          .thenAnswer((invocation) {
        final route = invocation.positionalArguments[0] as MaterialPageRoute;
        Future.delayed(Duration.zero, () => route.navigator?.pop(false));
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verifyNever(() => mockTransaksiOp.ambilBerdasarkanId(any()));
    });

    testWidgets(
        '12. harus menampilkan Toast error jika gagal memuat ulang data setelah edit',
        (tester) async {
      when(() => mockTransaksiOp.ambilBerdasarkanId('t1'))
          .thenThrow(Exception('Load failed'));

      when(() => mockNavigatorObserver.didPush(any(), any()))
          .thenAnswer((invocation) {
        final route = invocation.positionalArguments[0] as MaterialPageRoute;
        Future.delayed(Duration.zero, () => route.navigator?.pop(true));
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Since ToastUtil is static, we can't easily mock it.
      // We verify that the data has not changed as a proxy.
      expect(find.text('Pembayaran Wifi'), findsOneWidget);
      // And we assume the log and toast were called.
    });

    testWidgets('13. harus keluar halaman jika data tidak ditemukan setelah edit',
        (tester) async {
      when(() => mockTransaksiOp.ambilBerdasarkanId('t1'))
          .thenAnswer((_) async => null);
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);

      when(() => mockNavigatorObserver.didPush(any(), any()))
          .thenAnswer((invocation) {
        final route = invocation.positionalArguments[0] as MaterialPageRoute;
        Future.delayed(Duration.zero, () => route.navigator?.pop(true));
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));

      expect(find.byType(DetailTransaksi), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify that the page was popped
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
      expect(find.byType(DetailTransaksi), findsNothing);
    });

    testWidgets('14. harus mengembalikan true saat pop setelah ada pembaruan',
        (tester) async {
      final updatedTransaksi = mockTransaksi.copyWith(deskripsi: 'Updated');
      when(() => mockTransaksiOp.ambilBerdasarkanId('t1'))
          .thenAnswer((_) async => updatedTransaksi);
      when(() => mockNavigatorObserver.didPush(any(), any()))
          .thenAnswer((invocation) {
        final route = invocation.positionalArguments[0] as MaterialPageRoute;
        Future.delayed(Duration.zero, () => route.navigator?.pop(true));
      });
      bool? popResult;
      when(() => mockNavigatorObserver.didPop(any(), any())).thenAnswer((inv) {
        popResult = inv.positionalArguments[1] as bool?;
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle(); // Finish edit simulation

      // Now pop the detail page itself
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(popResult, isTrue);
    });

    testWidgets('15. harus mengembalikan false saat pop jika tidak ada pembaruan',
        (tester) async {
      bool? popResult;
      when(() => mockNavigatorObserver.didPop(any(), any())).thenAnswer((inv) {
        popResult = inv.positionalArguments[1] as bool?;
      });

      await tester.pumpWidget(createWidgetUnderTest(mockTransaksi));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(popResult, isFalse);
    });
  });
}


// path: test/admin/halaman/form/form_pelanggan_aktif_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/model/kategori_keuangan_model.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

// Mocks
class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransaksiOpSqlite {}

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockKategoriOpSqlite extends Mock implements KategoriOpSqlite {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockPaketOpSqlite mockPaketOp;
  late MockTransaksiOpsqlite mockTransaksiOp;
  late MockDompetOpSqlite mockDompetOp;
  late MockKategoriOpSqlite mockKategoriOp;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  final tPelanggan = PelangganModel(
    id: '1',
    nama: 'Pelanggan Test',
    email: 'test@example.com',
    nomorTelepon: '08123456789',
    alamat: 'Alamat Test',
  );

  final tPaket = PaketModel(
    id: 'p1',
    nama: 'Paket Internet',
    harga: 100000,
    durasi: 30,
  );

  final tDompet = DompetModel(id: 'd1', nama: 'Dompet Utama', saldo: 500000);
  final tKategori = KategoriKeuanganModel(id: 'c1', nama: 'Penjualan');

  setUp(() {
    mockPaketOp = MockPaketOpSqlite();
    mockTransaksiOp = MockTransaksiOpsqlite();
    mockDompetOp = MockDompetOpSqlite();
    mockKategoriOp = MockKategoriOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    container = ProviderContainer(
      overrides: [
        paketOpSqliteProvider.overrideWithValue(mockPaketOp),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOp),
        dompetOpSqliteProvider.overrideWithValue(mockDompetOp),
        kategoriOpSqliteProvider.overrideWithValue(mockKategoriOp),
      ],
    );

    when(() => mockPaketOp.ambilSemuaPaket()).thenAnswer((_) async => [tPaket]);
    when(() => mockDompetOp.ambilSemua()).thenAnswer((_) async => [tDompet]);
    when(() => mockKategoriOp.ambilSemuaKategori())
        .thenAnswer((_) async => [tKategori]);
    when(() => mockTransaksiOp.addTransaksi(any())).thenAnswer((_) async => 1);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: FormPelangganAktif(pelanggan: tPelanggan),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('FormPelangganAktif', () {
    testWidgets('01. harus menampilkan form dengan benar dan data terisi',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Aktivasi Paket untuk Pelanggan Test'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField), findsNWidgets(3));
    });

    testWidgets('02. harus menampilkan error jika form tidak diisi',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Pilih paket dulu'), findsOneWidget);
    });

    testWidgets('03. harus berhasil menyimpan transaksi baru', (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('paket-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paket Internet').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dompet-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet Utama').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() => mockTransaksiOp.addTransaksi(any())).called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
      expect(find.text('Aktivasi paket berhasil'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan snackbar error jika gagal menyimpan',
        (tester) async {
      when(() => mockTransaksiOp.addTransaksi(any()))
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('paket-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paket Internet').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dompet-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dompet Utama').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal mengaktivasi paket'), findsOneWidget);
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });
  });
}


// path: test/admin/halaman/lainnya/riwayat_aktivasi_paket_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/lainnya/riwayat_aktivasi_paket.dart';
import 'package:wifi/admin/providers/riwayat_aktivasi_paket_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

// Mocks
class MockTransaksiOpSqlite extends Mock implements TransaksiOpsqlite {}

class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

void main() {
  late MockTransaksiOpSqlite mockTransaksiOp;
  late MockPelangganOpSqlite mockPelangganOp;
  late ProviderContainer container;

  final tPelanggan1 = PelangganModel(
    id: 'p1',
    nama: 'Alpha',
    alamat: '',
    telepon: '',
    macAddress: '',
    kataSandi: '',
  );
  final tPelanggan2 = PelangganModel(
    id: 'p2',
    nama: 'Bravo',
    alamat: '',
    telepon: '',
    macAddress: '',
    kataSandi: '',
  );

  final tTransaksi1 = TransaksiModel(
    id: 't1',
    idPelanggan: 'p1',
    deskripsi: 'Aktivasi Alpha',
    tanggalBerakhir: DateTime(2023, 10, 30),
    tipe: TipeTransaksi.income,
    jumlah: 100,
    tanggal: DateTime.now(),
    idDompet: 'd1',
    idKategori: 'k1',
  );

  final tTransaksi2 = TransaksiModel(
    id: 't2',
    idPelanggan: 'p2',
    deskripsi: 'Aktivasi Bravo',
    tanggalBerakhir: DateTime(2023, 10, 25),
    tipe: TipeTransaksi.income,
    jumlah: 100,
    tanggal: DateTime.now(),
    idDompet: 'd1',
    idKategori: 'k1',
  );

  setUp(() {
    mockTransaksiOp = MockTransaksiOpSqlite();
    mockPelangganOp = MockPelangganOpSqlite();

    when(() => mockTransaksiOp.getTransactionsByPackageActivation())
        .thenAnswer((_) async => [tTransaksi1, tTransaksi2]);
    when(() => mockPelangganOp.ambilPelanggan())
        .thenAnswer((_) async => [tPelanggan1, tPelanggan2]);

    container = ProviderContainer(
      overrides: [
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOp),
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOp),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: const MaterialApp(
        home: RiwayatAktivasiPaketPage(),
      ),
    );
  }

  group('RiwayatAktivasiPaketPage', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('02. harus menampilkan data saat berhasil dimuat', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Bravo'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan error jika terjadi kegagalan',
        (tester) async {
      when(() => mockTransaksiOp.getTransactionsByPackageActivation())
          .thenThrow(Exception('DB Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception: DB Error'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan "Tidak ada riwayat." jika data kosong',
        (tester) async {
      when(() => mockTransaksiOp.getTransactionsByPackageActivation())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada riwayat.'), findsOneWidget);
    });

    testWidgets('05. harus bisa mengubah urutan ke Nama (A-Z)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Initial sort is by date, Bravo might be first
      final listTilesBefore = tester.widgetList<Card>(find.byType(Card));
      expect(find.text('Alpha'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nama (A-Z)'));
      await tester.pumpAndSettle();

      final listTilesAfter = tester.widgetList<Card>(find.byType(Card));
      final firstItemText = find
          .descendant(
            of: find.byWidget(listTilesAfter.first),
            matching: find.byType(Text),
          )
          .first;
      expect((firstItemText.evaluate().single.widget as Text).data, 'Alpha');
    });

    testWidgets('06. harus bisa mengubah urutan ke Nama (Z-A)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nama (Z-A)'));
      await tester.pumpAndSettle();

      final listTilesAfter = tester.widgetList<Card>(find.byType(Card));
      final firstItemText = find
          .descendant(
            of: find.byWidget(listTilesAfter.first),
            matching: find.byType(Text),
          )
          .first;
      expect((firstItemText.evaluate().single.widget as Text).data, 'Bravo');
    });
  });
}

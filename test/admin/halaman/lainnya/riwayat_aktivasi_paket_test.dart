
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
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

// Mocks
class MockTransaksiOpSqlite extends Mock implements TransaksiOpSqlite {}

class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

void main() {
  late MockTransaksiOpSqlite mockTransaksiOp;
  late MockPelangganOpSqlite mockPelangganOp;
  late ProviderContainer container;

  final tPelanggan1 = PelangganModel(
    id: '1',
    nama: 'Pelanggan A',
    email: 'a@test.com',
    nomorTelepon: '123',
    alamat: 'alamat',
  );
  final tPelanggan2 = PelangganModel(
    id: '2',
    nama: 'Pelanggan B',
    email: 'b@test.com',
    nomorTelepon: '456',
    alamat: 'alamat',
  );

  final tTransaksi1 = TransaksiModel(
    id: 't1',
    idPelanggan: '1',
    idPaket: 'p1',
    namaPaket: 'Paket 1',
    hargaPaket: 50000,
    tanggal: DateTime(2023, 1, 1),
    tanggalBerakhir: DateTime(2023, 2, 1),
    statusPembayaran: StatusPembayaran.paid,
    tipe: TipeTransaksi.package,
  );

  final tTransaksi2 = TransaksiModel(
    id: 't2',
    idPelanggan: '2',
    idPaket: 'p2',
    namaPaket: 'Paket 2',
    hargaPaket: 75000,
    tanggal: DateTime(2023, 1, 15),
    tanggalBerakhir: DateTime(2023, 2, 15),
    statusPembayaran: StatusPembayaran.unpaid,
    tipe: TipeTransaksi.package,
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
    testWidgets('01. harus menampilkan daftar riwayat dengan benar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Aktivasi Paket'), findsOneWidget);
      expect(find.text('Pelanggan A'), findsOneWidget);
      expect(find.text('Pelanggan B'), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      expect(find.text('Belum Lunas'), findsOneWidget);
    });

    testWidgets('02. harus dapat melakukan filter berdasarkan nama', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Pelanggan A');
      await tester.pumpAndSettle();

      expect(find.text('Pelanggan A'), findsOneWidget);
      expect(find.text('Pelanggan B'), findsNothing);
    });

    testWidgets('03. harus dapat melakukan sorting berdasarkan nama A-Z', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nama (A-Z)'));
      await tester.pumpAndSettle();

      final firstItem = find.text('Pelanggan A');
      final secondItem = find.text('Pelanggan B');

      final firstPos = tester.getTopLeft(firstItem);
      final secondPos = tester.getTopLeft(secondItem);

      expect(firstPos.dy, lessThan(secondPos.dy));
    });
  });
}

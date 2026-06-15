// path: test/user/page/transaction_detail_u_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';

void main() {
  final transaction = TransaksiModel(
    id: '1',
    idPelanggan: '1',
    idPaket: '1',
    tanggal: DateTime(2023, 1, 1),
    deskripsi: 'Test Transaction',
    jumlah: 100000,
    tipe: TipeTransaksi.purchase,
    statusPembayaran: StatusPembayaran.paid,
    tanggalMulai: DateTime(2023, 1, 1),
    tangglberakhir: DateTime(2023, 1, 31),
    poinDidapat: 10,
    poinDigunakan: 0,
  );

  final package = PaketModel(
    id: '1',
    nama: 'Test Package',
    harga: 100000,
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: DetailTransaksiU(
        transaksi: transaction,
        paket: package,
      ),
    );
  }

  group('TransactionDetailPage', () {
    testWidgets('Test 01: should display transaction details',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Detail Transaksi'), findsOneWidget);
      expect(find.text('Test Transaction'), findsOneWidget);
      expect(find.text('100.000'), findsOneWidget);
      expect(find.text('Purchase'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });
}

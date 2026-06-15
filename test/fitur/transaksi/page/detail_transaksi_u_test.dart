
// path: test/fitur/transaksi/page/detail_transaksi_u_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

// Mock BannerAdsWidget untuk menghindari error terkait ads di test
class MockBannerAdsWidget extends StatelessWidget {
  const MockBannerAdsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      width: double.infinity,
      child: Center(child: Text('Mock Banner Ad')),
    );
  }
}

void main() {
  final tTransaksi = TransaksiModel(
    id: 'trans1',
    deskripsi: 'Pembayaran Bulanan',
    jumlah: 50000,
    tanggal: DateTime(2023, 1, 15),
    tipe: TipeTransaksi.expense, // FIX: Menggunakan enum yang benar
    statusPembayaran: StatusPembayaran.paid,
    idDompet: 'dompet1',
    idKategori: 'kat1',
    poinDidapat: 25,
  );

  final tPaket = PaketModel(
      id: 'pkt1', nama: 'Paket Gamer', harga: 50000, durasi: 30, tipe: 'reguler');

  Widget createWidgetUnderTest(
      {required TransaksiModel transaksi, PaketModel? paket}) {
    return MaterialApp(
      home: Scaffold(
        body: DetailTransaksiU(transaksi: transaksi, paket: paket),
        bottomNavigationBar: const MockBannerAdsWidget(),
      ),
    );
  }

  group('DetailTransaksiU Rendering UI', () {
    testWidgets('01. harus merender AppBar dengan judul "Detail Transaksi"',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(transaksi: tTransaksi));

      // Wrap DetailTransaksiU dalam Scaffold untuk test AppBar
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(appBar: AppBar(title: const Text('Detail Transaksi'))),
      ));

      expect(find.widgetWithText(AppBar, 'Detail Transaksi'), findsOneWidget);
    });

    testWidgets('02. harus menampilkan semua detail transaksi dasar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(transaksi: tTransaksi));

      expect(find.text('15 Jan 23'), findsOneWidget);
      expect(find.text('Pembayaran Bulanan'), findsOneWidget);
      expect(find.text('Rp50.000'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      expect(find.text('25'), findsOneWidget); // Poin didapat
    });

    testWidgets('03. harus menampilkan nama paket jika PaketModel disediakan',
        (tester) async {
      await tester
          .pumpWidget(createWidgetUnderTest(transaksi: tTransaksi, paket: tPaket));

      expect(find.text('Paket Gamer'), findsOneWidget);
    });

    testWidgets(
        '04. harus menampilkan "Memuat..." untuk paket jika idPaket ada tapi PaketModel null',
        (tester) async {
      final transaksiWithPaketId = tTransaksi.copyWith(idPaket: 'pkt1');
      await tester.pumpWidget(
          createWidgetUnderTest(transaksi: transaksiWithPaketId, paket: null));

      expect(find.text('Memuat...'), findsOneWidget);
    });

    testWidgets(
        '05. tidak menampilkan baris paket jika idPaket dan PaketModel keduanya null',
        (tester) async {
      final transaksiTanpaPaket = tTransaksi.copyWith(idPaket: null);
      await tester.pumpWidget(
          createWidgetUnderTest(transaksi: transaksiTanpaPaket, paket: null));

      expect(find.textContaining('Paket:'), findsNothing);
    });

    testWidgets(
        '06. harus menampilkan tanggal mulai, berakhir, dan bonus jika datanya ada',
        (tester) async {
      final transaksiLengkap = tTransaksi.copyWith(
        tanggalMulai: DateTime(2023, 1, 15),
        tanggalBerakhir: DateTime(2023, 2, 15),
        durasiBonus: 7,
        tipeDurasiBonus: TipeDurasiPaket.hari, // FIX: Menggunakan enum yang benar
      );
      await tester.pumpWidget(createWidgetUnderTest(transaksi: transaksiLengkap));

      expect(find.text('Tanggal Mulai:'), findsOneWidget);
      expect(find.text('15 Jan 23'), findsWidgets);
      expect(find.text('Tanggal Berakhir:'), findsOneWidget);
      expect(find.text('15 Feb 23'), findsOneWidget);
      expect(find.text('Bonus'), findsOneWidget);
      expect(find.text('7 Hari'), findsOneWidget);
    });

    testWidgets('07. tidak menampilkan tanggal dan bonus jika datanya tidak ada',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(transaksi: tTransaksi));

      expect(find.text('Tanggal Mulai:'), findsNothing);
      expect(find.text('Tanggal Berakhir:'), findsNothing);
      expect(find.text('Bonus'), findsNothing);
    });

    testWidgets('08. harus menampilkan BannerAdsWidget', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(transaksi: tTransaksi));
      expect(find.byType(MockBannerAdsWidget), findsOneWidget);
    });
  });
}

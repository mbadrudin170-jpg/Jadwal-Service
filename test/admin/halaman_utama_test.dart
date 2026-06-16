
// path: test/admin/halaman_utama_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/dompet/page/dompet_page.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_page_a.dart';

void main() {
  group('HalamanUtama', () {
    testWidgets('01. harus menampilkan tampilan awal dengan benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HalamanUtama(),
          ),
        ),
      );

      // Verifikasi bahwa tab "Pelanggan" ditampilkan secara default
      expect(find.byType(PelangganAktifPage), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.text('Pelanggan'), findsOneWidget);

      // Verifikasi bahwa tab lain juga ada
      expect(find.byIcon(Icons.payment), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.byIcon(Icons.wallet_giftcard), findsOneWidget);
      expect(find.text('Dompet'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);
    });

    testWidgets('02. harus beralih ke tab Transaksi saat diketuk',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HalamanUtama(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.payment));
      await tester.pumpAndSettle();

      expect(find.byType(TransaksiPageA), findsOneWidget);
    });

    testWidgets('03. harus beralih ke tab Dompet saat diketuk',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HalamanUtama(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.wallet_giftcard));
      await tester.pumpAndSettle();

      expect(find.byType(DompetPage), findsOneWidget);
    });

    testWidgets('04. harus beralih ke tab Aktif saat diketuk',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HalamanUtama(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.wifi));
      await tester.pumpAndSettle();

      expect(find.byType(PelangganAktifPage), findsOneWidget);
    });

    testWidgets('05. harus beralih ke tab Lainnya saat diketuk',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HalamanUtama(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.byType(LainnyaPage), findsOneWidget);
    });
  });
}

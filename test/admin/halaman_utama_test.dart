// path: test/admin/halaman_utama_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/halaman/tab/dompet.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman/tab/pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/tab/transaksi.dart';
import 'package:wifi/admin/halaman_utama.dart';

void main() {
  // TODO: setup dan mock untuk service yang dibutuhkan
  group('HalamanUtama Widget Tests', () {
    testWidgets('Initial page is PelangganAktifPage',
        (final WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(),
        ),
      );

      expect(find.byType(PelangganAktifPage), findsOneWidget);
      expect(find.byType(DompetPage), findsNothing);
      expect(find.byType(TransaksiPage), findsNothing);
      expect(find.byType(LainnyaPage), findsNothing);
    });

    testWidgets('Tapping bottom navigation bar items changes the page',
        (final WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(),
        ),
      );

      // Tap on Dompet
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();
      expect(find.byType(DompetPage), findsOneWidget);

      // Tap on Transaksi
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();
      expect(find.byType(TransaksiPage), findsOneWidget);

      // Tap on Lainnya
      await tester.tap(find.byIcon(Icons.apps));
      await tester.pumpAndSettle();
      expect(find.byType(LainnyaPage), findsOneWidget);

      // Tap on Aktif
      await tester.tap(find.byIcon(Icons.person_pin_circle));
      await tester.pumpAndSettle();
      expect(find.byType(PelangganAktifPage), findsOneWidget);
    });

    testWidgets('Shows offline snackbar when isOffline is true',
        (final WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(isOffline: true),
        ),
      );

      await tester.pump(); // pump once for the post-frame callback

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.text('Anda dalam mode offline. Data mungkin tidak terbaru.'), findsOneWidget);
    });

    testWidgets('Does not show offline snackbar when isOffline is false',
        (final WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(),
        ),
      );

      await tester.pump(); // pump once for the post-frame callback

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

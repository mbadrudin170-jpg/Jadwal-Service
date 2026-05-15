// path: test/shared/widget/teks_pengaman_database_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/widget/teks_pengaman_database_widget.dart';

void main() {
  group('TeksPengamanDatabaseWidget Tests', () {
    testWidgets('1. harus menampilkan teks yang dikirim melalui parameter',
        (final WidgetTester tester) async {
      const String teksUji = 'Ini adalah teks pengaman untuk database.';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeksPengamanDatabaseWidget(teks: teksUji),
          ),
        ),
      );

      expect(find.text(teksUji), findsOneWidget);
      debugPrint('TEST 1: Berhasil menampilkan teks yang valid.');
    });

    testWidgets(
        '2. harus menampilkan widget kosong jika teks yang dikirim adalah string kosong',
        (final WidgetTester tester) async {
      const String teksKosong = '';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeksPengamanDatabaseWidget(teks: teksKosong),
          ),
        ),
      );

      final finderTeks = find.text(teksKosong);
      expect(finderTeks, findsOneWidget);
      final textWidget = tester.widget<Text>(finderTeks);
      expect(textWidget.data, teksKosong);
      debugPrint('TEST 2: Berhasil menangani string kosong.');
    });

    // Test case ini diperbaiki untuk mengatasi dua masalah:
    // 1. Menghilangkan argumen `teks: null` yang redundan (sesuai lint warning).
    // 2. Memastikan pengujian untuk nilai null berfungsi dengan benar.
    testWidgets('3. harus menampilkan tanda hubung jika teks tidak diberikan (null)',
        (final WidgetTester tester) async {
      // Membangun widget tanpa memberikan parameter `teks`.
      // Ini secara otomatis akan bernilai `null`.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeksPengamanDatabaseWidget(),
          ),
        ),
      );

      // Verifikasi bahwa widget menampilkan tanda hubung '-'.
      expect(find.text('-'), findsOneWidget);
      debugPrint('TEST 3: Berhasil menampilkan \'-\' saat teks null.');
    });

    testWidgets('4. harus menerapkan gaya default jika tidak ada gaya yang diberikan',
        (final WidgetTester tester) async {
      const String teksUji = 'Teks dengan gaya default';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeksPengamanDatabaseWidget(teks: teksUji),
          ),
        ),
      );

      final finderTeks = find.text(teksUji);
      expect(finderTeks, findsOneWidget);

      final BuildContext context = tester.element(find.byType(Scaffold));
      final textWidget = tester.widget<Text>(finderTeks);
      final defaultStyle = Theme.of(context).textTheme.bodyMedium;

      expect(textWidget.style, defaultStyle);
      debugPrint('TEST 4: Berhasil menerapkan gaya default.');
    });

    testWidgets('5. harus menerapkan gaya kustom jika gaya diberikan',
        (final WidgetTester tester) async {
      const String teksUji = 'Teks dengan gaya kustom';
      const TextStyle gayaKustom = TextStyle(color: Colors.red, fontSize: 20);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeksPengamanDatabaseWidget(teks: teksUji, style: gayaKustom),
          ),
        ),
      );

      final finderTeks = find.text(teksUji);
      expect(finderTeks, findsOneWidget);

      final textWidget = tester.widget<Text>(finderTeks);
      expect(textWidget.style, gayaKustom);
      debugPrint('TEST 5: Berhasil menerapkan gaya kustom.');
    });
  });
}

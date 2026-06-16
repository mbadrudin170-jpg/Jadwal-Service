
// path: test/admin/halaman/detail/detail_paket_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/page/form_paket.dart';
import 'package:wifi/shared/theme/app_icons.dart';

// Mocks
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockNavigatorObserver;

  final paketPublik = PaketModel(
    id: 'p1',
    nama: 'Paket Kencang',
    harga: 50000,
    durasi: 30,
    tipe: TipeDurasiPaket.hari,
    poinHadiah: 10,
    poinPenukaran: 100,
    statusPublik: true,
  );

  final paketPrivate = paketPublik.copyWith(
    id: 'p2',
    nama: 'Paket Rahasia',
    statusPublik: false,
  );

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createWidget(PaketModel paket) {
    return ProviderScope(
      child: MaterialApp(
        home: DetailPaketPage(paket: paket),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('01. Tampilan UI DetailPaketPage', () {
    testWidgets('01. harus menampilkan semua detail paket dengan benar (status publik true)',
        (tester) async {
      await tester.pumpWidget(createWidget(paketPublik));

      // Cek AppBar title
      expect(find.widgetWithText(AppBar, 'Paket Kencang'), findsOneWidget);

      // Cek detail di body
      expect(find.text('Paket Kencang'), findsNWidgets(2)); // Title and body
      expect(find.text('Rp 50000'), findsOneWidget);
      expect(find.text('30 Hari'), findsOneWidget);
      expect(find.text('10 Poin'), findsOneWidget);
      expect(find.text('100 Poin'), findsOneWidget);
      
      // Cek status publik
      final statusText = find.text('Tersedia di Aplikasi');
      expect(statusText, findsOneWidget);
      
      // Cek warna teks status
      final textWidget = tester.widget<Text>(statusText);
      expect(textWidget.style?.color, Colors.green);
    });

    testWidgets('02. harus menampilkan status publik "Hanya Admin" dengan warna merah (status publik false)',
        (tester) async {
      await tester.pumpWidget(createWidget(paketPrivate));
      
      // Cek AppBar title
      expect(find.widgetWithText(AppBar, 'Paket Rahasia'), findsOneWidget);

      // Cek status publik
      final statusText = find.text('Hanya Admin');
      expect(statusText, findsOneWidget);
      
      // Cek warna teks status
      final textWidget = tester.widget<Text>(statusText);
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('03. harus menampilkan sub-judul untuk poin', (tester) async {
      await tester.pumpWidget(createWidget(paketPublik));

      expect(find.text('Didapat saat beli paket'), findsOneWidget);
      expect(find.text('Syarat tukar gratis'), findsOneWidget);
    });
  });

  group('02. Navigasi', () {
    testWidgets('01. harus menavigasi ke FormPaket saat tombol edit ditekan',
        (tester) async {
      await tester.pumpWidget(createWidget(paketPublik));

      // Tekan tombol edit di AppBar
      await tester.tap(find.byIcon(TIcons.edit));
      await tester.pumpAndSettle();

      // Verifikasi bahwa navigasi terjadi
      verify(mockNavigatorObserver.didPush(any, any));

      // Verifikasi bahwa halaman yang dituju adalah FormPaket
      expect(find.byType(FormPaket), findsOneWidget);

      // Verifikasi bahwa FormPaket menerima paket yang benar
      final formPaket = tester.widget<FormPaket>(find.byType(FormPaket));
      expect(formPaket.paket, equals(paketPublik));
    });

    testWidgets('02. harus menutup halaman (pop) dengan hasil true jika edit berhasil (result true)',
        (tester) async {
      await tester.pumpWidget(createWidget(paketPublik));

      // Tekan tombol edit
      await tester.tap(find.byIcon(TIcons.edit));
      await tester.pumpAndSettle();

      // Verifikasi push terjadi
      final pushedRoute = verify(mockNavigatorObserver.didPush(captureAny, any)).captured.last as Route;
      expect(find.byType(FormPaket), findsOneWidget);

      // Pop halaman FormPaket dengan hasil true
      Navigator.of(tester.element(find.byType(FormPaket))).pop(true);
      await tester.pumpAndSettle();

      // Verifikasi bahwa DetailPaketPage di-pop dengan hasil true
      verify(mockNavigatorObserver.didPop(pushedRoute, true));
    });

    testWidgets('03. tidak boleh menutup halaman jika edit dibatalkan (result false)',
        (tester) async {
      await tester.pumpWidget(createWidget(paketPublik));

      final currentPageRoute = ModalRoute.of(tester.element(find.byType(DetailPaketPage)));

      // Tekan tombol edit
      await tester.tap(find.byIcon(TIcons.edit));
      await tester.pumpAndSettle();
      expect(find.byType(FormPaket), findsOneWidget);

      // Pop halaman FormPaket dengan hasil false
      Navigator.of(tester.element(find.byType(FormPaket))).pop(false);
      await tester.pumpAndSettle();

      // Verifikasi DetailPaketPage tidak di-pop
      final popEvents = verify(mockNavigatorObserver.didPop(captureAny, any)).captured;
      // Seharusnya hanya ada satu pop event (dari FormPaket), dan itu bukan route halaman detail.
      expect(popEvents.length, 1);
      expect(popEvents.first, isNot(equals(currentPageRoute)));
      
      // Halaman detail masih ada di tree
      expect(find.byType(DetailPaketPage), findsOneWidget);
    });
    
    testWidgets('04. tidak boleh menutup halaman jika edit dibatalkan (result null)',
        (tester) async {
      await tester.pumpWidget(createWidget(paketPublik));
      final currentPageRoute = ModalRoute.of(tester.element(find.byType(DetailPaketPage)));

      // Tekan tombol edit
      await tester.tap(find.byIcon(TIcons.edit));
      await tester.pumpAndSettle();
      expect(find.byType(FormPaket), findsOneWidget);

      // Pop halaman FormPaket dengan hasil null
      Navigator.of(tester.element(find.byType(FormPaket))).pop(null);
      await tester.pumpAndSettle();

      final popEvents = verify(mockNavigatorObserver.didPop(captureAny, any)).captured;
      expect(popEvents.length, 1);
      expect(popEvents.first, isNot(equals(currentPageRoute)));
      expect(find.byType(DetailPaketPage), findsOneWidget);
    });
  });
}

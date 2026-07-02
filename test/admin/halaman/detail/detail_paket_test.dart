// path: test/admin/halaman/detail/detail_paket_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';

import 'detail_paket_test.mocks.dart';

@GenerateMocks([NavigatorObserver])
void main() {
  late MockNavigatorObserver mockNavigatorObserver;

  const paket = PaketModel(
    id: '1',
    nama: 'Paket Harian',
    harga: 10000,
    durasi: 1,
    tipe: TipeDurasiPaket.days,
    poinHadiah: 10,
    poinPenukaran: 100,
    statusPublik: true,
  );

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [detailPaketProvider(paket.id).overrideWith((ref) => paket)],
      child: MaterialApp(
        home: DetailPaketPage(paket: paket),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('01. DetailPaketPage UI Tests', () {
    testWidgets('01. harus menampilkan detail paket dengan benar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Detail Paket'), findsOneWidget);
      expect(find.text('Nama Paket'), findsOneWidget);
      expect(find.text('Paket Harian'), findsOneWidget);
      expect(find.text('Harga'), findsOneWidget);
      expect(find.text('10,000'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('1 Hari'), findsOneWidget);
      expect(find.text('Poin Hadiah'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Poin Penukaran'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Status Publik'), findsOneWidget);
      expect(find.text('Dapat dilihat oleh semua pengguna'), findsOneWidget);
    });

    testWidgets('02. harus menampilkan status non-publik dengan benar', (
      tester,
    ) async {
      final paketNonPublik = paket.copyWith(statusPublik: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailPaketProvider(
              paketNonPublik.id,
            ).overrideWith((ref) => paketNonPublik),
          ],
          child: MaterialApp(home: DetailPaketPage(paket: paketNonPublik)),
        ),
      );

      expect(find.text('Hanya dapat dilihat oleh admin'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan durasi dalam jam, menit, bulan', (
      tester,
    ) async {
      final paketJam = paket.copyWith(tipe: TipeDurasiPaket.hours, durasi: 5);
      await tester.pumpWidget(
        MaterialApp(home: DetailPaketPage(paket: paketJam)),
      );
      expect(find.text('5 Jam'), findsOneWidget);

      final paketMenit = paket.copyWith(
        tipe: TipeDurasiPaket.minutes,
        durasi: 30,
      );
      await tester.pumpWidget(
        MaterialApp(home: DetailPaketPage(paket: paketMenit)),
      );
      expect(find.text('30 Menit'), findsOneWidget);

      final paketBulan = paket.copyWith(
        tipe: TipeDurasiPaket.months,
        durasi: 2,
      );
      await tester.pumpWidget(
        MaterialApp(home: DetailPaketPage(paket: paketBulan)),
      );
      expect(find.text('2 Bulan'), findsOneWidget);
    });
  });

  group('02. Interaksi dan Navigasi', () {
    testWidgets(
      '01. harus kembali ke halaman sebelumnya saat tombol back ditekan',
      (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        verify(mockNavigatorObserver.didPop(any, any)).called(1);
      },
    );

    testWidgets('02. harus navigasi ke halaman edit saat tombol edit ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets(
      '03. harus menampilkan dialog konfirmasi saat tombol hapus ditekan',
      (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text('Konfirmasi Hapus'), findsOneWidget);
        expect(
          find.text('Apakah Anda yakin ingin menghapus paket ini?'),
          findsOneWidget,
        );
        expect(find.text('Batal'), findsOneWidget);
        expect(find.text('Hapus'), findsOneWidget);
      },
    });
  });
}

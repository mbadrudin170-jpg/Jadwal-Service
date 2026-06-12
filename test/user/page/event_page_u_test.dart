
// path: test/user/page/event_page_u_test.dart
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/user/page/event_page_u.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockTimer extends Mock implements Timer {}

void main() {
  // Data dummy
  final event = EventModel(
    id: 'event1',
    title: 'Test Event',
    imageUrl: 'https://via.placeholder.com/600',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 1)),
  );

  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
  });

  // Widget wrapper
  Widget createWidgetUnderTest() {
    return ProviderScope(
      child: MaterialApp(
        home: EventPageU(event: event),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Uji Halaman Event Pengguna', () {
    testWidgets('Test 01: Render awal menampilkan gambar dan countdown',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifikasi CachedNetworkImage
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      final image = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
      expect(image.imageUrl, event.imageUrl);

      // Verifikasi tombol dengan angka countdown awal
      expect(find.widgetWithText(ElevatedButton, '5'), findsOneWidget);
    });

    testWidgets('Test 02: Hitung mundur otomatis dan menutup halaman',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      verify(() => mockNavigatorObserver.didPush(any(), any()));

      // Awal
      expect(find.text('5'), findsOneWidget);

      // Setelah 1 detik
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4'), findsOneWidget);

      // Setelah 2 detik
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('3'), findsOneWidget);

      // Setelah 3 detik
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);

      // Setelah 4 detik
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      
      // Setelah 5 detik
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      
      // Setelah 6 detik, halaman harusnya sudah di-pop
      await tester.pump(const Duration(seconds: 1));
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('Test 03: Tombol tutup manual berfungsi', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      verify(() => mockNavigatorObserver.didPush(any(), any()));

      // Tekan tombol tutup
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verifikasi halaman ditutup
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('Test 04: Timer dibatalkan saat widget di-dispose', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final state = tester.state(find.byType(EventPageU)) as _EventPageUState;
      final timer = state._timer;

      expect(timer, isNotNull);
      expect(timer!.isActive, isTrue);

      // Dispose widget
      await tester.pumpWidget(Container());

      // Verifikasi timer tidak aktif lagi
      expect(timer.isActive, isFalse);
    });
  });
}

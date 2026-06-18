
// path: test/fitur/event/page/event_page_a_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/event_page_a.dart';

import 'event_page_a_test.mocks.dart';

@GenerateMocks([EventOpSupabase, NavigatorObserver])
void main() {
  late MockEventOpSupabase mockEventOpSupabase;
  late MockNavigatorObserver mockNavigatorObserver;
  late StreamController<List<EventModel>> streamController;

  setUp(() {
    mockEventOpSupabase = MockEventOpSupabase();
    mockNavigatorObserver = MockNavigatorObserver();
    streamController = StreamController<List<EventModel>>();

    // Stub stream sebagai perilaku default
    when(
      mockEventOpSupabase.ambilRealtimeStream(),
    ).thenAnswer((_) => streamController.stream);
  });

  tearDown(() {
    streamController.close();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
      ],
      child: MaterialApp(
        home: const EventPageA(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  final testEvent = EventModel(
    id: 'event-123',
    linkGambar: 'https://example.com/image.png',
    statusAktif: true,
    tanggalDibuat: DateTime(2023, 10, 10),
    tanggalMulai: DateTime(2023, 10, 11),
    tanggalBerakhir: DateTime(2023, 10, 12),
  );

  group('EventPageA UI States', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat loading',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('02. harus menampilkan pesan saat daftar pengumuman kosong', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      streamController.add([]);
      await tester.pump();
      expect(find.text('Belum ada pengumuman.'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan daftar pengumuman saat ada data', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      streamController.add([testEvent]);
      await tester.pump();
      expect(find.byType(Card), findsOneWidget);
      expect(find.textContaining('ID: event-123'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan pesan error saat stream gagal', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      streamController.addError(Exception('Gagal memuat'));
      await tester.pump();
      expect(find.text('Gagal memuat pengumuman.'), findsOneWidget);
    });
  });

  group('Interaksi Pengguna', () {
    testWidgets('05. harus navigasi ke halaman kelola saat FAB ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      streamController.add([]);
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
    });

    testWidgets('06. harus navigasi ke detail saat item di-tap', (
      tester,
    ) async {
      when(
        mockEventOpSupabase.ambilBerdasarkanId('event-123'),
      ).thenAnswer((_) async => testEvent);

      await tester.pumpWidget(createWidgetUnderTest());
      streamController.add([testEvent]);
      await tester.pump();

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('Detail Pengumuman'), findsOneWidget);
    });
  });
}

// path: test/fitur/event/page/detail_event_a_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/detail_event_a.dart';

import 'detail_event_a_test.mocks.dart';

@GenerateMocks([EventOpSupabase])
void main() {
  late MockEventOpSupabase mockEventOpSupabase;

  setUp(() {
    mockEventOpSupabase = MockEventOpSupabase();
  });

  final testEvent = EventModel(
    id: 'evt-123',
    linkGambar: 'https://example.com/image.png',
    statusAktif: true,
    tanggalDibuat: DateTime(2023, 1, 1),
    tanggalMulai: DateTime(2023, 1, 2),
    tanggalBerakhir: DateTime(2023, 1, 3),
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
      ],
      child: MaterialApp(home: DetailEventA(event: testEvent)),
    );
  }

  group('DetailEventA Widget Tests', () {
    testWidgets('01. harus menampilkan loading indicator saat memuat data', (
      tester,
    ) async {
      final completer = Completer<EventModel?>();
      when(
        mockEventOpSupabase.ambilBerdasarkanId(testEvent.id),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      '02. harus menampilkan detail event saat data berhasil dimuat',
      (tester) async {
        when(
          mockEventOpSupabase.ambilBerdasarkanId(testEvent.id),
        ).thenAnswer((_) async => testEvent);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Detail Pengumuman'), findsOneWidget);
        expect(find.text(testEvent.id), findsOneWidget);
        expect(find.text('Aktif'), findsOneWidget);
        expect(find.textContaining('Dibuat: 2023-01-01'), findsOneWidget);
      },
    );

    testWidgets('03. harus menampilkan pesan error jika gagal memuat data', (
      tester,
    ) async {
      when(
        mockEventOpSupabase.ambilBerdasarkanId(testEvent.id),
      ).thenAnswer((_) async => throw Exception('Koneksi Gagal'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger build
      await tester.pump(); // Trigger FutureBuilder completion with error

      expect(find.text('Gagal memuat data.'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan pesan jika pengumuman tidak ditemukan', (
      tester,
    ) async {
      when(
        mockEventOpSupabase.ambilBerdasarkanId(testEvent.id),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Pengumuman tidak ditemukan.'), findsOneWidget);
    });
  });
}

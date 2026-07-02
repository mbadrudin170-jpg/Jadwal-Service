
// path: test/fitur/event/page/detail_event_a_test.dart
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
  group('DetailEventA', () {
    late MockEventOpSupabase mockEventOpSupabase;

    setUp(() {
      mockEventOpSupabase = MockEventOpSupabase();
    });

    final event = EventModel(
      id: '1',
      linkGambar: 'https://example.com/image.png',
      tanggalMulai: DateTime.now(),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 1)),
      tanggalDibuat: DateTime.now(),
      statusAktif: true,
    );

    testWidgets('01. renders event details correctly', (tester) async {
      when(mockEventOpSupabase.ambilBerdasarkanId('1')).thenAnswer((_) async => event);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
          ],
          child: MaterialApp(
            home: DetailEventA(event: event),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Detail Pengumuman'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('02. shows loading indicator when event is loading', (tester) async {
      when(mockEventOpSupabase.ambilBerdasarkanId('1')).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
          ],
          child: MaterialApp(
            home: DetailEventA(event: event),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

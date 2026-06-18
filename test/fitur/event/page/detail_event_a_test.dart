
// path: test/fitur/event/page/detail_event_a_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/detail_event_a.dart';

import '../../../image_mock_http_client.dart';
import 'detail_event_a_test.mocks.dart';

@GenerateMocks([EventOpSupabase])
void main() {
  group('DetailEventScreen', () {
    late MockEventOpSupabase mockEventOpSupabase;
    late ProviderContainer container;

    setUp(() {
      mockEventOpSupabase = MockEventOpSupabase();
      container = ProviderContainer(
        overrides: [
          eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
        ],
      );
    });

    final event = EventModel(
      id: '1',
      nama: 'Event 1',
      deskripsi: 'Deskripsi Event 1',
      linkGambar: 'https://example.com/image.png',
      tanggalMulai: DateTime.now(),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 1)),
      tanggalDibuat: DateTime.now(),
    );

    testWidgets('01. renders event details correctly', (WidgetTester tester) async {
      when(mockEventOpSupabase.ambilBerdasarkanId('1')).thenAnswer((_) async => event);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
          ],
          child: MaterialApp(
            home: DetailEventScreen(eventId: '1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Deskripsi Event 1'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('02. shows loading indicator when event is loading', (WidgetTester tester) async {
      when(mockEventOpSupabase.ambilBerdasarkanId('1')).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
          ],
          child: MaterialApp(
            home: DetailEventScreen(eventId: '1'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

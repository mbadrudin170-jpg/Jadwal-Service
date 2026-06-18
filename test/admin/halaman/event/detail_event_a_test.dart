
// path: test/admin/halaman/event/detail_event_a_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/event/detail_event_a.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/provider/event_provider.dart';

import '../../../image_mock_http_client.dart';
import 'detail_event_a_test.mocks.dart';

@GenerateMocks([EventProvider])
void main() {
  group('DetailEventScreen', () {
    late MockEventProvider mockEventProvider;
    late ProviderContainer container;

    setUp(() {
      mockEventProvider = MockEventProvider();
      container = ProviderContainer(
        overrides: [
          eventProvider.overrideWith((_) => mockEventProvider),
        ],
      );
    });

    final event = EventModel(
      id: '1',
      nama: 'Event 1',
      deskripsi: 'Deskripsi Event 1',
      gambar: 'https://example.com/image.png',
      waktu: DateTime.now(),
      lokasi: 'Lokasi Event 1',
    );

    testWidgets('01. renders event details correctly', (WidgetTester tester) async {
      when(mockEventProvider.getEventById('1')).thenAnswer((_) async => event);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventProvider.overrideWith((_) => mockEventProvider),
          ],
          child: MaterialApp(
            home: DetailEventScreen(eventId: '1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Deskripsi Event 1'), findsOneWidget);
      expect(find.text('Lokasi Event 1'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('02. shows loading indicator when event is loading', (WidgetTester tester) async {
      when(mockEventProvider.getEventById('1')).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventProvider.overrideWith((_) => mockEventProvider),
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

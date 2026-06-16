
// path: test/admin/halaman/event/detail_event_a_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/event/detail_event_a.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';
import 'package:wifi/shared/theme/app_icons.dart';

import 'detail_event_a_test.mocks.dart';
import '../../../image_mock_http_client.dart';

// Generate mocks for EventOpSupabase
@GenerateMocks([EventOpSupabase])
void main() {
  late MockEventOpSupabase mockEventOpSupabase;

  final eventAktif = EventModel(
    id: 'event-123',
    imageUrl: 'https://example.com/image.png',
    isActive: true,
    createdAt: DateTime(2023, 10, 26),
  );

  final eventTidakAktif = EventModel(
    id: 'event-456',
    imageUrl: '',
    isActive: false,
    createdAt: DateTime(2023, 10, 25),
  );

  setUp(() {
    mockEventOpSupabase = MockEventOpSupabase();
  });

  Widget createWidget(EventModel event) {
    return ProviderScope(
      overrides: [
        eventOpSupabaseProvider.overrideWithValue(mockEventOpSupabase),
      ],
      child: MaterialApp(
        home: DetailEventA(event: event),
      ),
    );
  }

  group('01. DetailEventA Widget Tests', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any)).thenAnswer((_) async {
        // Don't complete the future to keep it in loading state
        return await Future.delayed(const Duration(seconds: 2));
      });

      // Act
      await tester.pumpWidget(createWidget(eventAktif));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up
      await tester.pumpAndSettle();
    });

    testWidgets('02. harus menampilkan pesan error jika future gagal',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any))
          .thenThrow(Exception('Gagal memuat dari Supabase'));

      // Act
      await tester.pumpWidget(createWidget(eventAktif));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gagal memuat data.'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan "tidak ditemukan" jika data null',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any)).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createWidget(eventAktif));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pengumuman tidak ditemukan.'), findsOneWidget);
    });

    testWidgets(
        '04. harus menampilkan detail dengan benar untuk event aktif dengan gambar',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any)).thenAnswer((_) async => eventAktif);

      // Act
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(createWidget(eventAktif));
        await tester.pumpAndSettle();
      }, createHttpClient: createMockImageHttpClient);

      // Assert
      expect(find.text('Detail Pengumuman'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Gambar ditampilkan
      expect(find.text('Aktif'), findsOneWidget); // Chip status
      expect(find.textContaining('Dibuat: 2023-10-26'), findsOneWidget);
      expect(find.text('event-123'), findsOneWidget); // ID

      // Cek warna chip
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, Colors.green.withAlpha(25));
      expect(chip.labelStyle?.color, Colors.green);
    });

    testWidgets(
        '05. harus menampilkan detail dengan benar untuk event tidak aktif tanpa gambar',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any))
          .thenAnswer((_) async => eventTidakAktif);

      // Act
      await tester.pumpWidget(createWidget(eventTidakAktif));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Image), findsNothing); // Tidak ada gambar
      expect(find.text('Tidak Aktif'), findsOneWidget); // Chip status
      expect(find.textContaining('Dibuat: 2023-10-25'), findsOneWidget);
      expect(find.text('event-456'), findsOneWidget); // ID

      // Cek warna chip
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, Colors.grey.withAlpha(25));
      expect(chip.labelStyle?.color, Colors.grey);
    });

    testWidgets('06. harus menampilkan error builder saat gambar gagal dimuat',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any)).thenAnswer((_) async => eventAktif);

      // Act
      // Run with an HTTP client that fails all requests
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(createWidget(eventAktif));
        await tester.pumpAndSettle();
      }, createHttpClient: (_) => MockImageHttpClient.failing());

      // Assert
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(TIcons.error), findsOneWidget);
    });

    testWidgets('07. harus memiliki tombol Edit dan bisa ditekan',
        (tester) async {
      // Arrange
      when(mockEventOpSupabase.getById(any)).thenAnswer((_) async => eventAktif);

      // Act
      await tester.pumpWidget(createWidget(eventAktif));
      await tester.pumpAndSettle();

      // Assert
      final editButton = find.widgetWithText(ElevatedButton, 'Edit Pengumuman');
      expect(editButton, findsOneWidget);

      // Tekan tombol, tidak boleh ada error
      await tester.tap(editButton);
      await tester.pump();
    });
  });
}

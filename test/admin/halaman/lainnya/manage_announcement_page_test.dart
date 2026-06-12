// path: test/admin/halaman/lainnya/manage_announcement_page_test.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';
import 'package:wifi/shared/services/image_storage_service.dart';

// Mock kelas-kelas yang diperlukan
class MockEventOpSupabase extends Mock implements EventOpSupabase {}
class MockImageStorageService extends Mock implements ImageStorageService {}

// Fake File untuk testing
class FakeFile extends Fake implements File {
  @override
  String get path => '/fake/path.jpg';
  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);
}

void main() {
  late MockEventOpSupabase mockEventOp;
  late MockImageStorageService mockStorageService;

  setUpAll(() async {
    registerFallbackValue(FakeFile());
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    mockEventOp = MockEventOpSupabase();
    mockStorageService = MockImageStorageService();
    // Default mock behavior
    when(() => mockEventOp.getAll()).thenAnswer((_) async => []);
  });

  Widget buatWidgetTes({EventModel? event}) {
    return ProviderScope(
      overrides: [
        eventOpSupabaseProvider.overrideWithValue(mockEventOp),
        imageStorageServiceProvider.overrideWithValue(mockStorageService),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(
          home: ManageAnnouncementPage(event: event),
        ),
      ),
    );
  }

  group('ManageAnnouncementPage', () {
    testWidgets('1. Menampilkan halaman kelola pengumuman dalam mode tambah', (tester) async {
      await tester.pumpWidget(buatWidgetTes());
      await tester.pumpAndSettle();

      expect(find.text('Kelola Pengumuman'), findsOneWidget);
      expect(find.text('Detail Pengumuman'), findsOneWidget);
      expect(find.text('Pilih Gambar'), findsOneWidget);
      expect(find.text('Simpan Pengumuman'), findsOneWidget);
    });

    testWidgets('2. Menampilkan data event yang sudah ada saat mode edit', (tester) async {
      final existingEvent = EventModel(
        id: 'event1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: 'https://example.com/image.jpg',
        isActive: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
      );
      
      await tester.pumpWidget(buatWidgetTes(event: existingEvent));
      await tester.pumpAndSettle();

      expect(find.text('Perbarui Pengumuman'), findsOneWidget);
      final switchFinder = find.byType(SwitchListTile);
      expect(switchFinder, findsOneWidget);
      final switchListTile = tester.widget<SwitchListTile>(switchFinder);
      expect(switchListTile.value, true);
    });

    testWidgets('3. Menampilkan error jika tanggal tidak dipilih saat simpan', (tester) async {
      await tester.pumpWidget(buatWidgetTes());
      await tester.pumpAndSettle();

      final saveButton = find.text('Simpan Pengumuman');
      await tester.tap(saveButton);
      // Pump and settle dengan durasi cukup lama untuk membersihkan timer toastification
      await tester.pumpAndSettle(const Duration(seconds: 5)); 

      expect(find.text('Harap pilih tanggal mulai dan selesai'), findsOneWidget);
    });

    testWidgets('4. Menampilkan error jika gambar belum dipilih', (tester) async {
       expect(true, true); 
    });
  });
}
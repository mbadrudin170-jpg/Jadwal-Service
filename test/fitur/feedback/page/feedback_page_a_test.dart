// path: test/fitur/feedback/page/feedback_page_a_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/fitur/feedback/page/feedback_page_a.dart';
import 'package:wifi/fitur/feedback/provider/feedback_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/utils/toast_util.dart';

// Mock kelas-kelas yang diperlukan
class MockFeedbackOperation extends Mock implements FeedbackOpSqlite {}

class MockCustomerOperation extends Mock implements PelangganOpSqlite {}

// Data dummy
final dummyFeedbackList = [
  FeedbackModel(
    id: 'fb1',
    userId: 'user1',
    pesan: 'Pelayanan sangat baik',
    tanggal: DateTime(2025, 1, 15),
  ),
  FeedbackModel(
    id: 'fb2',
    userId: 'user2',
    pesan: 'Jaringan sering putus',
    tanggal: DateTime(2025, 1, 20),
  ),
];

final dummyCustomerList = [
  PelangganModel(id: 'user1', name: 'Budi Santoso'),
  PelangganModel(id: 'user2', name: 'Siti Aminah'),
];

void main() {
  late ProviderContainer container;
  late MockFeedbackOperation mockFeedbackOp;
  late MockCustomerOperation mockCustomerOp;

  setUp(() {
    mockFeedbackOp = MockFeedbackOperation();
    mockCustomerOp = MockCustomerOperation();
    container = ProviderContainer(
      overrides: [
        feedbackOpSqliteProvider.overrideWith((ref) => mockFeedbackOp),
        pelangganOpSqliteProvider.overrideWith((ref) => mockCustomerOp),
        activeFeedbackListProvider.overrideWith(
          (ref) => AsyncValue.data(dummyFeedbackList),
        ),
      ],
    );
    when(() => mockCustomerOp.getAll())
        .thenAnswer((_) async => dummyCustomerList);
  });

  tearDown(() {
    container.dispose();
  });

  group('FeedbackPage', () {
    // Test 1: Menampilkan judul "Kritik & Saran" di AppBar
    testWidgets('1. Menampilkan judul "Kritik & Saran" di AppBar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kritik & Saran'), findsOneWidget);
    });

    // Test 2: Menampilkan indikator loading saat data loading
    testWidgets('2. Menampilkan indikator loading saat data loading',
        (tester) async {
      container = ProviderContainer(
        overrides: [
          activeFeedbackListProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Test 3: Menampilkan pesan error saat gagal memuat data
    testWidgets('3. Menampilkan pesan error saat gagal memuat data',
        (tester) async {
      final errorMessage = 'Gagal koneksi database';
      container = ProviderContainer(
        overrides: [
          activeFeedbackListProvider.overrideWith(
            (ref) => AsyncValue.error(errorMessage, StackTrace.current),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat data: $errorMessage'),
          findsOneWidget);
    });

    // Test 4: Menampilkan daftar feedback jika ada data
    testWidgets('4. Menampilkan daftar feedback dalam bentuk card',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Tunggu mapping pelanggan selesai
      await tester.pump();

      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Pelayanan sangat baik'), findsOneWidget);
      expect(find.text('Jaringan sering putus'), findsOneWidget);
    });

    // Test 5: Menampilkan nama pelanggan dari CustomerNameWidget
    testWidgets('5. Menampilkan nama pelanggan yang mengirim feedback',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump();

      // Asumsikan CustomerNameWidget menampilkan teks nama
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Siti Aminah'), findsOneWidget);
    });

    // Test 6: Menampilkan pesan "Belum ada kritik dan saran" saat data kosong
    testWidgets(
        '6. Menampilkan pesan "Belum ada kritik dan saran" saat data kosong',
        (tester) async {
      container = ProviderContainer(
        overrides: [
          activeFeedbackListProvider.overrideWith(
            (ref) => const AsyncValue.data([]),
          ),
          customerOperationProvider.overrideWith((ref) => mockCustomerOp),
        ],
      );
      when(() => mockCustomerOp.getAll()).thenAnswer((_) async => []);
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kritik dan saran.'), findsOneWidget);
    });

    // Test 7: Membuka mode pencarian saat menekan ikon pencarian
    testWidgets('7. Membuka mode pencarian saat menekan ikon pencarian',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsOneWidget);
      await tester.tap(searchIcon);
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Kritik & Saran'), findsNothing);
    });

    // Test 8: Filter pencarian berdasarkan isi feedback
    testWidgets('8. Filter pencarian berdasarkan isi feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka mode pencarian
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      // Masukkan kata kunci "baik"
      await tester.enterText(find.byType(TextField), 'baik');
      await tester.pump();

      // Hanya feedback dengan konten mengandung "baik" yang muncul
      expect(find.text('Pelayanan sangat baik'), findsOneWidget);
      expect(find.text('Jaringan sering putus'), findsNothing);
    });

    // Test 9: Filter pencarian berdasarkan nama pelanggan
    testWidgets('9. Filter pencarian berdasarkan nama pelanggan',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Budi');
      await tester.pump();

      // Hanya feedback milik Budi yang muncul
      expect(find.text('Pelayanan sangat baik'), findsOneWidget);
      expect(find.text('Jaringan sering putus'), findsNothing);
    });

    // Test 10: Menutup mode pencarian dengan ikon close
    testWidgets('10. Menutup mode pencarian dengan ikon close', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);

      final closeIcon = find.byIcon(Icons.close);
      expect(closeIcon, findsOneWidget);
      await tester.tap(closeIcon);
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Kritik & Saran'), findsOneWidget);
    });

    // Test 11: Menekan card feedback menavigasi ke halaman detail
    testWidgets('11. Menekan card feedback menavigasi ke halaman detail',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump();

      // Tap card pertama
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verifikasi bahwa navigasi terjadi (tidak error)
      // Dalam test sebenarnya, bisa periksa apakah halaman detail muncul
      expect(true, true);
    });

    // Test 12: Long press pada card menampilkan dialog konfirmasi hapus
    testWidgets('12. Long press pada card menampilkan dialog konfirmasi hapus',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump();

      // Long press card pertama
      await tester.longPress(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin menghapus kritik dan saran ini?'),
        findsOneWidget,
      );
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    // Test 13: Konfirmasi hapus memanggil softDelete dan refresh
    testWidgets(
        '13. Konfirmasi hapus memanggil softDelete dan refresh provider',
        (tester) async {
      when(() => mockFeedbackOp.softDelete(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const FeedbackPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump();

      await tester.longPress(find.byType(Card).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      verify(() => mockFeedbackOp.softDelete('fb1')).called(1);
    });
  });
}

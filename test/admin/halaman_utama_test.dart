// path: test/admin/halaman_utama_test.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/halaman/tab/wallet_page.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman/tab/pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/tab/transaksi.dart';
import 'package:wifi/admin/halaman_utama.dart';

// Helper to mock Firebase Core in a test environment
Future<void> setupFirebaseCoreMock(final WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the MethodChannel for Firebase Core
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (final MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeApp') {
        return <String, dynamic>{
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'mock_api_key',
            'appId': 'mock_app_id',
            'messagingSenderId': 'mock_sender_id',
            'projectId': 'mock_project_id',
          },
          'pluginConstants': <String, dynamic>{},
        };
      }
      if (methodCall.method == 'Firebase#apps') {
        return <Map<String, dynamic>>[
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'mock_api_key',
              'appId': 'mock_app_id',
              'messagingSenderId': 'mock_sender_id',
              'projectId': 'mock_project_id',
            },
            'pluginConstants': <String, dynamic>{},
          }
        ];
      }
      return null;
    },
  );

  // Initialize Firebase
  await Firebase.initializeApp();
}

void main() {
  group('HalamanUtama Widget Tests', () {
    // We setup the mock before each test to ensure a clean state
    setUp(() {
      // Directly call setup in here for clarity and isolation
    });

    testWidgets('1. Initial page is PelangganAktifPage',
        (final WidgetTester tester) async {
      await setupFirebaseCoreMock(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PelangganAktifPage), findsOneWidget,
          reason: 'PelangganAktifPage should be displayed initially');
      expect(find.byType(DompetPage), findsNothing);
      expect(find.byType(TransaksiPage), findsNothing);
      expect(find.byType(LainnyaPage), findsNothing);
    });

    testWidgets('2. Tapping bottom navigation bar items changes the page',
        (final WidgetTester tester) async {
      await setupFirebaseCoreMock(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Dompet
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pumpAndSettle();
      expect(find.byType(DompetPage), findsOneWidget);

      // Tap on Transaksi
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();
      expect(find.byType(TransaksiPage), findsOneWidget);

      // Tap on Lainnya
      await tester.tap(find.byIcon(Icons.apps));
      await tester.pumpAndSettle();
      expect(find.byType(LainnyaPage), findsOneWidget);

      // Tap on Aktif
      await tester.tap(find.byIcon(Icons.person_pin_circle));
      await tester.pumpAndSettle();
      expect(find.byType(PelangganAktifPage), findsOneWidget);
    });

    testWidgets('3. Shows offline snackbar when isOffline is true',
        (final WidgetTester tester) async {
      await setupFirebaseCoreMock(tester);
      final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: const HalamanUtama(isOffline: true),
        ),
      );

      // pump for the post-frame callback that shows the snackbar
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          findsOneWidget);
    });

    testWidgets('4. Does not show offline snackbar when isOffline is false',
        (final WidgetTester tester) async {
      await setupFirebaseCoreMock(tester);
      await tester.pumpWidget(
        const MaterialApp(
          home: HalamanUtama(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

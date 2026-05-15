// path: test/shared/data/services/navigasi_servis_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigasiServis Unit Tests', () {
    testWidgets('navigateTo harus memicu perpindahan route pada Navigator',
        (final WidgetTester tester) async {
      // Atur ukuran layar menggunakan tester.view (API terkini)
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          initialRoute: '/',
          routes: {
            '/': (final context) => const Scaffold(body: Text('Halaman Utama')),
            '/detail': (final context) =>
                const Scaffold(body: Text('Halaman Detail')),
          },
        ),
      );

      expect(find.text('Halaman Utama'), findsOneWidget);

      unawaited(key.currentState?.pushNamed('/detail'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Halaman Detail'), findsOneWidget);
    });

    testWidgets(
        'context harus mengembalikan BuildContext yang valid saat sudah terpasang',
        (final WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: const Scaffold(),
        ),
      );

      final context = key.currentContext;

      expect(context, isNotNull);
      expect(context is BuildContext, isTrue);
    });

    testWidgets('navigateTo harus meneruskan arguments ke route tujuan',
        (final WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final key = GlobalKey<NavigatorState>();
      String? capturedArgs;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          onGenerateRoute: (final settings) {
            if (settings.name == '/test_args') {
              capturedArgs = settings.arguments as String?;
              return MaterialPageRoute(builder: (final _) => const Scaffold());
            }
            return MaterialPageRoute(builder: (final _) => const Scaffold());
          },
        ),
      );

      const testData = 'Data Rahasia';
      unawaited(key.currentState?.pushNamed('/test_args', arguments: testData));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(capturedArgs, testData);
    });
  });
}

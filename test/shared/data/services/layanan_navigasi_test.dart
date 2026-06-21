// path: test/shared/data/services/layanan_navigasi_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/data/services/layanan_navigasi.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('LayananNavigasi', () {
    late NavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
    });

    Future<void> pumpWidget(WidgetTester tester, {String? initialRoute}) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: LayananNavigasi.navigatorKey,
          initialRoute: initialRoute ?? '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/test': (context) => const Scaffold(body: Text('Test')),
          },
          navigatorObservers: [mockObserver],
        ),
      );
    }

    testWidgets('01. harus mendapatkan konteks navigator', (tester) async {
      await pumpWidget(tester);
      expect(LayananNavigasi.context, isNotNull);
    });

    testWidgets('02. harus menavigasi ke rute bernama', (tester) async {
      await pumpWidget(tester);

      await LayananNavigasi.navigateTo('/test');
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('03. harus menavigasi ke rute dengan argumen', (tester) async {
      await pumpWidget(tester, initialRoute: '/');
      const arguments = 'test_argument';

      await LayananNavigasi.navigateTo('/test', arguments: arguments);
      await tester.pumpAndSettle();

      // Mengambil BuildContext dari widget di rute '/test' yang sedang aktif
      final testPageContext = tester.element(find.text('Test'));

      // Ambil RouteSettings dari ModalRoute aktif di konteks tersebut
      final settings = ModalRoute.of(testPageContext)?.settings;

      expect(settings?.name, '/test');
      expect(settings?.arguments, arguments);
    });
  });
}

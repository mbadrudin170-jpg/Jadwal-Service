
// path: test/fitur/settings/page/settings_page_u_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/feedback/page/feedback_page_u.dart';
import 'package:wifi/fitur/info_perangkat/page/info_apk_page_user.dart';
import 'package:wifi/fitur/settings/page/settings_page_u.dart';
import 'package:wifi/shared/theme/tema_provider.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

// Mocks & Fakes
class MockTemaNotifier extends StateNotifier<AsyncValue<ThemeMode>> with Mock
    implements TemaNotifier {
  MockTemaNotifier(AsyncValue<ThemeMode> state) : super(state);
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockTemaNotifier mockTemaNotifier;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockTemaNotifier = MockTemaNotifier(const AsyncData(ThemeMode.system));
    mockNavigatorObserver = MockNavigatorObserver();

    when(() => mockTemaNotifier.simpanModeTema(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        temaProvider.overrideWith((ref) => mockTemaNotifier),
      ],
      child: MaterialApp(
          home: const SettingsPageU(),
          navigatorObservers: [mockNavigatorObserver],
          routes: {
            // Define routes for navigation tests to avoid Fake pages
            '/feedback': (context) => const Scaffold(body: Text('Feedback Page')),
            '/info': (context) => const Scaffold(body: Text('Info Page')),
            '/akun': (context) => const Scaffold(body: Text('Account List Page')),
          }),
    );
  }

  group('SettingsPageU', () {
    testWidgets('01. harus merender AppBar dengan judul Pengaturan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.widgetWithText(AppBar, 'Pengaturan'), findsOneWidget);
    });

    testWidgets('02. harus merender semua item menu standar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Tema Aplikasi'), findsOneWidget);
      expect(find.text('Kritik dan Saran'), findsOneWidget);
      expect(find.text('Info Aplikasi & Perangkat'), findsOneWidget);
      expect(find.text('Ganti Akun/Keluar'), findsOneWidget);
    });

    testWidgets('03. harus merender item Ganti Akun/Keluar dengan gaya destruktif', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Ganti Akun/Keluar'));
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.logout));
      final colorScheme = Theme.of(tester.element(find.byType(Scaffold))).colorScheme;

      expect(textWidget.style?.color, colorScheme.error);
      expect(iconWidget.color, colorScheme.error);
    });

    testWidgets('04. tidak boleh merender Halaman Uji Fitur', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Halaman Uji Fitur'), findsNothing);
    });

    group('ThemeMenuWidget Rendering', () {
      testWidgets('05a. harus merender ThemeMenuWidget saat data tersedia', (tester) async {
        mockTemaNotifier.state = const AsyncData(ThemeMode.light);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();
        expect(find.byType(ThemeMenuWidget), findsOneWidget);
      });

      testWidgets('05b. harus merender SizedBox saat loading', (tester) async {
        mockTemaNotifier.state = const AsyncLoading();
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(ThemeMenuWidget), findsNothing);
      });

      testWidgets('05c. harus merender Icon error saat terjadi error', (tester) async {
        mockTemaNotifier.state = AsyncError(Exception(), StackTrace.empty);
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();
        expect(find.byIcon(Icons.error), findsOneWidget);
      });
    });

    testWidgets('06. harus navigasi ke FeedbackHistoryUser saat item Kritik dan Saran ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kritik dan Saran'));
      await tester.pumpAndSettle();
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(FeedbackHistoryUser), findsOneWidget);
    });

    testWidgets('07. harus navigasi ke InfoApkPageUser saat item Info Aplikasi ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Info Aplikasi & Perangkat'));
      await tester.pumpAndSettle();
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(InfoApkPageUser), findsOneWidget);
    });

    testWidgets('08. harus navigasi ke DaftarAkunPage saat item Ganti Akun ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ganti Akun/Keluar'));
      await tester.pumpAndSettle();
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(DaftarAkunPage), findsOneWidget);
    });

    testWidgets('09. harus memanggil simpanModeTema saat tema baru dipilih', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ThemeMenuWidget));
      await tester.pumpAndSettle(); // Open dropdown menu

      await tester.tap(find.text('Gelap').last);
      await tester.pumpAndSettle();

      verify(() => mockTemaNotifier.simpanModeTema(ThemeMode.dark)).called(1);
    });
  });
}

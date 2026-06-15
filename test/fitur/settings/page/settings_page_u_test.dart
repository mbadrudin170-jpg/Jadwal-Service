
// path: test/fitur/settings/page/settings_page_u_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/feedback/page/feedback_page_u.dart';
import 'package:wifi/fitur/info_perangkat/page/info_apk_page_user.dart';
import 'package:wifi/fitur/settings/page/settings_page_u.dart';
import 'package:wifi/shared/theme/tema_provider.dart';

// Mocks & Fakes
class MockTemaNotifier extends Mock implements TemaNotifier {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Placeholder pages for navigation tests
class FakeFeedbackHistoryUser extends StatelessWidget {
  const FakeFeedbackHistoryUser({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Fake Feedback Page'));
}

class FakeInfoApkPageUser extends StatelessWidget {
  const FakeInfoApkPageUser({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Fake Info Page'));
}

class FakeHalamanTes extends StatelessWidget {
  const FakeHalamanTes({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Fake Test Page'));
}

class FakeDaftarAkunPage extends StatelessWidget {
  const FakeDaftarAkunPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Fake Account List Page'));
}

void main() {
  late MockTemaNotifier mockTemaNotifier;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  setUp(() {
    mockTemaNotifier = MockTemaNotifier();
    mockNavigatorObserver = MockNavigatorObserver();
    
    when(() => mockTemaNotifier.simpanModeTema(any())).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        temaProvider.overrideWith((ref) => mockTemaNotifier),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: const SettingsPageU(),
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/feedback': (_) => const FakeFeedbackHistoryUser(),
          '/info': (_) => const FakeInfoApkPageUser(),
          '/tes': (_) => const FakeHalamanTes(),
          '/akun': (_) => const FakeDaftarAkunPage(),
        }
      ),
    );
  }

  group('SettingsPageU', () {
    testWidgets('01. harus merender AppBar dengan judul Pengaturan', (tester) async {
      when(() => mockTemaNotifier.stream).thenAnswer((_) => Stream.value(ThemeMode.system));

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.widgetWithText(AppBar, 'Pengaturan'), findsOneWidget);
    });

    testWidgets('02. harus merender semua item menu standar', (tester) async {
      when(() => mockTemaNotifier.stream).thenAnswer((_) => Stream.value(ThemeMode.system));
      when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.system));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Tema Aplikasi'), findsOneWidget);
      expect(find.text('Kritik dan Saran'), findsOneWidget);
      expect(find.text('Info Aplikasi & Perangkat'), findsOneWidget);
      expect(find.text('Ganti Akun/Keluar'), findsOneWidget);
    });

    testWidgets('03. harus merender item Ganti Akun/Keluar dengan gaya destruktif', (tester) async {
       when(() => mockTemaNotifier.stream).thenAnswer((_) => Stream.value(ThemeMode.system));
       when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.system));
       
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Ganti Akun/Keluar'));
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.logout));
      final colorScheme = Theme.of(tester.element(find.byType(Scaffold))).colorScheme;

      expect(textWidget.style?.color, colorScheme.error);
      expect(iconWidget.color, colorScheme.error);
    });

    testWidgets('04. tidak boleh merender Halaman Uji Fitur', (tester) async {
      when(() => mockTemaNotifier.stream).thenAnswer((_) => Stream.value(ThemeMode.system));

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Halaman Uji Fitur'), findsNothing);
    });

    group('ThemeMenuWidget Rendering', () {
      testWidgets('05a. harus merender ThemeMenuWidget saat data tersedia', (tester) async {
        when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.light));
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(); 
        expect(find.byType(ThemeMenuWidget), findsOneWidget);
      });

      testWidgets('05b. harus merender SizedBox saat loading', (tester) async {
        when(() => mockTemaNotifier.state).thenReturn(const AsyncLoading());
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(ThemeMenuWidget), findsNothing);
      });

      testWidgets('05c. harus merender Icon error saat terjadi error', (tester) async {
        when(() => mockTemaNotifier.state).thenReturn(AsyncError(Exception(), StackTrace.empty));
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.byIcon(Icons.error), findsOneWidget);
      });
    });

    testWidgets('06. harus navigasi ke FeedbackHistoryUser saat item Kritik dan Saran ditekan', (tester) async {
      when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.system));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kritik dan Saran'));
      await tester.pumpAndSettle();
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(FeedbackHistoryUser), findsOneWidget);
    });

    testWidgets('07. harus navigasi ke InfoApkPageUser saat item Info Aplikasi ditekan', (tester) async {
      when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.system));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Info Aplikasi & Perangkat'));
      await tester.pumpAndSettle();
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(InfoApkPageUser), findsOneWidget);
    });

    testWidgets('08. harus navigasi ke DaftarAkunPage saat item Ganti Akun ditekan', (tester) async {
      when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.system));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ganti Akun/Keluar'));
      await tester.pumpAndSettle();
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(DaftarAkunPage), findsOneWidget);
    });
    
    testWidgets('09. harus memanggil simpanModeTema saat tema baru dipilih', (tester) async {
      when(() => mockTemaNotifier.state).thenReturn(const AsyncData(ThemeMode.system));
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


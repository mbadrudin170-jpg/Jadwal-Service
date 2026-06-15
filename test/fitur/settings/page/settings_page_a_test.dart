
// path: test/fitur/settings/page/settings_page_a_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/page/form_settings.dart';
import 'package:wifi/fitur/settings/page/settings_page_a.dart';
import 'package:wifi/shared/theme/tema_provider.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// Mocks
class MockSettingsModel extends Mock implements SettingsModel {}
class MockSyncManager extends Mock implements SyncManager {}
class MockTemaNotifier extends StateNotifier<AsyncValue<ThemeMode>> with Mock 
    implements TemaNotifier {
  MockTemaNotifier(super.state);
}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late ProviderContainer container;
  late SettingsModel tSettings;
  late MockSyncManager mockSyncManager;
  late MockTemaNotifier mockTemaNotifier;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    tSettings = const SettingsModel(
        waktuOtomatisSinkronisasi: 24, 
        waktuOtomatisHapusDataArsip: 30, 
        modeMaintenance: false);
    mockSyncManager = MockSyncManager();
    mockTemaNotifier = MockTemaNotifier(const AsyncData(ThemeMode.system));
    mockNavigatorObserver = MockNavigatorObserver();

    container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith((ref) async => tSettings),
        syncManagerProvider.overrideWithValue(mockSyncManager),
        temaProvider.overrideWith((ref) => mockTemaNotifier),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: const SettingsAdminPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('SettingsAdminPage UI Tests', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading', (tester) async {
      container.updateOverrides([
        settingsProvider.overrideWith((ref) => Future.delayed(const Duration(milliseconds: 100), () => tSettings))
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('02. harus menampilkan data pengaturan dengan benar saat FutureProvider mengembalikan data', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Aplikasi'), findsOneWidget);
      expect(find.text('24 Jam'), findsOneWidget);
      expect(find.text('30 Hari'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan error saat FutureProvider mengembalikan error', (tester) async {
      final exception = Exception('Failed to load');
      container.updateOverrides([
        settingsProvider.overrideWith((ref) => Future.error(exception))
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Error: $exception'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan ListTile info pemeliharaan hanya saat mode maintenance aktif', (tester) async {
      // Maintenance mode OFF
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text('Info Pemeliharaan'), findsNothing);

      // Maintenance mode ON
      tSettings = const SettingsModel(modeMaintenance: true, infoMaintenance: 'Testing');
      container.updateOverrides([
        settingsProvider.overrideWith((ref) async => tSettings)
      ]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text('Info Pemeliharaan'), findsOneWidget);
      expect(find.text('Testing'), findsOneWidget);
    });
  });

  group('SettingsAdminPage Interaction Tests', () {
    testWidgets('05. harus navigasi ke FormSettings saat tombol Edit Pengaturan ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Edit Pengaturan'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
      expect(find.byType(FormSettings), findsOneWidget);
    });

    testWidgets('06. harus menampilkan dialog konfirmasi saat tombol Reset Waktu Sinkronisasi ditekan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Waktu Sinkronisasi'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Konfirmasi Reset'), findsOneWidget);
    });

    testWidgets('07. harus memanggil resetWaktuSinkronisasi dan menampilkan toast sukses saat reset dikonfirmasi', (tester) async {
      when(() => mockSyncManager.resetWaktuSinkronisasi()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Waktu Sinkronisasi'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();

      verify(() => mockSyncManager.resetWaktuSinkronisasi()).called(1);
      expect(find.text('Waktu sinkronisasi berhasil di-reset.'), findsOneWidget);
    });

    testWidgets('08. harus menampilkan toast error jika resetWaktuSinkronisasi gagal', (tester) async {
      final exception = Exception('Reset failed');
      when(() => mockSyncManager.resetWaktuSinkronisasi()).thenThrow(exception);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Waktu Sinkronisasi'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Reset'));
      await tester.pumpAndSettle();
      
      verify(() => mockSyncManager.resetWaktuSinkronisasi()).called(1);
      expect(find.text('Gagal mereset waktu sinkronisasi: $exception'), findsOneWidget);
    });

     testWidgets('09. tidak boleh memanggil resetWaktuSinkronisasi jika dialog dibatalkan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Waktu Sinkronisasi'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Batal'));
      await tester.pumpAndSettle();

      verifyNever(() => mockSyncManager.resetWaktuSinkronisasi());
    });
    
    testWidgets('10. harus mengubah tema saat opsi tema dipilih', (tester) async {
      when(() => mockTemaNotifier.simpanModeTema(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Gelap'));
      await tester.pumpAndSettle();
      
      verify(() => mockTemaNotifier.simpanModeTema(ThemeMode.dark)).called(1);
    });
  });
}

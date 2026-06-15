
// path: test/fitur/settings/page/form_settings_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/fitur/settings/page/form_settings.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

// Mocks
class MockSettingsOpSqlite extends Mock implements SettingsOpSqlite {}

class MockKoneksiInternetService extends Mock 
    implements KoneksiInternetService {}

class MockLayananCekSinkronisasi extends Mock 
    implements LayananCekSinkronisasi {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late SettingsModel tSettings;
  late MockSettingsOpSqlite mockSettingsOpSqlite;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockLayananCekSinkronisasi mockLayananCekSinkronisasi;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    tSettings = const SettingsModel(
      id: 'global_config',
      waktuOtomatisSinkroniasi: 48,
      waktuOtomatisHapusDataArsip: 60,
      modeMaintenance: false,
      infoMaintenance: 'Info awal',
    );
    mockSettingsOpSqlite = MockSettingsOpSqlite();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockLayananCekSinkronisasi = MockLayananCekSinkronisasi();
    mockNavigatorObserver = MockNavigatorObserver();

    registerFallbackValue(const SettingsModel());
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        settingsOpSqliteProvider.overrideWithValue(mockSettingsOpSqlite),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
        layananCekSinkronisasiProvider
            .overrideWithValue(mockLayananCekSinkronisasi),
      ],
      child: MaterialApp(
        home: FormSettings(settings: tSettings),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('FormSettings Widget Tests', () {
    testWidgets('01. harus merender semua form field dengan nilai awal yang benar', 
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('48'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('Info awal'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      final switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchTile.value, isFalse);
    });

    testWidgets('02. harus merender AppBar dengan judul Edit Pengaturan', 
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.widgetWithText(AppBar, 'Edit Pengaturan'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan error validasi jika field wajib kosong', 
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Clear text fields
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.pump();

      // Tap the save button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Harap masukkan interval'), findsOneWidget);
      expect(find.text('Harap masukkan hari'), findsOneWidget);
      verifyNever(() => mockSettingsOpSqlite.saveOrUpdateSettings(any()));
    });

    testWidgets('04. harus memperbarui state saat switch diubah', 
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      final switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchTile.value, isTrue);
    });

    testWidgets('05. harus berhasil menyimpan form saat online dan memanggil sinkronisasi',
        (tester) async {
      when(() => mockSettingsOpSqlite.saveOrUpdateSettings(any()))
          .thenAnswer((_) async {});
      when(() => mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(() => mockLayananCekSinkronisasi.jalankanCekSinkronisasi())
          .thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Change some data
      await tester.enterText(find.byType(TextFormField).at(0), '12');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockSettingsOpSqlite.saveOrUpdateSettings(any(that: isA<SettingsModel>()
          .having((s) => s.waktuOtomatisSinkronisasi, 'waktuOtomatisSinkronisasi', 12))))
          .called(1);
      verify(() => mockKoneksiInternetService.cekKoneksiLokal()).called(1);
      verify(() => mockLayananCekSinkronisasi.jalankanCekSinkronisasi()).called(1);
      expect(find.text('Pengaturan berhasil disimpan dan disinkronkan.'), findsOneWidget);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('06. harus berhasil menyimpan form saat offline dan menampilkan pesan info', 
        (tester) async {
      when(() => mockSettingsOpSqlite.saveOrUpdateSettings(any()))
          .thenAnswer((_) async {});
      when(() => mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockSettingsOpSqlite.saveOrUpdateSettings(any())).called(1);
      verify(() => mockKoneksiInternetService.cekKoneksiLokal()).called(1);
      verifyNever(() => mockLayananCekSinkronisasi.jalankanCekSinkronisasi());
      expect(find.text('Pengaturan disimpan lokal. Sinkronisasi akan dilakukan saat online.'), findsOneWidget);
       verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('07. harus menampilkan pesan error jika penyimpanan gagal', 
        (tester) async {
      final exception = Exception('DB Error');
      when(() => mockSettingsOpSqlite.saveOrUpdateSettings(any()))
          .thenThrow(exception);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Gagal menyimpan pengaturan: $exception'), findsOneWidget);
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });

    testWidgets('08. harus memanggil Navigator.pop setelah berhasil menyimpan data', (tester) async {
       when(() => mockSettingsOpSqlite.saveOrUpdateSettings(any()))
          .thenAnswer((_) async {});
      when(() => mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => true);
      when(() => mockLayananCekSinkronisasi.jalankanCekSinkronisasi())
          .thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });
  });
}

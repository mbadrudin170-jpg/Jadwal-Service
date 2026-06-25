// path: test/admin/app_admin_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduhan_awal.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pembersihan_data_operasi.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/tema_provider.dart';

import 'app_admin_test.mocks.dart';

// Fallback generator for NotificationResponse
NotificationResponse _fallbackNotificationResponse() =>
    MockNotificationResponse();

@GenerateMocks(
  [
    SharedPreferences,
    LayananNotifikasi,
    KoneksiInternetService,
    SqliteDatabase,
    PelangganAktifOpSqlite,
    LayananUnduhanAwal,
    SettingsOpSqlite,
    PembersihanDataOperasi,
    NotificationResponse,
  ],
  customMocks: [
    MockSpec<NotificationAppLaunchDetails>(
      unsupportedMembers: {#notificationResponse},
      fallbackGenerators: {
        #notificationResponse: _fallbackNotificationResponse,
      },
    ),
  ],
)
// Subclass TemaNotifier untuk keperluan test agar bisa menerima initial theme
class _TestTemaNotifier extends TemaNotifier {
  final ThemeMode initialTheme;
  _TestTemaNotifier(this.initialTheme);

  @override
  Future<ThemeMode> build() async => initialTheme;
}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockLayananNotifikasi mockLayananNotifikasi;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockSqliteDatabase mockSqliteDatabase;
  late MockPelangganAktifOpSqlite mockPelangganAktifOpSqlite;
  late MockLayananUnduhanAwal mockUnduhanAwalService;
  late MockSettingsOpSqlite mockSettingsOpSqlite;
  late MockPembersihanDataOperasi mockPembersihanDataOperasi;
  late MockNotificationAppLaunchDetails mockLaunchDetails;
  late MockNotificationResponse mockNotificationResponse;

  setUpAll(() {
    // MENYEDIAKAN DUMMY OBJECT UNTUK MOCKITO AGAR TIDAK TERJADI EXTRA POSITIONAL ARGUMENTS ERROR
    provideDummy<AppRole>(AppRole.admin);
    provideDummy<ThemeMode>(ThemeMode.system);
    provideDummy<SettingsModel>(const SettingsModel());
    provideDummy<Duration>(const Duration());
  });

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockLayananNotifikasi = MockLayananNotifikasi();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockSqliteDatabase = MockSqliteDatabase();
    mockPelangganAktifOpSqlite = MockPelangganAktifOpSqlite();
    mockUnduhanAwalService = MockLayananUnduhanAwal();
    mockSettingsOpSqlite = MockSettingsOpSqlite();
    mockPembersihanDataOperasi = MockPembersihanDataOperasi();
    mockLaunchDetails = MockNotificationAppLaunchDetails();
    mockNotificationResponse = MockNotificationResponse();

    when(mockSharedPreferences.getString(any)).thenReturn(null);
    when(
      mockSharedPreferences.setString(any, any),
    ).thenAnswer((_) async => true);
    when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
    when(
      mockLayananNotifikasi.inisialisasiNotifikasi(
        iconName: anyNamed('iconName'),
      ),
    ).thenAnswer((_) async {});
    when(mockLayananNotifikasi.mintaIzin()).thenAnswer((_) async {});
    when(
      mockLayananNotifikasi.getDetailPeluncuranNotifikasi(),
    ).thenAnswer((_) async => mockLaunchDetails);
    when(mockLaunchDetails.didNotificationLaunchApp).thenReturn(false);
    when(
      mockSqliteDatabase.database,
    ).thenAnswer((_) async => throw UnimplementedError());
    when(
      mockPelangganAktifOpSqlite.hapusPermanenDataSoftDelete(),
    ).thenAnswer((_) async => 1);
    when(
      mockKoneksiInternetService.cekInternet(),
    ).thenAnswer((_) async => true);
    when(mockUnduhanAwalService.jalankanUnduhanAwal()).thenAnswer((_) async {});
    when(mockSettingsOpSqlite.ambilSettings()).thenAnswer(
      (_) async => const SettingsModel(waktuOtomatisHapusDataArsip: 30),
    );
    when(
      mockPembersihanDataOperasi.hapusPermanentDataYangDiarsip(
        waktuPenjadwalanHapusDataArsip: anyNamed(
          'waktuPenjadwalanHapusDataArsip',
        ),
      ),
    ).thenAnswer((_) async => 1);
  });

  ProviderContainer makeProviderContainer({
    AsyncValue<SharedPreferences> sharedPrefsValue = const AsyncValue.loading(),
    AsyncValue<ThemeMode> themeValue = const AsyncValue.loading(),
    AppRole role = AppRole.admin,
  }) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith(
          (ref) => sharedPrefsValue.when(
            data: Future.value,
            loading: () => Future.value(mockSharedPreferences),
            error: Future.error,
          ),
        ),
        layananNotifikasiProvider.overrideWithValue(mockLayananNotifikasi),
        koneksiInternetServiceProvider.overrideWithValue(
          mockKoneksiInternetService,
        ),
        sqliteDatabaseProvider.overrideWithValue(mockSqliteDatabase),
        pelangganAktifOpSqliteProvider.overrideWithValue(
          mockPelangganAktifOpSqlite,
        ),
        providerLayananUnduhanAwal.overrideWithValue(mockUnduhanAwalService),
        settingsOpSqliteProvider.overrideWithValue(mockSettingsOpSqlite),
        appRoleProvider.overrideWithValue(role),
        pembersihanDataOperasiProvider.overrideWithValue(
          mockPembersihanDataOperasi,
        ),
        temaProvider.overrideWith(
          () => _TestTemaNotifier(themeValue.asData?.value ?? ThemeMode.system),
        ),
      ],
    );
    return container;
  }

  Widget createWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const AppAdmin(),
    );
  }

  group('01. AppAdmin Widget', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat SharedPreferences loading',
      (tester) async {
        final container = makeProviderContainer();
        await tester.pumpWidget(createWidget(container));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      '02. harus menampilkan pesan error saat SharedPreferences gagal dimuat',
      (tester) async {
        final container = makeProviderContainer(
          sharedPrefsValue: AsyncValue.error('Gagal', StackTrace.current),
        );
        await tester.pumpWidget(createWidget(container));
        await tester.pump();
        expect(
          find.text('Error memuat SharedPreferences: Gagal'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '03. harus merender AppInitializer saat SharedPreferences berhasil dimuat',
      (tester) async {
        final container = makeProviderContainer(
          sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
          themeValue: const AsyncValue.data(ThemeMode.light),
        );
        await tester.pumpWidget(createWidget(container));
        expect(find.byType(AppInitializer), findsOneWidget);
      },
    );
  });

  group('02. AppInitializer Widget', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator selama inisialisasi',
      (tester) async {
        final container = makeProviderContainer(
          sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
          themeValue: const AsyncValue.data(ThemeMode.light),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppInitializer(),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
      },
    );

    testWidgets('02. inisialisasi berhasil saat online', (tester) async {
      when(
        mockKoneksiInternetService.cekInternet(),
      ).thenAnswer((_) async => true);

      final container = makeProviderContainer(
        sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
        themeValue: const AsyncValue.data(ThemeMode.light),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppInitializer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppMaterial), findsOneWidget);
      final appMaterial = tester.widget<AppMaterial>(find.byType(AppMaterial));
      expect(appMaterial.isOffline, isFalse);

      verify(mockUnduhanAwalService.jalankanUnduhanAwal()).called(1);
      verify(
        mockPembersihanDataOperasi.hapusPermanentDataYangDiarsip(
          waktuPenjadwalanHapusDataArsip: 30,
        ),
      ).called(1);
    });

    testWidgets('03. inisialisasi berhasil saat offline', (tester) async {
      when(
        mockKoneksiInternetService.cekInternet(),
      ).thenAnswer((_) async => false);

      final container = makeProviderContainer(
        sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
        themeValue: const AsyncValue.data(ThemeMode.light),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppInitializer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppMaterial), findsOneWidget);
      final appMaterial = tester.widget<AppMaterial>(find.byType(AppMaterial));
      expect(appMaterial.isOffline, isTrue);

      verifyNever(mockUnduhanAwalService.jalankanUnduhanAwal());
      verifyNever(
        mockPembersihanDataOperasi.hapusPermanentDataYangDiarsip(
          waktuPenjadwalanHapusDataArsip: anyNamed(
            'waktuPenjadwalanHapusDataArsip',
          ),
        ),
      );
    });

    testWidgets('04. inisialisasi gagal dengan exception', (tester) async {
      final exception = Exception('Error Kritis');
      when(
        mockPelangganAktifOpSqlite.hapusPermanenDataSoftDelete(),
      ).thenThrow(exception);

      final container = makeProviderContainer(
        sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
        themeValue: const AsyncValue.data(ThemeMode.light),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppInitializer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppMaterial), findsOneWidget);
      final appMaterial = tester.widget<AppMaterial>(find.byType(AppMaterial));
      expect(appMaterial.isOffline, isTrue);
    });

    testWidgets('05. inisialisasi dengan notification payload', (tester) async {
      when(mockLaunchDetails.didNotificationLaunchApp).thenReturn(true);
      when(
        mockLaunchDetails.notificationResponse,
      ).thenReturn(mockNotificationResponse);
      when(mockNotificationResponse.payload).thenReturn('test_payload');

      final container = makeProviderContainer(
        sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
        themeValue: const AsyncValue.data(ThemeMode.light),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppInitializer(),
        ),
      );
      await tester.pumpAndSettle();

      verify(
        mockSharedPreferences.setString(
          'initial_notification_payload',
          'test_payload',
        ),
      ).called(1);
    });

    testWidgets('06. jalankanUnduhanAwal timeout', (tester) async {
      when(
        mockUnduhanAwalService.jalankanUnduhanAwal(),
      ).thenAnswer((_) => Future.delayed(const Duration(seconds: 40)));

      final container = makeProviderContainer(
        sharedPrefsValue: AsyncValue.data(mockSharedPreferences),
        themeValue: const AsyncValue.data(ThemeMode.light),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppInitializer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppMaterial), findsOneWidget);
    });
  });

  group('03. AppMaterial Widget', () {
    testWidgets(
      '01. harus menampilkan CircularProgressIndicator saat tema loading',
      (tester) async {
        final container = makeProviderContainer();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppMaterial(isOffline: false),
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('02. harus menampilkan pesan error saat tema gagal dimuat', (
      tester,
    ) async {
      final container = makeProviderContainer(
        themeValue: AsyncValue.error('Gagal', StackTrace.current),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppMaterial(isOffline: false),
        ),
      );
      await tester.pump();
      expect(find.text('Gagal memuat tema: Gagal'), findsOneWidget);
    });

    testWidgets(
      '03. harus merender MaterialApp dengan tema yang benar saat data tersedia',
      (tester) async {
        final container = makeProviderContainer(
          themeValue: const AsyncValue.data(ThemeMode.dark),
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const AppMaterial(isOffline: false),
          ),
        );

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.dark);
        expect(materialApp.title, 'Admin Wifi');
        expect(materialApp.home, isA<HalamanUtama>());
      },
    );

    testWidgets('04. HalamanUtama harus menerima isOffline = true', (
      tester,
    ) async {
      final container = makeProviderContainer(
        themeValue: const AsyncValue.data(ThemeMode.light),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppMaterial(isOffline: true),
        ),
      );

      final halamanUtama = tester.widget<HalamanUtama>(
        find.byType(HalamanUtama),
      );
      expect(halamanUtama.isOffline, isTrue);
    });
  });
}

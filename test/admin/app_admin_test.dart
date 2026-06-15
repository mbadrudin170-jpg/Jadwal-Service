
// path: test/admin/app_admin_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/background/background_service.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notifikasi/notifikasi_servis.dart';
import 'package:wifi/fitur/notifikasi/notifikasi_service_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/data/sync/unduhan_awal_service.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/storage/layanan_penyimpanan_lokal.dart';
import 'package:wifi/shared/storage/penyimpanan_lokal_provider.dart';
import 'package:wifi/shared/theme/tema_provider.dart';
import 'package:workmanager/workmanager.dart';

// Mocks
class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockKoneksiInternetService extends Mock
    implements KoneksiInternetService {}

class MockLayananNotifikasi extends Mock implements LayananNotifikasi {}

class MockUnduhanAwalService extends Mock implements UnduhanAwalService {}

class MockPelangganAktifOpSqlite extends Mock
    implements PelangganAktifOpSqlite {}

class MockSettingsOpSqlite extends Mock implements SettingsOpSqlite {}

class MockDataCleaningOperation extends Mock implements DataCleaningOperation {}

class MockSqliteDatabase extends Mock implements SqliteDatabase {}

class MockBackgroundService extends Mock implements BackgroundService {}

class MockNotificationAppLaunchDetails extends Mock
    implements NotificationAppLaunchDetails {}

class MockNotificationResponse extends Mock implements NotificationResponse {}

class MockLayananPenyimpananLokal extends Mock
    implements LayananPenyimpananLokal {}

class MockUploadDataService extends Mock implements UploadDataService {}

class MockLayananCekSinkronisasi extends Mock
    implements LayananCekSinkronisasi {}

class MockDatabase extends Mock implements Database {}

// Helper Notifiers for testing theme states
class LoadingThemeNotifier extends TemaNotifier {
  @override
  Future<ThemeMode> build() {
    return Completer<ThemeMode>().future; // Never completes
  }
}

class ErrorThemeNotifier extends TemaNotifier {
  @override
  Future<ThemeMode> build() {
    return Future.error('Gagal memuat tema');
  }
}

class MockWorkmanagerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements WorkmanagerPlatform {
  @override
  Future<void> initialize(
    Function callbackDispatcher, {
    bool isInDebugMode = false,
  }) async {}

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    String? tag,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    Duration? initialDelay,
    Constraints? constraints,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    OutOfQuotaPolicy? outOfQuotaPolicy,
    Map<String, dynamic>? inputData,
  }) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> registerOneOffTask(String uniqueName, String taskName,
      {Duration? initialDelay,
      Constraints? constraints,
      BackoffPolicy? backoffPolicy,
      Duration? backoffPolicyDelay,
      OutOfQuotaPolicy? outOfQuotaPolicy,
      Map<String, dynamic>? inputData,
      String? tag,
      ExistingWorkPolicy? existingWorkPolicy}) async {}

  @override
  Future<void> cancelByTag(String tag) async {}

  @override
  Future<void> cancelByUniqueName(String uniqueName) async {}
}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockLayananNotifikasi mockNotifikasiServis;
  late MockUnduhanAwalService mockUnduhanAwalService;
  late MockPelangganAktifOpSqlite mockPelangganAktifOpSqlite;
  late MockSettingsOpSqlite mockSettingsOpSqlite;
  late MockDataCleaningOperation mockDataCleaningOperation;
  late MockNotificationAppLaunchDetails mockLaunchDetails;
  late MockNotificationResponse mockNotificationResponse;
  late MockLayananPenyimpananLokal mockLocalStorage;
  late MockUploadDataService mockUploadDataService;
  late MockLayananCekSinkronisasi mockSyncCheckService;
  late MockSqliteDatabase mockDatabaseHelper;
  late MockDatabase mockDatabase;
  late MockWorkmanagerPlatform mockWorkmanagerPlatform;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockNotifikasiServis = MockLayananNotifikasi();
    mockUnduhanAwalService = MockUnduhanAwalService();
    mockPelangganAktifOpSqlite = MockPelangganAktifOpSqlite();
    mockSettingsOpSqlite = MockSettingsOpSqlite();
    mockDataCleaningOperation = MockDataCleaningOperation();
    mockLaunchDetails = MockNotificationAppLaunchDetails();
    mockNotificationResponse = MockNotificationResponse();
    mockLocalStorage = MockLayananPenyimpananLokal();
    mockUploadDataService = MockUploadDataService();
    mockSyncCheckService = MockLayananCekSinkronisasi();
    mockDatabaseHelper = MockSqliteDatabase();
    mockDatabase = MockDatabase();

    // Inisialisasi mock Workmanager platform
    mockWorkmanagerPlatform = MockWorkmanagerPlatform();
    WorkmanagerPlatform.instance = mockWorkmanagerPlatform;

    when(() => mockUploadDataService.uploadSemuaData())
        .thenAnswer((_) async => true);
    when(() => mockSyncCheckService.jalankanCekSinkronisasi())
        .thenAnswer((_) async {});
    when(() => mockLocalStorage.ambilModeTema())
        .thenAnswer((_) async => ThemeMode.light);
    when(() => mockLocalStorage.simpanModeTema(any()))
        .thenAnswer((_) async => true);
    when(() => mockPrefs.getString(any())).thenReturn('ThemeMode.light');
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

    when(() => mockNotifikasiServis.getDetailPeluncuranNotifikasi())
        .thenAnswer((_) async => mockLaunchDetails);
    when(() => mockLaunchDetails.didNotificationLaunchApp).thenReturn(false);
    when(() => mockLaunchDetails.notificationResponse)
        .thenReturn(mockNotificationResponse);
    when(() => mockNotificationResponse.payload).thenReturn(null);

    when(() => mockPelangganAktifOpSqlite.arsipkanLanggananKadaluarsa())
        .thenAnswer((_) async => 0);
    when(() => mockSettingsOpSqlite.ambilSettings())
        .thenAnswer((_) async => SettingsModel());
    when(() => mockDataCleaningOperation.hapusPermanentDataYangDiarsip(
        retentionDays: any(named: 'retentionDays'))).thenAnswer((_) async => 0);
    when(() => mockUnduhanAwalService.jalankanUnduhanAwal())
        .thenAnswer((_) async {});
    when(() => mockDatabaseHelper.database)
        .thenAnswer((_) async => mockDatabase);
    when(() => mockPelangganAktifOpSqlite.getAllActiveCustomersWithDetails())
        .thenAnswer((_) async => []);
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget createTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => mockPrefs),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
        notifikasiServiceProvider.overrideWithValue(mockNotifikasiServis),
        unduhanAwalServiceProvider.overrideWithValue(mockUnduhanAwalService),
        pelangganAktifOpSqliteProvider
            .overrideWithValue(mockPelangganAktifOpSqlite),
        settingsOpSqliteProvider.overrideWithValue(mockSettingsOpSqlite),
        dataCleaningOperationProvider
            .overrideWithValue(mockDataCleaningOperation),
        sqliteDatabaseProvider.overrideWithValue(mockDatabaseHelper),
        layananPenyimpananLokalProvider.overrideWithValue(mockLocalStorage),
        uploadDataServiceProvider.overrideWithValue(mockUploadDataService),
        layananCekSinkronisasiProvider.overrideWithValue(mockSyncCheckService),
        ...overrides,
      ],
      child: const AppAdmin(),
    );
  }

  group('Pengujian Widget AppAdmin', () {
    testWidgets(
        '01. Menampilkan CircularProgressIndicator saat SharedPreferences loading',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider
                .overrideWith((ref) => Completer<SharedPreferences>().future),
          ],
          child: const AppAdmin(),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        '02. Menampilkan pesan error saat SharedPreferences gagal dimuat',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider
                .overrideWith((ref) => Future.error('Gagal')),
          ],
          child: const AppAdmin(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Error memuat SharedPreferences'),
          findsOneWidget);
    });

    testWidgets(
        '03. Menampilkan AppInitializer saat SharedPreferences berhasil dimuat',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(AppInitializer), findsOneWidget);
    });
  });

  group('Pengujian Inisialisasi Aplikasi (AppInitializer)', () {
    testWidgets('04. Menampilkan HalamanUtama dengan status ONLINE',
        (tester) async {
      when(() => mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(() => mockKoneksiInternetService.cekKoneksiLokal()).called(1);

      expect(find.byType(HalamanUtama), findsOneWidget);
      final halamanUtama =
          tester.widget<HalamanUtama>(find.byType(HalamanUtama));
      expect(halamanUtama.isOffline, isFalse);
    });
    testWidgets('05. Menampilkan HalamanUtama dengan status OFFLINE',
        (tester) async {
      when(() => mockKoneksiInternetService.cekKoneksiLokal())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HalamanUtama), findsOneWidget);
      final halamanUtama =
          tester.widget<HalamanUtama>(find.byType(HalamanUtama));
      expect(halamanUtama.isOffline, isTrue);

      verifyNever(() => mockUnduhanAwalService.jalankanUnduhanAwal());
      verifyNever(() => mockDataCleaningOperation.hapusPermanentDataYangDiarsip(
          retentionDays: any(named: 'retentionDays')));
    });
  });

  group('Pengujian AppMaterial', () {
    testWidgets('06. Menampilkan loading indicator saat tema sedang loading',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
          overrides: [temaProvider.overrideWith(LoadingThemeNotifier.new)]));

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('07. Menampilkan pesan error saat tema gagal dimuat',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
          overrides: [temaProvider.overrideWith(ErrorThemeNotifier.new)]));

      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat tema'), findsOneWidget);
    });
  });
}

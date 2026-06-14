// path: test/admin/app_admin_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/background/background_service.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/data/sync/unduhan_awal_service.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/theme_provider.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';
import 'package:workmanager/workmanager.dart';

import 'app_admin_test.mocks.dart';

// Helper Notifiers for testing theme states
class LoadingThemeNotifier extends ThemeNotifier {
  @override
  Future<ThemeMode> build() {
    return Completer<ThemeMode>().future; // Never completes
  }
}

class ErrorThemeNotifier extends ThemeNotifier {
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

@GenerateMocks([
  SharedPreferences,
  KoneksiInternetService,
  NotifikasiServis,
  UnduhanAwalService,
  PelangganAktifOpSqlite,
  SettingsOpSqlite,
  DataCleaningOperation,
  SqliteDatabase,
  BackgroundService,
  NotificationAppLaunchDetails,
  NotificationResponse,
  LayananPenyimpananLokal,
  UploadDataService,
  SyncCheckService,
  Database,
])
void main() {
  late MockSharedPreferences mockPrefs;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockNotifikasiServis mockNotifikasiServis;
  late MockLayananUnduhAwal mockLayananUnduhAwal;
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late MockSettingsOperation mockSettingsOperation;
  late MockDataCleaningOperation mockDataCleaningOperation;
  late MockNotificationAppLaunchDetails mockLaunchDetails;
  late MockNotificationResponse mockNotificationResponse;
  late MockLayananPenyimpananLokal mockLocalStorage;
  late MockUploadDataService mockUploadDataService;
  late MockSyncCheckService mockSyncCheckService;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;
  late MockWorkmanagerPlatform mockWorkmanagerPlatform;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockNotifikasiServis = MockNotifikasiServis();
    mockLayananUnduhAwal = MockLayananUnduhAwal();
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    mockSettingsOperation = MockSettingsOperation();
    mockDataCleaningOperation = MockDataCleaningOperation();
    mockLaunchDetails = MockNotificationAppLaunchDetails();
    mockNotificationResponse = MockNotificationResponse();
    mockLocalStorage = MockLayananPenyimpananLokal();
    mockUploadDataService = MockUploadDataService();
    mockSyncCheckService = MockSyncCheckService();
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();

    // Inisialisasi mock Workmanager platform
    mockWorkmanagerPlatform = MockWorkmanagerPlatform();
    WorkmanagerPlatform.instance = mockWorkmanagerPlatform;

    when(mockUploadDataService.uploadSemuaData())
        .thenReturn(Future.value(true));
    when(mockSyncCheckService.runSyncCheck()).thenAnswer((_) async {});
    when(mockLocalStorage.ambilModeTema())
        .thenReturn(Future.value(ThemeMode.light));
    when(mockLocalStorage.simpanModeTema(any)).thenReturn(Future.value(true));
    when(mockPrefs.getString(any)).thenReturn('ThemeMode.light');
    when(mockPrefs.setString(any, any)).thenReturn(Future.value(true));
    when(mockPrefs.remove(any)).thenReturn(Future.value(true));

    when(mockNotifikasiServis.getDetailPeluncuranNotifikasi())
        .thenReturn(Future.value(mockLaunchDetails));
    when(mockLaunchDetails.didNotificationLaunchApp).thenReturn(false);
    when(mockLaunchDetails.notificationResponse)
        .thenReturn(mockNotificationResponse);
    when(mockNotificationResponse.payload).thenReturn(null);

    when(mockActiveCustomerOperation.archiveExpiredCustomers())
        .thenReturn(Future.value(0));
    when(mockSettingsOperation.getSettings())
        .thenReturn(Future.value(SettingsModel()));
    when(mockDataCleaningOperation.hapusPermanentDataYangDiarsip(
            retentionDays: anyNamed('retentionDays')))
        .thenReturn(Future.value(0));
    when(mockLayananUnduhAwal.jalankanUnduhanAwal()).thenAnswer((_) async {});
    when(mockDatabaseHelper.database).thenReturn(Future.value(mockDatabase));
    when(mockActiveCustomerOperation.getAllActiveCustomersWithDetails())
        .thenReturn(Future.value([]));
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget createTestWidget({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(AsyncValue.data(mockPrefs)),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
        notifikasiServisProvider.overrideWithValue(mockNotifikasiServis),
        unduhanAwalServiceProvider.overrideWithValue(mockLayananUnduhAwal),
        activeCustomerOperationProvider
            .overrideWithValue(mockActiveCustomerOperation),
        settingsOperationProvider.overrideWithValue(mockSettingsOperation),
        dataCleaningOperationProvider
            .overrideWithValue(mockDataCleaningOperation),
        sqliteDatabaseProvider.overrideWithValue(mockDatabaseHelper),
        localStorageServiceProvider
            .overrideWithValue(AsyncValue.data(mockLocalStorage)),
        uploadDataServiceProvider.overrideWithValue(mockUploadDataService),
        syncCheckServiceProvider.overrideWithValue(mockSyncCheckService),
        ...overrides,
      ],
      child: const AppAdmin(),
    );
  }

  group('Pengujian Widget AppAdmin', () {
    testWidgets(
        '1. Menampilkan CircularProgressIndicator saat SharedPreferences loading',
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
        '2. Menampilkan pesan error saat SharedPreferences gagal dimuat',
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
        '3. Menampilkan AppInitializer saat SharedPreferences berhasil dimuat',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(AppInitializer), findsOneWidget);
    });
  });

  group('Pengujian Inisialisasi Aplikasi (AppInitializer)', () {
    testWidgets('4. Menampilkan HalamanUtama dengan status ONLINE',
        (tester) async {
      when(mockKoneksiInternetService.cekKoneksiLokal())
          .thenReturn(Future.value(true));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(mockKoneksiInternetService.cekKoneksiLokal()).called(1);

      expect(find.byType(HalamanUtama), findsOneWidget);
      final halamanUtama =
          tester.widget<HalamanUtama>(find.byType(HalamanUtama));
      expect(halamanUtama.isOffline, isFalse);
    });
    testWidgets('5. Menampilkan HalamanUtama dengan status OFFLINE',
        (tester) async {
      when(mockKoneksiInternetService.cekKoneksiLokal())
          .thenReturn(Future.value(false));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HalamanUtama), findsOneWidget);
      final halamanUtama =
          tester.widget<HalamanUtama>(find.byType(HalamanUtama));
      expect(halamanUtama.isOffline, isTrue);

      verifyNever(mockLayananUnduhAwal.jalankanUnduhanAwal());
      verifyNever(mockDataCleaningOperation.hapusPermanentDataYangDiarsip(
          retentionDays: anyNamed('retentionDays')));
    });
  });

  group('Pengujian AppMaterial', () {
    testWidgets('7. Menampilkan loading indicator saat tema sedang loading',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
          overrides: [themeProvider.overrideWith(LoadingThemeNotifier.new)]));

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('8. Menampilkan pesan error saat tema gagal dimuat',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
          overrides: [themeProvider.overrideWith(ErrorThemeNotifier.new)]));

      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal memuat tema:'), findsOneWidget);
    });
  });
}

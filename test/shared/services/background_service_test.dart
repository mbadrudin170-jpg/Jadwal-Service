// path: test/shared/services/background_service_test.dart
// DIUBAH: Memperbaiki peringatan analyzer (no_self_assignments, avoid_dynamic_calls).

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi/fitur/background/background_service.dart';
import 'package:workmanager_platform_interface/workmanager_platform_interface.dart';

// Mock untuk WorkmanagerPlatform yang lebih fleksibel
class MockWorkmanagerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements WorkmanagerPlatform {
  // Menggunakan Map untuk menyimpan panggilan berdasarkan nama metode
  final Map<String, List<MethodCall>> methodCalls = {};

  void _logMethodCall(String methodName, [Map<String, dynamic>? arguments]) {
    methodCalls
        .putIfAbsent(methodName, () => [])
        .add(MethodCall(methodName, arguments));
  }

  @override
  Future<void> initialize(
    final Function callbackDispatcher, {
    final bool isInDebugMode = false,
  }) async {
    _logMethodCall('initialize', {
      'callbackDispatcher': callbackDispatcher,
      'isInDebugMode': isInDebugMode,
    });
  }

  @override
  Future<void> registerPeriodicTask(
    final String uniqueName,
    final String taskName, {
    final Duration? frequency,
    final Duration? flexInterval,
    final String? tag,
    final ExistingPeriodicWorkPolicy? existingWorkPolicy,
    final Duration? initialDelay,
    final Constraints? constraints,
    final BackoffPolicy? backoffPolicy,
    final Duration? backoffPolicyDelay,
    final OutOfQuotaPolicy? outOfQuotaPolicy,
    final Map<String, dynamic>? inputData,
  }) async {
    _logMethodCall('registerPeriodicTask', {
      'uniqueName': uniqueName,
      'taskName': taskName,
      'frequency': frequency,
      'existingWorkPolicy': existingWorkPolicy,
      'initialDelay': initialDelay,
      'constraints': constraints,
    });
  }

  @override
  Future<void> cancelAll() async {
    _logMethodCall('cancelAll');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock untuk Firebase Core
  const MethodChannel firebaseCoreChannel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firebaseCoreChannel,
          (MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return <String, dynamic>{
        'name': '[DEFAULT]',
        'options': <String, String>{
          'apiKey': 'test_api_key',
          'appId': 'test_app_id',
          'messagingSenderId': 'test_messaging_sender_id',
          'projectId': 'test_project_id',
        },
      };
    }
    return null;
  });

  late MockWorkmanagerPlatform mockWorkmanagerPlatform;

  setUp(() {
    mockWorkmanagerPlatform = MockWorkmanagerPlatform();
    WorkmanagerPlatform.instance = mockWorkmanagerPlatform;
  });

  // KODE DIPERBAIKI: Menghapus tearDown yang tidak perlu dan menyebabkan lint warning.

  group('Pengujian BackgroundService', () {
    test(
      '1. init() harus mendaftarkan TUGAS SINKRONISASI dan PENJADWALAN ULANG',
      () async {
        // ACT
        await BackgroundService.init();

        // ASSERT: Verifikasi inisialisasi
        expect(mockWorkmanagerPlatform.methodCalls['initialize'], isNotNull);
        expect(mockWorkmanagerPlatform.methodCalls['initialize']!.length, 1);

        // ASSERT: Verifikasi ada DUA panggilan pendaftaran tugas
        final registerCalls =
            mockWorkmanagerPlatform.methodCalls['registerPeriodicTask'];
        expect(registerCalls, isNotNull);
        expect(registerCalls!.length, 2);

        // KODE DIPERBAIKI: Memberi tipe eksplisit pada argumen
        final syncTaskCall = registerCalls.firstWhere(
          (call) =>
              (call.arguments as Map<String, dynamic>)['uniqueName'] ==
              syncTaskName,
        );
        final syncArgs = syncTaskCall.arguments as Map<String, dynamic>;
        expect(syncArgs['frequency'], const Duration(minutes: 15));
        expect((syncArgs['constraints'] as Constraints).networkType,
            NetworkType.connected);

        // KODE DIPERBAIKI: Memberi tipe eksplisit pada argumen
        final rescheduleTaskCall = registerCalls.firstWhere(
          (call) =>
              (call.arguments as Map<String, dynamic>)['uniqueName'] ==
              rescheduleNotificationsTaskName,
        );
        final rescheduleArgs =
            rescheduleTaskCall.arguments as Map<String, dynamic>;
        expect(rescheduleArgs['frequency'], const Duration(hours: 24));
        expect((rescheduleArgs['constraints'] as Constraints).networkType,
            NetworkType.notRequired);
        expect(rescheduleArgs['initialDelay'], const Duration(minutes: 5));
      },
    );

    test(
      '2. registerPeriodicSync() berhasil mendaftarkan tugas sinkronisasi',
      () async {
        await BackgroundService.daftarSinkronisasiPeriodik();

        final registerCall =
            mockWorkmanagerPlatform.methodCalls['registerPeriodicTask']!.first;
        expect(registerCall.method, 'registerPeriodicTask');
        expect((registerCall.arguments as Map)['uniqueName'], syncTaskName);
      },
    );

    test('3. batalkanSemuaTugas() berhasil membatalkan semua tugas', () async {
      await BackgroundService.batalkanSemuaTugas();

      expect(mockWorkmanagerPlatform.methodCalls['cancelAll']!.first.method,
          'cancelAll');
    });

    test(
        '4. daftarPenjadwalanUlangPeriodik() harus mendaftarkan tugas dengan benar',
        () async {
      await BackgroundService.daftarPenjadwalanUlangPeriodik();

      final registerCalls =
          mockWorkmanagerPlatform.methodCalls['registerPeriodicTask'];
      expect(registerCalls, isNotNull);
      expect(registerCalls!.length, 1);

      final callArguments =
          registerCalls.first.arguments as Map<String, dynamic>;
      expect(callArguments['uniqueName'], rescheduleNotificationsTaskName);
      expect(callArguments['taskName'], rescheduleNotificationsTaskName);
      expect(callArguments['frequency'], const Duration(hours: 24));
      expect(callArguments['existingWorkPolicy'],
          ExistingPeriodicWorkPolicy.replace);
      expect(callArguments['initialDelay'], const Duration(minutes: 5));
      expect(callArguments['constraints'], isA<Constraints>());
      expect((callArguments['constraints'] as Constraints).networkType,
          NetworkType.notRequired);
    });
  });
}

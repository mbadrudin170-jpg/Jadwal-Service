// path: test/shared/services/background_service_test.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:workmanager_platform_interface/workmanager_platform_interface.dart';

import 'background_service_test.mocks.dart';

// Mock untuk WorkmanagerPlatform
class MockWorkmanagerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements WorkmanagerPlatform {
  @override
  Future<void> initialize(
    final Function callbackDispatcher, {
    final bool isInDebugMode = false,
  }) async {
    // Implementasi mock untuk initialize
    logMethodCall('initialize', {
      'callbackDispatcher': callbackDispatcher,
      'isInDebugMode': isInDebugMode,
    });
  }

  @override
  Future<void> registerPeriodicTask(
    final String uniqueName,
    final String taskName, {
    final Duration? frequency,
    final String? tag,
    final ExistingPeriodicWorkPolicy? existingWorkPolicy,
    final Duration? initialDelay,
    final Constraints? constraints,
    final BackoffPolicy? backoffPolicy,
    final Duration? backoffPolicyDelay,
    final OutOfQuotaPolicy? outOfQuotaPolicy,
  }) async {
    // Implementasi mock untuk registerPeriodicTask
    logMethodCall('registerPeriodicTask', {
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
    // Implementasi mock untuk cancelAll
    logMethodCall('cancelAll');
  }

  // List untuk menyimpan panggilan method
  final List<MethodCall> methodCalls = [];

  // Helper untuk mencatat panggilan
  void logMethodCall(String methodName, [Map<String, dynamic>? arguments]) {
    methodCalls.add(MethodCall(methodName, arguments));
  }
}

// Menjalankan build_runner: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([SyncCheckService])
void main() {
  // Pastikan binding diinisialisasi sekali saja
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Firebase Core
  // Setup method channel untuk Firebase Core
  const MethodChannel firebaseCoreChannel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firebaseCoreChannel, (MethodCall methodCall) async {
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
    // Selalu buat instance baru untuk setiap tes untuk isolasi
    mockWorkmanagerPlatform = MockWorkmanagerPlatform();
    WorkmanagerPlatform.instance = mockWorkmanagerPlatform;
  });

  group('Pengujian BackgroundService', () {
    test(
      '1. init() berhasil menginisialisasi Workmanager dan mendaftarkan tugas periodik',
      () async {
        await BackgroundService.init();

        // Verifikasi initialize dipanggil
        final initializeCall = mockWorkmanagerPlatform.methodCalls.firstWhere(
          (call) => call.method == 'initialize',
          orElse: () => const MethodCall(''),
        );
        expect(initializeCall.method, 'initialize');
        expect(initializeCall.arguments['isInDebugMode'], false);
        expect(initializeCall.arguments['callbackDispatcher'],
            callbackDispatcher);

        // Verifikasi registerPeriodicTask dipanggil
        final registerCall = mockWorkmanagerPlatform.methodCalls.firstWhere(
          (call) => call.method == 'registerPeriodicTask',
          orElse: () => const MethodCall(''),
        );
        expect(registerCall.method, 'registerPeriodicTask');
        expect(registerCall.arguments['uniqueName'], syncTaskName);
        expect(registerCall.arguments['taskName'], syncTaskName);
        expect(registerCall.arguments['frequency'], const Duration(minutes: 15));
        expect(registerCall.arguments['existingWorkPolicy'],
            ExistingPeriodicWorkPolicy.replace);
        expect(
            registerCall.arguments['initialDelay'], const Duration(minutes: 1));
        expect(registerCall.arguments['constraints'],
            isA<Constraints>().having((c) => c.networkType, 'networkType', NetworkType.connected));
      },
    );

    test(
      '2. registerPeriodicSync() berhasil mendaftarkan tugas periodik',
      () async {
        await BackgroundService.registerPeriodicSync();

        final registerCall = mockWorkmanagerPlatform.methodCalls.first;
        expect(registerCall.method, 'registerPeriodicTask');
        expect(registerCall.arguments['uniqueName'], syncTaskName);
      },
    );

    test('3. cancelAllTasks() berhasil membatalkan semua tugas', () async {
      await BackgroundService.cancelAllTasks();

      expect(mockWorkmanagerPlatform.methodCalls.first.method, 'cancelAll');
    });
  });

  // Pengujian untuk callbackDispatcher harus dipisahkan karena sifatnya
  // yang merupakan top-level function dan kompleksitasnya.
  // Pengujian callbackDispatcher yang sebenarnya memerlukan pendekatan yang berbeda,
  // kemungkinan dengan integration test, karena:
  // 1. Ia berjalan di isolate terpisah.
  // 2. Ia membuat ProviderContainer-nya sendiri, yang sulit di-mock dalam unit test.
  // 3. Ia menginisialisasi Firebase, yang juga sulit di-mock di isolate baru.
  // Oleh karena itu, pengujian untuk callbackDispatcher dihilangkan dari
  // unit test ini untuk menjaga fokus dan keandalan.
}

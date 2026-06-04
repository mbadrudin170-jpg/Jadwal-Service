// path: test/shared/services/background_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:workmanager_platform_interface/workmanager_platform_interface.dart';

// Mock untuk WorkmanagerPlatform
class MockWorkmanagerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements WorkmanagerPlatform {
  // List untuk menyimpan panggilan method
  final List<MethodCall> methodCalls = [];

  // Helper untuk mencatat panggilan
  void logMethodCall(String methodName, [Map<String, dynamic>? arguments]) {
    methodCalls.add(MethodCall(methodName, arguments));
  }

  @override
  Future<void> initialize(
    final Function callbackDispatcher, {
    final bool isInDebugMode = false,
  }) async {
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
    logMethodCall('cancelAll');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock untuk Firebase Core
  const MethodChannel firebaseCoreChannel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  // Pengaturan Mock Handler untuk channel Firebase
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

  group('Pengujian BackgroundService', () {
    test(
      '1. init() berhasil menginisialisasi Workmanager dan mendaftarkan tugas periodik',
      () async {
        await BackgroundService.init();

        final initializeCall = mockWorkmanagerPlatform.methodCalls.firstWhere(
          (call) => call.method == 'initialize',
          orElse: () => const MethodCall(''),
        );
        expect(initializeCall.method, 'initialize');
        expect((initializeCall.arguments as Map)['isInDebugMode'], false);
        expect((initializeCall.arguments as Map)['callbackDispatcher'],
            callbackDispatcher);

        final registerCall = mockWorkmanagerPlatform.methodCalls.firstWhere(
          (call) => call.method == 'registerPeriodicTask',
          orElse: () => const MethodCall(''),
        );
        expect(registerCall.method, 'registerPeriodicTask');
        expect((registerCall.arguments as Map)['uniqueName'], syncTaskName);
        expect((registerCall.arguments as Map)['taskName'], syncTaskName);
        expect((registerCall.arguments as Map)['frequency'],
            const Duration(minutes: 15));
        expect((registerCall.arguments as Map)['existingWorkPolicy'],
            ExistingPeriodicWorkPolicy.replace);
        expect((registerCall.arguments as Map)['initialDelay'],
            const Duration(minutes: 1));
        expect(
            (registerCall.arguments as Map)['constraints'],
            isA<Constraints>().having(
                (c) => c.networkType, 'networkType', NetworkType.connected));
      },
    );

    test(
      '2. registerPeriodicSync() berhasil mendaftarkan tugas periodik',
      () async {
        await BackgroundService.registerPeriodicSync();

        final registerCall = mockWorkmanagerPlatform.methodCalls.first;
        expect(registerCall.method, 'registerPeriodicTask');
        expect((registerCall.arguments as Map)['uniqueName'], syncTaskName);
      },
    );

    test('3. cancelAllTasks() berhasil membatalkan semua tugas', () async {
      await BackgroundService.cancelAllTasks();

      expect(mockWorkmanagerPlatform.methodCalls.first.method, 'cancelAll');
    });
  });
}

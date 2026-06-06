// path: test/main/main_admin/firebase_mock.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to mock Firebase Core initialization (including Pigeon channels).
void setupFirebaseCoreMocks() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  const StandardMessageCodec codec = StandardMessageCodec();

  // 1. Mock untuk MethodChannel legacy (plugins.flutter.io/firebase_core)
  // Digunakan oleh versi firebase_core yang lebih lama atau sebagai fallback.
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall call) async {
      if (call.method == 'Firebase#initializeCore') {
        return <Map<String, dynamic>>[
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'fake-api-key',
              'appId': 'fake-app-id',
              'messagingSenderId': 'fake-sender-id',
              'projectId': 'fake-project-id',
            },
          }
        ];
      }
      if (call.method == 'Firebase#initializeApp') {
        // Cast arguments to a Map for type safety to resolve avoid_dynamic_calls.
        final args = call.arguments as Map<dynamic, dynamic>;
        return {
          'name': args['appName'],
          'options': args['options'],
        };
      }
      return null;
    },
  );

  // 2. Mock untuk Pigeon channels (FirebaseCoreHostApi)
  // Pigeon menggunakan BasicMessageChannel, sehingga harus menggunakan setMockMessageHandler.

  // initializeCore channel
  binding.defaultBinaryMessenger.setMockMessageHandler(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
    (ByteData? message) async {
      return codec.encodeMessage(<Object?, Object?>{
        'result': <Object?>[
          <Object?, Object?>{
            'name': '[DEFAULT]',
            'options': <Object?, Object?>{
              'apiKey': 'fake-api-key',
              'appId': 'fake-app-id',
              'messagingSenderId': 'fake-sender-id',
              'projectId': 'fake-project-id',
            },
          }
        ],
      });
    },
  );

  // initializeApp channel
  binding.defaultBinaryMessenger.setMockMessageHandler(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeApp',
    (ByteData? message) async {
      final decodedMessage = codec.decodeMessage(message) as List<Object?>?;
      final String appName = (decodedMessage != null && decodedMessage.isNotEmpty)
          ? decodedMessage[0] as String
          : '[DEFAULT]';
      final Map<Object?, Object?> options =
          (decodedMessage != null && decodedMessage.length > 1)
              ? decodedMessage[1] as Map<Object?, Object?>
              : {};

      return codec.encodeMessage(<Object?, Object?>{
        'result': <Object?, Object?>{
          'name': appName,
          'options': options,
        },
      });
    },
  );
}

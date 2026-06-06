// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:wifi/admin/app_admin.dart';
// import 'package:wifi/main/main_admin/admin_dev.dart' as admin_dev;
// import 'package:wifi/shared/services/boot_service.dart';

// import 'firebase_mock.dart';

// class FakeBootService implements BootService {
//   int schedulePeriodicArchiveTaskCalled = 0;
//   int rescheduleArchivingTaskCalled = 0;

//   @override
//   Future<void> schedulePeriodicArchiveTask(ProviderContainer container) {
//     schedulePeriodicArchiveTaskCalled++;
//     return Future.value();
//   }

//   @override
//   Future<void> rescheduleArchivingTask(ProviderContainer container) {
//     rescheduleArchivingTaskCalled++;
//     return Future.value();
//   }
// }

// void main() {
//   // 1. Inisialisasi binding Flutter untuk pengetesan terlebih dahulu.
//   // Ini harus menjadi perintah pertama sebelum berinteraksi dengan layanan platform.
//   final binding = TestWidgetsFlutterBinding.ensureInitialized();

//   // 2. Pasang mock Firebase Core setelah binding siap.
//   // setupFirebaseCoreMocks() harus dipasang setelah binding diinisialisasi agar binary messenger tersedia.
//   setupFirebaseCoreMocks();

//   setUpAll(() async {
//     // Gunakan inisialisasi default yang sudah di-mock oleh setupFirebaseCoreMocks().
//     // Ini menghindari konflik type cast pada channel Pigeon initializeCore.
//     await Firebase.initializeApp();
//   });

//   setUp(() {
//     const channelSharedPreferences =
//         MethodChannel('plugins.flutter.io/shared_preferences');
//     binding.defaultBinaryMessenger.setMockMethodCallHandler(
//       channelSharedPreferences,
//       (MethodCall methodCall) async {
//         if (methodCall.method == 'getAll') return <String, dynamic>{};
//         if (methodCall.method.startsWith('set')) return true;
//         return <String,
//             dynamic>{}; // Kembalikan map kosong alih-alih null untuk keamanan
//       },
//     );

//     const channelMobileAds =
//         MethodChannel('plugins.flutter.io/google_mobile_ads');
//     binding.defaultBinaryMessenger.setMockMethodCallHandler(
//       channelMobileAds,
//       (MethodCall methodCall) async {
//         if (methodCall.method == 'MobileAds#initialize') return {};
//         return {}; // Mengembalikan map kosong untuk mencegah error null check pada SDK iklan
//       },
//     );

//     const channelSplash = MethodChannel('flutter_native_splash');
//     binding.defaultBinaryMessenger.setMockMethodCallHandler(
//       channelSplash,
//       (MethodCall methodCall) async => {},
//     );

//     const channelBackground = MethodChannel('com.wifi.background_service');
//     binding.defaultBinaryMessenger.setMockMethodCallHandler(
//       channelBackground,
//       (MethodCall methodCall) async => {},
//     );
//   });

//   group('Pengujian file main_admin_dev.dart', () {
//     testWidgets('1. Inisialisasi berhasil dan AppAdmin ditampilkan',
//         (tester) async {
//       dotenv.env['SUPABASE_URL'] = 'https://mock.supabase.co';
//       dotenv.env['SUPABASE_PUBLISHABLE_KEY'] = 'mock_key_12345';

//       admin_dev.main();
//       await tester.pumpAndSettle();
//       expect(find.byType(AppAdmin), findsOneWidget);

//       dotenv.env.remove('SUPABASE_URL');
//       dotenv.env.remove('SUPABASE_PUBLISHABLE_KEY');
//     });

//     testWidgets('2. Aplikasi tetap berjalan saat variabel env Supabase kosong',
//         (tester) async {
//       dotenv.env.remove('SUPABASE_URL');
//       dotenv.env.remove('SUPABASE_PUBLISHABLE_KEY');

//       admin_dev.main();
//       await tester.pumpAndSettle();
//       expect(find.byType(AppAdmin), findsOneWidget);
//     });

//     testWidgets('3. Melemparkan error saat inisialisasi Firebase gagal',
//         (tester) async {
//       binding.defaultBinaryMessenger.setMockMethodCallHandler(
//         const MethodChannel('plugins.flutter.io/firebase_core'),
//         (MethodCall methodCall) async {
//           if (methodCall.method == 'Firebase#initializeCore') {
//             throw PlatformException(
//                 code: 'ERROR', message: 'Firebase init failed');
//           }
//           return null;
//         },
//       );

//       expect(admin_dev.main, throwsA(isA<FirebaseException>()));
//     });
//   });
// }

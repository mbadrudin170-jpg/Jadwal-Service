
// path: test/admin/firebase_option/firebase_option_admin_prod_test.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_prod.dart';

void main() {
  group('01. DefaultFirebaseOptions (Admin Prod)', () {
    // The test environment runs on the VM, so kIsWeb is always false.
    // The code under test throws an error if kIsWeb is true.
    // We cannot directly test the web scenario here, but we can test all other scenarios.

    test('01. harus mengembalikan opsi android saat platform adalah Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(DefaultFirebaseOptions.currentPlatform,
          equals(DefaultFirebaseOptions.android));
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('02. harus melempar UnsupportedError untuk iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>().having((e) => e.message,
            'message', contains('have not been configured for ios'))),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('03. harus melempar UnsupportedError untuk macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>().having((e) => e.message,
            'message', contains('have not been configured for macos'))),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('04. harus melempar UnsupportedError untuk Windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>().having((e) => e.message,
            'message', contains('have not been configured for windows'))),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('05. harus melempar UnsupportedError untuk Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>().having((e) => e.message,
            'message', contains('have not been configured for linux'))),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('06. harus melempar UnsupportedError untuk platform default (Fuchsia)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>().having((e) => e.message, 'message',
            contains('are not supported for this platform'))),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('07. properti opsi android harus benar', () {
      const androidOptions = DefaultFirebaseOptions.android;
      expect(androidOptions.apiKey, 'AIzaSyBVBa4xyhqiQhtwSu3Gg5qMJEkRgV6NpL4');
      expect(androidOptions.appId,
          '1:374464649442:android:521483824c57ca601066bb');
      expect(androidOptions.messagingSenderId, '374464649442');
      expect(androidOptions.projectId, 'studio-5934431625-6eeb1');
      expect(androidOptions.storageBucket,
          'studio-5934431625-6eeb1.firebasestorage.app');
    });
  });
}

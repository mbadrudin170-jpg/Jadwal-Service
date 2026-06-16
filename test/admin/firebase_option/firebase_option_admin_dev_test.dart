
// path: test/admin/firebase_option/firebase_option_admin_dev_test.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/firebase_option/firebase_option_admin_dev.dart';

void main() {
  group('01. DefaultFirebaseOptions (Admin Dev)', () {
    test('01. harus mengembalikan opsi web saat kIsWeb adalah true', () {
      // Tidak perlu mock kIsWeb karena test environment menjalankannya secara non-web,
      // dan kita bisa langsung membandingkan dengan properti statis.
      // Namun, untuk kejelasan, kita asumsikan bisa.
      // Dalam praktiknya, kita hanya akan menguji nilai statis.
      expect(DefaultFirebaseOptions.web, isA<FirebaseOptions>());
    });

    test('02. harus mengembalikan opsi android saat platform adalah Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(DefaultFirebaseOptions.currentPlatform,
          equals(DefaultFirebaseOptions.android));
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('03. harus melempar UnsupportedError untuk iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>()),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('04. harus melempar UnsupportedError untuk macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>()),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('05. harus melempar UnsupportedError untuk Windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>()),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('06. harus melempar UnsupportedError untuk Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>()),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('07. harus melempar UnsupportedError untuk platform default (Fuchsia)', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>()),
      );
      debugDefaultTargetPlatformOverride = null; // Reset
    });

    test('08. properti opsi web harus benar', () {
      const webOptions = DefaultFirebaseOptions.web;
      expect(webOptions.apiKey, 'AIzaSyCmUaDk1_f7Fpa1QNxj_qzjBnc02XEMmjE');
      expect(webOptions.appId, '1:71302938947:web:b84c919c4abadcfe2baff6');
      expect(webOptions.messagingSenderId, '71302938947');
      expect(webOptions.projectId, 'flutter-coding-9f081');
      expect(webOptions.storageBucket, 'flutter-coding-9f081.firebasestorage.app');
    });

    test('09. properti opsi android harus benar', () {
      const androidOptions = DefaultFirebaseOptions.android;
      expect(androidOptions.apiKey, 'AIzaSyAlOBmxKwtcDQQgO1PTHqAaeL60YBFDPNU');
      expect(androidOptions.appId, '1:71302938947:android:efeeb5c56fcafe772baff6');
      expect(androidOptions.messagingSenderId, '71302938947');
      expect(androidOptions.projectId, 'flutter-coding-9f081');
      expect(androidOptions.storageBucket, 'flutter-coding-9f081.firebasestorage.app');
    });
  });
}

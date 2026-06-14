// path: test/user/page/update_apk_page_u_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/user/page/update_apk_page_u.dart';

void main() {
  final apkInfo = VersiApkModel(
    latestVersion: '1.0.1',
    isUpdateRequired: true,
    releaseNotes: 'Bug fixes and performance improvements',
    downloadLinks: {ArsitekturApk.universal: 'https://example.com/update.apk'},
  );

  final packageInfo = InfoPerangkatModel(
    appName: 'Test App',
    packageName: 'com.example.test',
    version: '1.0.0',
    buildNumber: '1',
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      child: MaterialApp(
        home: UpdateApkPage(
          apkInfo: apkInfo,
          packageInfo: packageInfo,
          architecture: ArsitekturApk.universal,
        ),
      ),
    );
  }

  group('UpdateApkPage', () {
    testWidgets('Test 01: should display version information',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('v1.0.1'), findsOneWidget);
    });

    testWidgets('Test 02: should display changelog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Apa yang Baru?'), findsOneWidget);
      expect(
          find.text('Bug fixes and performance improvements'), findsOneWidget);
    });

    testWidgets('Test 03: should show download button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Download Pembaruan'), findsOneWidget);
    });
  });
}

// path: test/admin/halaman/form/apk_version_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';

class MockApkVersionOperation extends Mock implements ApkVersionOperation {}

void main() {
  late MockApkVersionOperation mockApkVersionOperation;
  late ApkVersionModel testApkVersion;

  setUp(() {
    mockApkVersionOperation = MockApkVersionOperation();
    testApkVersion = ApkVersionModel(
      id: '1',
      latestVersion: '1.0.0',
      latestBuildNumber: {},
      releaseNotes: 'Initial release',
      downloadLinks: {},
      isUpdateRequired: false,
      youtubeTutorial: '',
    );
  });

  Widget createTestWidget({ApkVersionModel? apkVersion}) {
    return ProviderScope(
      overrides: [
        apkVersionOperationProvider.overrideWithValue(mockApkVersionOperation),
      ],
      child: MaterialApp(
        home: ApkVersionForm(apkVersion: apkVersion),
      ),
    );
  }

  testWidgets('01. ApkVersionForm should display add form correctly', (tester) async {
    when(() => mockApkVersionOperation.getLatestApkVersion())
        .thenAnswer((_) async => null);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Tambah Versi APK'), findsOneWidget);
  });

  testWidgets('02. ApkVersionForm should display edit form correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(apkVersion: testApkVersion));
    await tester.pumpAndSettle();
    expect(find.text('Edit Versi APK'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('Initial release'), findsOneWidget);
  });
}

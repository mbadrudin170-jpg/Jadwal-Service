// path: test/admin/halaman/detail/apk_version_detail_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/apk_version_detail.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';

// Mocks
class MockApkVersionOperation extends Mock implements ApkVersionOperation {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockApkVersionOperation mockApkVersionOp;
  late MockNavigatorObserver mockNavigatorObserver;

  final tApkVersion = ApkVersionModel(
    id: '1',
    latestVersion: '1.0.0',
    latestBuildNumber: const {ApkArchitectureEnum.arm64: 1},
    downloadLinks: const {
      ApkArchitectureEnum.arm64: 'https://example.com/app.apk'
    },
    releaseNotes: 'Rilis awal',
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockApkVersionOp = MockApkVersionOperation();
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createTestWidget(ApkVersionModel model) {
    return ProviderScope(
      overrides: [
        apkVersionOperationProvider.overrideWithValue(mockApkVersionOp),
      ],
      child: MaterialApp(
        home: ApkVersionDetailPage(apkVersion: model),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Pengujian Halaman Detail Versi APK', () {
    testWidgets('1. Menampilkan detail versi APK dengan benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(tApkVersion));
      await tester.pumpAndSettle();

      expect(find.text('Detail Versi APK'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('Rilis awal'), findsOneWidget);
      expect(find.text('https://example.com/app.apk'), findsOneWidget);
    });

    testWidgets('2. Navigasi ke form edit saat tombol edit ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(tApkVersion));
      await tester.pumpAndSettle();

      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any()));
      expect(find.byType(ApkVersionForm), findsOneWidget);
    });

    testWidgets('3. Memuat ulang data setelah kembali dari form edit',
        (WidgetTester tester) async {
      when(() => mockApkVersionOp.getApkVersionById(any()))
          .thenAnswer((_) async => tApkVersion);

      await tester.pumpWidget(createTestWidget(tApkVersion));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Simulate popping the form
      Navigator.of(tester.element(find.byType(ApkVersionForm))).pop();
      await tester.pumpAndSettle();

      verify(() => mockApkVersionOp.getApkVersionById('1')).called(1);
    });
  });
}

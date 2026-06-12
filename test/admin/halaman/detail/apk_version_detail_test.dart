// path: test/admin/halaman/detail/apk_version_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/apk_version_detail.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/paket_provider.dart';
import 'package:wifi/shared/theme/app_theme.dart';

import 'apk_version_detail_test.mocks.dart';

@GenerateMocks([ApkVersionOperation])
void main() {
  late MockApkVersionOperation mockApkVersionOp;

  final versiApkDummy = ApkVersionModel(
    id: '1',
    versionName: '1.0.0',
    buildNumber: 1,
    url: 'https://example.com/app.apk',
    releaseNotes: 'Rilis awal',
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockApkVersionOp = MockApkVersionOperation();
  });

  Widget buatHalamanUji(ApkVersionModel model) {
    return ProviderScope(
      overrides: [
        apkVersionOperationProvider.overrideWithValue(mockApkVersionOp),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: ApkVersionDetailPage(apkVersion: model),
      ),
    );
  }

  group('Pengujian Halaman Detail Versi APK', () {
    testWidgets('1. Menampilkan detail versi APK dengan benar',
        (WidgetTester tester) async {
      // Jalankan
      await tester.pumpWidget(buatHalamanUji(versiApkDummy));
      await tester.pumpAndSettle();

      // Periksa
      expect(find.text('Detail Versi APK'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Rilis awal'), findsOneWidget);
      expect(find.text('https://example.com/app.apk'), findsOneWidget);
    });

    testWidgets('2. Navigasi ke form edit saat tombol edit ditekan',
        (WidgetTester tester) async {
      // Jalankan
      await tester.pumpWidget(buatHalamanUji(versiApkDummy));
      await tester.pumpAndSettle();

      final tombolEdit = find.byIcon(Icons.edit);
      expect(tombolEdit, findsOneWidget);

      await tester.tap(tombolEdit);
      await tester.pumpAndSettle();

      // Periksa
      expect(find.byType(ApkVersionForm), findsOneWidget);
    });

    testWidgets('3. Memuat ulang data setelah kembali dari form edit',
        (WidgetTester tester) async {
      when(mockApkVersionOp.getById('1'))
          .thenAnswer((_) async => versiApkDummy);

      // Jalankan
      await tester.pumpWidget(buatHalamanUji(versiApkDummy));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Simulasi kembali dari form
      Navigator.of(tester.element(find.byType(ApkVersionForm))).pop();
      await tester.pumpAndSettle();

      // Periksa pemanggilan ulang data
      verify(mockApkVersionOp.getById('1')).called(atLeastOnce());
    });
  });
}
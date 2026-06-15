
// path: test/admin/halaman/detail/apk_version_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/apk_version_detail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

// Mocks
class MockApkVersionOperation extends Mock implements ApkVersionOperation {}

class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockApkVersionOperation mockApkVersionOp;
  late MockBaseOpSqlite mockBaseOp;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  const tVersi = VersiApkModel(
    id: '1',
    version: '1.0.0',
    buildNumber: {
      ArsitekturApk.universal: 1,
      ArsitekturApk.arm64: 2,
    },
    appName: 'user',
    platform: 'android',
    downloadUrl: {
      ArsitekturApk.universal: 'url1',
      ArsitekturApk.arm64: 'url2',
    },
    releaseNotes: 'notes',
    isMandatory: false,
  );

  setUp(() {
    mockApkVersionOp = MockApkVersionOperation();
    mockBaseOp = MockBaseOpSqlite();
    mockNavigatorObserver = MockNavigatorObserver();

    container = ProviderContainer(
      overrides: [
        apkVersionOperationProvider.overrideWithValue(mockApkVersionOp),
        baseOpSqliteProvider.overrideWithValue(mockBaseOp),
      ],
    );

    when(() => mockApkVersionOp.softDelete(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: ApkVersionDetailPage(apkVersion: tVersi),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('ApkVersionDetailPage', () {
    testWidgets('01. harus menampilkan detail versi APK dengan benar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Detail Versi APK'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('notes'), findsOneWidget);
      expect(find.text('Tidak Wajib'), findsOneWidget);
      expect(find.text('universal'), findsOneWidget);
      expect(find.text('arm64'), findsOneWidget);
    });

    testWidgets('02. harus memanggil delete dan pop saat tombol hapus ditekan',
        (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      verify(() => mockApkVersionOp.softDelete('1')).called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(2);
    });

    testWidgets('03. harus navigasi ke form edit saat tombol edit ditekan',
        (tester) async {
      when(() => mockNavigatorObserver.didPush(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });

    testWidgets('04. harus menampilkan snackbar error saat hapus gagal',
        (tester) async {
      when(() => mockApkVersionOp.softDelete(any())).thenThrow(Exception('Error'));
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal menghapus versi APK'), findsOneWidget);
    });
  });
}

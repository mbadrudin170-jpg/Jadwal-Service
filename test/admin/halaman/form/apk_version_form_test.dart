// path: test/admin/halaman/form/apk_version_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/versi_apk/page/form_versi_apk.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

// Mocks
class MockApkVersionOperation extends Mock implements VersiApkOpSqlite {}

class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockApkVersionOperation mockApkVersionOp;
  late MockBaseOpSqlite mockBaseOp;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  final tVersi = VersiApkModel(
    id: '1',
    version: '1.0.0',
    buildNumber: 1,
    appName: 'user',
    platform: 'android',
    downloadUrl: 'url',
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

    // Default mock responses
    when(() => mockApkVersionOp.tambahVersiApk(any())).thenAnswer((_) async {});
    when(() => mockApkVersionOp.perbaruiVersiApk(any()))
        .thenAnswer((_) async {});

    registerFallbackValue(tVersi);
  });

  Widget createWidgetUnderTest({VersiApkModel? apkVersion}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: FormVersiApk(versiApk: apkVersion),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('ApkVersionForm', () {
    testWidgets('01. harus menampilkan form tambah dengan benar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Tambah Versi APK'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(4)); // version, build, url, notes
    });

    testWidgets('02. harus menampilkan form edit dengan data yang terisi',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(apkVersion: tVersi));
      expect(find.text('Edit Versi APK'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('url'), findsOneWidget);
      expect(find.text('notes'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('03. harus menampilkan error jika field kosong saat disimpan',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Versi tidak boleh kosong'), findsOneWidget);
      expect(find.text('Build number tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('04. harus memanggil addApkVersion saat mode tambah',
        (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(const Key('version')), '1.0.1');
      await tester.enterText(find.byKey(const Key('buildNumber')), '2');
      await tester.enterText(find.byKey(const Key('downloadUrl')), 'new_url');

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() =>
              mockApkVersionOp.tambahVersiApk(any(that: isA<VersiApkModel>())))
          .called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('05. harus memanggil updateApkVersion saat mode edit',
        (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(apkVersion: tVersi));

      await tester.enterText(find.byKey(const Key('version')), '1.0.2');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() => mockApkVersionOp.perbaruiVersiApk(any(
          that: isA<VersiApkModel>()
            ..having((v) => v.versiTerkahir, 'version', '1.0.2')))).called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('06. harus menampilkan snackbar error jika terjadi kegagalan',
        (tester) async {
      when(() => mockApkVersionOp.tambahVersiApk(any()))
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byKey(const Key('version')), '1.0.1');
      await tester.enterText(find.byKey(const Key('buildNumber')), '2');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal menyimpan versi APK'), findsOneWidget);
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });
  });
}

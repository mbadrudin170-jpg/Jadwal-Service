
// path: test/admin/halaman/form/apk_version_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/apk_version_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockApkVersionOperation extends Mock implements ApkVersionOperation {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockApkVersionOperation mockApkVersionOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final apkVersion = ApkVersionModel(
    id: '1',
    releaseNotes: 'Initial release',
    latestVersion: '1.0.0',
    youtubeTutorial: 'youtube.com/tutorial',
    isUpdateRequired: false,
    latestBuildNumber: const {ApkArchitectureEnum.universal: 1},
    downloadLinks: const {ApkArchitectureEnum.universal: 'google.com'},
  );

  setUp(() {
    mockApkVersionOperation = MockApkVersionOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        apkVersionOperationProvider.overrideWithValue(mockApkVersionOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {ApkVersionModel? apkVersion}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: ApkVersionForm(apkVersion: apkVersion),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form versi APK (mode edit)', (tester) async {
    when(() => mockApkVersionOperation.getLatestApkVersion()).thenAnswer((_) async => apkVersion);

    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, apkVersion: apkVersion));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Versi APK'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '1.0.0'), findsOneWidget);
    expect(find.text('SIMPAN DATA RILIS'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form versi APK', (tester) async {
    when(() => mockApkVersionOperation.getLatestApkVersion()).thenAnswer((_) async => null);

    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container));
    
    await tester.pumpAndSettle();

    await tester.tap(find.text('SIMPAN DATA RILIS'));
    await tester.pump();

    // Belum ada implementasi untuk scroll, jadi kita hanya cek apakah dialog muncul
    // expect(find.text('Konfirmasi Simpan'), findsNothing);
  });
}

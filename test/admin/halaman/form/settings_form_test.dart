
// path: test/admin/halaman/form/settings_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockSettingsOperation extends Mock implements SettingsOperation {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockSettingsOperation mockSettingsOperation;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final settings = SettingsModel(
    id: '1',
    autoSyncInterval: 24,
    autoDeleteArchiveDays: 30,
    maintenanceMode: false,
    maintenanceInfo: '',
  );

  setUp(() {
    mockSettingsOperation = MockSettingsOperation();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        settingsOperationProvider.overrideWithValue(mockSettingsOperation),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {required SettingsModel settings}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: SettingsForm(settings: settings),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form pengaturan', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, settings: settings));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Pengaturan'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '24'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });

  testWidgets('2. Tes validasi form pengaturan', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, settings: settings));
    
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '24'), '');
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pump();

    expect(find.text('Harap masukkan interval'), findsOneWidget);
  });
}

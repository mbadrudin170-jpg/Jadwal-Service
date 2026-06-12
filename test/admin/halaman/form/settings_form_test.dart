// path: test/admin/halaman/form/settings_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';

class MockSettingsOperation extends Mock implements SettingsOperation {}

void main() {
  late MockSettingsOperation mockSettingsOperation;
  late SettingsModel testSettings;

  setUp(() {
    mockSettingsOperation = MockSettingsOperation();
    testSettings = SettingsModel(
      id: 1,
      autoSyncInterval: 24,
      autoDeleteArchiveDays: 30,
      maintenanceMode: false,
      maintenanceInfo: '',
    );
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        settingsOperationProvider.overrideWithValue(mockSettingsOperation),
      ],
      child: MaterialApp(
        home: SettingsForm(settings: testSettings),
      ),
    );
  }

  testWidgets('01. SettingsForm should display settings correctly', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Edit Pengaturan'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });
}

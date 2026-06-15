// path: test/admin/halaman/form/settings_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/settings/page/form_settings.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';

class MockSettingsOperation extends Mock implements SettingsOpSqlite {}

void main() {
  late MockSettingsOperation mockSettingsOperation;
  late SettingsModel testSettings;

  setUp(() {
    mockSettingsOperation = MockSettingsOperation();
    testSettings = SettingsModel(
      id: 1,
      waktuOtomatisSinkroniasi: 24,
      waktuOtomatisHapusDataArsip: 30,
      modeMaintenance: false,
      infoMaintenance: '',
    );
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        settingsOperationProvider.overrideWithValue(mockSettingsOperation),
      ],
      child: MaterialApp(
        home: FormSettings(settings: testSettings),
      ),
    );
  }

  testWidgets('01. SettingsForm should display settings correctly',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Edit Pengaturan'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
  });
}

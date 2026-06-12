// path: test/shared/operasi/settings_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/settings_model.dart' as model;
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';

import 'settings_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, BaseOperation, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late SettingsOperation settingsOperation;
  final tableName = TableNameValue.get(TableName.settings);

  // --- PERBAIKAN: Menggunakan ID String yang benar dari model ---
  const String globalSettingsId = model.globalSettingsId;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    settingsOperation = SettingsOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );

    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('getSettings', () {
    test(
        '1. harus mengembalikan pengaturan yang ada jika ditemukan di database',
        () async {
      // Atur
      // --- PERBAIKAN: Menggunakan konstanta ColumnNames ---
      final settingsMap = {
        ColumnNames.id: globalSettingsId,
        ColumnNames.autoSyncInterval: 48,
        ColumnNames.autoDeleteArchiveDays: 60,
        ColumnNames.maintenanceMode: 1,
        ColumnNames.maintenanceInfo: 'Under construction',
        ColumnNames.updatedAt: DateTime.now().millisecondsSinceEpoch,
      };

      when(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: [globalSettingsId],
      )).thenAnswer((_) async => [settingsMap]);

      // Lakukan
      final result = await settingsOperation.getSettings();

      // Periksa
      expect(result.autoSyncInterval, 48);
      expect(result.maintenanceMode, true);
      verify(mockDatabase.query(tableName,
          where: 'id = ?', whereArgs: [globalSettingsId])).called(1);
      verifyNever(mockBaseOperation.sisipkan(any, any));
    });

    test(
        '2. harus membuat, menyimpan, dan mengembalikan pengaturan default jika tidak ditemukan',
        () async {
      // Atur
      when(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: [globalSettingsId],
      )).thenAnswer((_) async => []);

      // Saat insert, mock harus mengembalikan ID string yang kita harapkan
      when(mockBaseOperation.sisipkan(any, any,
              dariServer: anyNamed('fromServer')))
          .thenAnswer((_) async => globalSettingsId);

      // Lakukan
      final result = await settingsOperation.getSettings();
      final defaultSettings = model.SettingsModel();

      // Periksa
      expect(result.autoSyncInterval, defaultSettings.autoSyncInterval);

      verify(mockDatabase.query(tableName,
          where: 'id = ?', whereArgs: [globalSettingsId])).called(1);

      final captured = verify(mockBaseOperation.sisipkan(
        tableName,
        captureAny,
      )).captured;

      final savedData = captured.first as Map<String, dynamic>;

      // --- PERBAIKAN: Memeriksa dengan konstanta ColumnNames dan ID yang benar ---
      expect(savedData[ColumnNames.id], globalSettingsId);
    });
  });

  group('saveOrUpdateSettings', () {
    test('3. harus memanggil _baseOperation.insert dengan data yang benar',
        () async {
      // Atur
      final settings = model.SettingsModel(
        autoSyncInterval: 12,
        updatedAt: DateTime(2023, 10, 26),
      );

      // Mengembalikan ID yang benar (string)
      when(mockBaseOperation.sisipkan(any, any,
              dariServer: anyNamed('fromServer')))
          .thenAnswer((_) async => globalSettingsId);

      // Lakukan
      await settingsOperation.saveOrUpdateSettings(settings);

      // Periksa
      final captured = verify(mockBaseOperation.sisipkan(
        tableName,
        captureAny,
      )).captured;

      final savedData = captured.first as Map<String, dynamic>;

      // --- PERBAIKAN: Memeriksa dengan konstanta ColumnNames dan ID yang benar ---
      expect(savedData[ColumnNames.id], globalSettingsId);
      expect(savedData[ColumnNames.autoSyncInterval], 12);
    });

    test('4. harus meneruskan flag fromServer dengan benar', () async {
      // Atur
      final settings = model.SettingsModel();
      when(mockBaseOperation.sisipkan(any, any,
              dariServer: anyNamed('fromServer')))
          .thenAnswer((_) async => globalSettingsId);

      // Lakukan
      await settingsOperation.saveOrUpdateSettings(settings, fromServer: true);

      // Periksa
      verify(mockBaseOperation.sisipkan(
        tableName,
        any,
        dariServer: true,
      )).called(1);
    });
  });
}

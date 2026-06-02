// path: test/shared/operasi/settings_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';

import 'settings_operation_test.mocks.dart';

// ID Global untuk baris pengaturan di SQLite. Selalu 1.
const int globalSettingsId = 1;

@GenerateMocks([DatabaseHelper, BaseOperation, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late SettingsOperation settingsOperation;
  final tableName = TableNameValue.get(TableName.settings);

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
    test('harus mengembalikan pengaturan yang ada jika ditemukan di database', () async {
      // Atur
      final settingsMap = {
        'id': globalSettingsId,
        'autoSyncInterval': 48,
        'autoDeleteArchiveDays': 60,
        'maintenanceMode': 1,
        'maintenanceInfo': 'Under construction',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      // --- PERBAIKAN: Menggunakan ID integer untuk whereArgs --- 
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
      verify(mockDatabase.query(tableName, where: 'id = ?', whereArgs: [globalSettingsId])).called(1);
      verifyNever(mockBaseOperation.insert(any, any));
    });

    test('harus membuat, menyimpan, dan mengembalikan pengaturan default jika tidak ditemukan', () async {
      // Atur
      // --- PERBAIKAN: Menggunakan ID integer untuk whereArgs --- 
      when(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: [globalSettingsId],
      )).thenAnswer((_) async => []);

      when(mockBaseOperation.insert(any, any, fromServer: anyNamed('fromServer')))
          .thenAnswer((_) async => globalSettingsId);

      // Lakukan
      final result = await settingsOperation.getSettings();
      final defaultSettings = SettingsModel();

      // Periksa
      expect(result.autoSyncInterval, defaultSettings.autoSyncInterval);
      
      verify(mockDatabase.query(tableName, where: 'id = ?', whereArgs: [globalSettingsId])).called(1);
      
      final captured = verify(mockBaseOperation.insert(
        tableName,
        captureAny,
      )).captured;

      final savedData = captured.first as Map<String, dynamic>;
      // --- PERBAIKAN: Memastikan ID yang disimpan adalah integer --- 
      expect(savedData['id'], globalSettingsId);
    });
  });

  group('saveOrUpdateSettings', () {
    test('harus memanggil _baseOperation.insert dengan data yang benar', () async {
      // Atur
      final settings = SettingsModel(
        autoSyncInterval: 12,
        updatedAt: DateTime(2023, 10, 26),
      );
      
      when(mockBaseOperation.insert(any, any, fromServer: anyNamed('fromServer')))
          .thenAnswer((_) async => 1);

      // Lakukan
      await settingsOperation.saveOrUpdateSettings(settings);

      // Periksa
      final captured = verify(mockBaseOperation.insert(
        tableName,
        captureAny,
      )).captured;

      final savedData = captured.first as Map<String, dynamic>;

      // --- PERBAIKAN: Memastikan ID yang disimpan adalah integer --- 
      expect(savedData['id'], globalSettingsId);
      expect(savedData['autoSyncInterval'], 12);
    });

    test('harus meneruskan flag fromServer dengan benar', () async {
      // Atur
      final settings = SettingsModel();
      when(mockBaseOperation.insert(any, any, fromServer: anyNamed('fromServer')))
          .thenAnswer((_) async => 1);

      // Lakukan
      await settingsOperation.saveOrUpdateSettings(settings, fromServer: true);

      // Periksa
      verify(mockBaseOperation.insert(
        tableName,
        any,
        fromServer: true,
      )).called(1);
    });
  });
}

// path: test/shared/operasi/settings_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';

void main() {
  // Initialize FFI for sqflite for in-memory testing
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late SettingsOperation settingsOperation;
  late BaseOperation baseOperation;
  final settingsTableName = TableNameValue.get(TableName.settings);

  setUp(() async {
    // Use the singleton instance, which will use an in-memory DB for tests
    dbHelper = DatabaseHelper.instance;
    // Clear the database before each test
    dbHelper.debugSetDatabaseNull();
    await dbHelper.database; // Ensure database is initialized

    // Use a real BaseOperation connected to the in-memory database
    baseOperation = BaseOperation(dbHelper: dbHelper);
    settingsOperation = SettingsOperation(
      dbHelper: dbHelper,
      baseOperation: baseOperation,
    );
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.debugSetDatabaseNull();
  });

  group('SettingsOperation Tests', () {
    test('getSettings should create and return default settings if none exist',
        () async {
      // Arrange (DB is empty by default)

      // Act
      final settings = await settingsOperation.getSettings();

      // Assert
      expect(settings.id, equals(globalSettingsId));
      expect(settings.autoSyncInterval, 24); // Default value

      // Verify that default settings were indeed saved to the database
      final db = await dbHelper.database;
      final result = await db.query(settingsTableName,
          where: 'id = ?', whereArgs: [globalSettingsId]);
      expect(result.length, 1);
      expect(result.first['id'], globalSettingsId);
      expect(result.first[ColumnNames.autoSyncInterval], 24);
    });

    test('getSettings should return existing settings from the database',
        () async {
      // Arrange: Manually insert settings into the DB
      final db = await dbHelper.database;
      final testSettings = SettingsModel(
        id: globalSettingsId,
        autoSyncInterval: 48, // Non-default value
        updatedAt: DateTime.now().toUtc(),
      );
      await db.insert(settingsTableName, testSettings.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      // Act
      final settings = await settingsOperation.getSettings();

      // Assert
      expect(settings.id, globalSettingsId);
      expect(settings.autoSyncInterval, 48);
    });

    test('saveOrUpdateSettings should correctly insert new settings', () async {
      // Arrange
      final newSettings = SettingsModel(
        autoSyncInterval: 72,
        updatedAt: DateTime.now().toUtc(),
      );

      // Act
      await settingsOperation.saveOrUpdateSettings(newSettings);

      // Assert
      final db = await dbHelper.database;
      final result = await db.query(settingsTableName,
          where: 'id = ?', whereArgs: [globalSettingsId]);
      expect(result.length, 1);
      expect(result.first[ColumnNames.autoSyncInterval], 72);
    });

    test('update should update partial fields of the settings', () async {
      // Arrange: Insert initial settings
      final initialSettings = SettingsModel(
        autoSyncInterval: 12,
      );
      await settingsOperation.saveOrUpdateSettings(initialSettings);

      // Act: Update only the autoSyncInterval field
      const newInterval = 6;
      await settingsOperation
          .update({ColumnNames.autoSyncInterval: newInterval});

      // Assert
      final settings = await settingsOperation.getSettings();
      expect(settings.autoSyncInterval, newInterval);
      // Ensure other fields are not wiped or altered unexpectedly
      expect(settings.id, globalSettingsId);
    });

    test(
        'saveOrUpdateSettingsWithBatch should correctly insert or update settings',
        () async {
      // Arrange
      final batchSettings = SettingsModel(
        autoSyncInterval: 1,
        updatedAt: DateTime.now().toUtc(),
      );
      // Act
      await settingsOperation.saveOrUpdateSettingsWithBatch(batchSettings);
      // Assert
      final settings = await settingsOperation.getSettings();
      expect(settings.id, globalSettingsId);
      expect(settings.autoSyncInterval, 1);
    });
  });
}

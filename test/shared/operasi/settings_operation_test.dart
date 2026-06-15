// path: test/shared/operasi/settings_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart' as model;
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';

import 'settings_operation_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late SettingsOpSqlite settingsOperation;
  final tableName = NamaTabel.get(TableName.settings);

  // --- PERBAIKAN: Menggunakan ID String yang benar dari model ---
  const String globalSettingsId = model.idGlobalSetting;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    settingsOperation = SettingsOpSqlite(
      sqliteDb: mockDbHelper,
      baseOpSqlite: mockBaseOperation,
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
        NamaKolom.id: globalSettingsId,
        NamaKolom.waktuOtomatisSinkroniasi: 48,
        NamaKolom.waktuOtomatisHapusDataArsip: 60,
        NamaKolom.modeMaintenance: 1,
        NamaKolom.infoMaintenance: 'Under construction',
        NamaKolom.diperbaruiPada: DateTime.now().millisecondsSinceEpoch,
      };

      when(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: [globalSettingsId],
      )).thenAnswer((_) async => [settingsMap]);

      // Lakukan
      final result = await settingsOperation.getSettings();

      // Periksa
      expect(result.waktuOtomatisSinkroniasi, 48);
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
      expect(result.waktuOtomatisSinkroniasi,
          defaultSettings.waktuOtomatisSinkroniasi);

      verify(mockDatabase.query(tableName,
          where: 'id = ?', whereArgs: [globalSettingsId])).called(1);

      final captured = verify(mockBaseOperation.sisipkan(
        tableName,
        captureAny,
      )).captured;

      final savedData = captured.first as Map<String, dynamic>;

      // --- PERBAIKAN: Memeriksa dengan konstanta ColumnNames dan ID yang benar ---
      expect(savedData[NamaKolom.id], globalSettingsId);
    });
  });

  group('saveOrUpdateSettings', () {
    test('3. harus memanggil _baseOperation.insert dengan data yang benar',
        () async {
      // Atur
      final settings = model.SettingsModel(
        waktuOtomatisSinkroniasi: 12,
        diperbaruiPada: DateTime(2023, 10, 26),
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
      expect(savedData[NamaKolom.id], globalSettingsId);
      expect(savedData[NamaKolom.waktuOtomatisSinkroniasi], 12);
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

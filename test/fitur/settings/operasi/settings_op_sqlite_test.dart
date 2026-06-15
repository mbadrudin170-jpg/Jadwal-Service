
// path: test/fitur/settings/operasi/settings_op_sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

// Mocks
class MockSqliteDatabase extends Mock implements SqliteDatabase {}

class MockDatabase extends Mock implements Database {}

class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}

void main() {
  late SettingsOpSqlite settingsOpSqlite;
  late MockSqliteDatabase mockSqliteDatabase;
  late MockDatabase mockDatabase;
  late MockBaseOpSqlite mockBaseOpSqlite;

  setUp(() {
    mockSqliteDatabase = MockSqliteDatabase();
    mockDatabase = MockDatabase();
    mockBaseOpSqlite = MockBaseOpSqlite();

    when(() => mockSqliteDatabase.database).thenAnswer((_) async => mockDatabase);

    settingsOpSqlite = SettingsOpSqlite(
      sqliteDb: mockSqliteDatabase,
      baseOpSqlite: mockBaseOpSqlite,
    );

    // Register fallback values
    registerFallbackValue(<String, dynamic>{});
  });

  group('SettingsOpSqlite', () {
    final tSettingsModel = SettingsModel(
      id: idGlobalSetting,
      waktuOtomatisSinkroniasi: 12,
      waktuOtomatisHapusDataArsip: 15,
      modeMaintenance: true,
      infoMaintenance: 'Under construction',
      diperbaruiPada: DateTime(2023),
    );
    final tSettingsMap = tSettingsModel.toSqlite();

    group('getSettings', () {
      test(
        '01. harus mengembalikan SettingsModel yang ada jika data ditemukan di database',
        () async {
          // Arrange
          when(() => mockDatabase.query(
                NamaTabel.settings,
                where: any(named: 'where'),
                whereArgs: any(named: 'whereArgs'),
              )).thenAnswer((_) async => [tSettingsMap]);

          // Act
          final result = await settingsOpSqlite.getSettings();

          // Assert
          expect(result, isA<SettingsModel>());
          expect(result.id, tSettingsModel.id);
          verify(() => mockDatabase.query(
                NamaTabel.settings,
                where: 'id = ?',
                whereArgs: [idGlobalSetting],
              )).called(1);
        },
      );

      test(
        '02. harus membuat, menyimpan, dan mengembalikan SettingsModel default jika tidak ada data di database',
        () async {
          // Arrange
          when(() => mockDatabase.query(
                NamaTabel.settings,
                where: any(named: 'where'),
                whereArgs: any(named: 'whereArgs'),
              )).thenAnswer((_) async => []);

          when(() => mockBaseOpSqlite.sisipkan(
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenAnswer((_) async => Future.value());

          // Act
          final result = await settingsOpSqlite.getSettings();

          // Assert
          expect(result, isA<SettingsModel>());
          expect(result.id, idGlobalSetting);
          verify(() => mockDatabase.query(
                NamaTabel.settings,
                where: 'id = ?',
                whereArgs: [idGlobalSetting],
              )).called(1);
          verify(() => mockBaseOpSqlite.sisipkan(
                NamaTabel.settings,
                any(that: isA<Map<String, dynamic>>()),
                dariServer: false,
              )).called(1);
        },
      );

      test(
        '03. harus mengembalikan SettingsModel default dan mencatat error jika terjadi kegagalan saat mengambil data dari database',
        () async {
          // Arrange
          when(() => mockDatabase.query(
                NamaTabel.settings,
                where: any(named: 'where'),
                whereArgs: any(named: 'whereArgs'),
              )).thenThrow(Exception('DB Error'));

          // Act
          final result = await settingsOpSqlite.getSettings();

          // Assert
          expect(result, const SettingsModel());
          verify(() => mockDatabase.query(
                NamaTabel.settings,
                where: 'id = ?',
                whereArgs: [idGlobalSetting],
              )).called(1);
        },
      );
    });

    group('saveOrUpdateSettings', () {
      test(
        '04. harus memanggil _baseOpSqlite.sisipkan dengan data dan nama tabel yang benar',
        () async {
          // Arrange
          when(() => mockBaseOpSqlite.sisipkan(
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenAnswer((_) async => Future.value());

          // Act
          await settingsOpSqlite.saveOrUpdateSettings(tSettingsModel);

          // Assert
          final captured = verify(() => mockBaseOpSqlite.sisipkan(
                NamaTabel.settings,
                captureAny(),
                dariServer: false,
              )).captured.last as Map<String, dynamic>;

          expect(captured[NamaKolom.id], idGlobalSetting);
          expect(captured, isA<Map<String, dynamic>>());
        },
      );
      test(
        '05. harus memanggil _baseOpSqlite.sisipkan dengan dariServer bernilai true',
        () async {
          // Arrange
          when(() => mockBaseOpSqlite.sisipkan(
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenAnswer((_) async => Future.value());

          // Act
          await settingsOpSqlite.saveOrUpdateSettings(tSettingsModel,
              fromServer: true);

          // Assert
          verify(() => mockBaseOpSqlite.sisipkan(
                NamaTabel.settings,
                any(that: isA<Map<String, dynamic>>()),
                dariServer: true,
              )).called(1);
        },
      );

      test(
        '06. harus melempar ulang (rethrow) exception jika _baseOpSqlite.sisipkan gagal',
        () async {
          // Arrange
          final exception = Exception('Failed to insert');
          when(() => mockBaseOpSqlite.sisipkan(
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenThrow(exception);

          // Act
          final call = settingsOpSqlite.saveOrUpdateSettings;

          // Assert
          expect(() => call(tSettingsModel), throwsA(isA<Exception>()));
        },
      );
    });

    group('updateSettings', () {
      final updateData = {NamaKolom.modeMaintenance: true};

      test(
        '07. harus memanggil _baseOpSqlite.update dengan data parsial yang benar',
        () async {
          // Arrange
          when(() => mockBaseOpSqlite.update(
                any(),
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenAnswer((_) async => Future.value());

          // Act
          await settingsOpSqlite.updateSettings(updateData);

          // Assert
          final captured = verify(() => mockBaseOpSqlite.update(
                NamaTabel.settings,
                captureAny(),
                idGlobalSetting,
                dariServer: false,
              )).captured.last as Map<String, dynamic>;

          expect(captured[NamaKolom.modeMaintenance], updateData[NamaKolom.modeMaintenance]);
          expect(captured.containsKey(NamaKolom.diperbaruiPada), isTrue);
        },
      );
      test(
        '08. harus memanggil _baseOpSqlite.update dengan dariServer bernilai true',
        () async {
          // Arrange
          when(() => mockBaseOpSqlite.update(
                any(),
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenAnswer((_) async => Future.value());

          // Act
          await settingsOpSqlite.updateSettings(updateData, dariServer: true);

          // Assert
          verify(() => mockBaseOpSqlite.update(
                NamaTabel.settings,
                any(that: isA<Map<String, dynamic>>()),
                idGlobalSetting,
                dariServer: true,
              )).called(1);
        },
      );

      test(
        '09. harus melempar ulang (rethrow) exception jika _baseOpSqlite.update gagal',
        () async {
          // Arrange
          final exception = Exception('Failed to update');
          when(() => mockBaseOpSqlite.update(
                any(),
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenThrow(exception);

          // Act
          final call = settingsOpSqlite.updateSettings;

          // Assert
          expect(() => call(updateData), throwsA(isA<Exception>()));
        },
      );
    });
    group('saveOrUpdateSettingsWithBatch', () {
      test(
        '10. harus memanggil _baseOpSqlite.insertOrUpdateBatch dengan data yang benar',
        () async {
          // Arrange
          when(() => mockBaseOpSqlite.insertOrUpdateBatch(
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenAnswer((_) async => Future.value());

          // Act
          await settingsOpSqlite.saveOrUpdateSettingsWithBatch(tSettingsModel);

          // Assert
          final captured = verify(() => mockBaseOpSqlite.insertOrUpdateBatch(
                NamaTabel.settings,
                captureAny(),
                dariServer: false,
              )).captured.last as List<Map<String, dynamic>>;

          expect(captured.length, 1);
          expect(captured.first[NamaKolom.id], idGlobalSetting);
        },
      );

      test(
        '11. harus melempar ulang (rethrow) exception jika _baseOpSqlite.insertOrUpdateBatch gagal',
        () async {
          // Arrange
          final exception = Exception('Failed to batch update');
          when(() => mockBaseOpSqlite.insertOrUpdateBatch(
                any(),
                any(),
                dariServer: any(named: 'dariServer'),
              )).thenThrow(exception);

          // Act
          final call = settingsOpSqlite.saveOrUpdateSettingsWithBatch;

          // Assert
          expect(() => call(tSettingsModel), throwsA(isA<Exception>()));
        },
      );
    });
  });
}

// path: test/fitur/settings/operasi/settings_op_sqlite_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

import 'settings_op_sqlite_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database])
void main() {
  late SettingsOpSqlite settingsOpSqlite;
  late MockSqliteDatabase mockSqliteDb;
  late MockBaseOpSqlite mockBaseOpSqlite;
  late MockDatabase mockDb;

  setUp(() {
    mockSqliteDb = MockSqliteDatabase();
    mockBaseOpSqlite = MockBaseOpSqlite();
    mockDb = MockDatabase();

    settingsOpSqlite = SettingsOpSqlite(
      sqliteDb: mockSqliteDb,
      baseOpSqlite: mockBaseOpSqlite,
    );

    // Stubbing
    when(mockSqliteDb.database).thenAnswer((_) async => mockDb);
  });

  const namaTabel = NamaTabel.settings;
  const id = idGlobalSetting;

  final settingsModel = SettingsModel(
    waktuOtomatisSinkronisasi: 48,
    diperbaruiPada: DateTime(2023),
  );

  group('ambilSettings', () {
    test('01. harus mengembalikan SettingsModel dari DB jika ada', () async {
      // Arrange
      final dbData = <String, dynamic>{
        NamaKolom.id: id,
        NamaKolom.waktuOtomatisSinkronisasi: 48,
        NamaKolom.diperbaruiPada: DateTime(2023).millisecondsSinceEpoch,
      };

      when(
        mockDb.query(
          namaTabel,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((_) async => [dbData]);

      // Act
      final result = await settingsOpSqlite.ambilSettings();

      // Assert
      expect(result.id, id);
      expect(result.waktuOtomatisSinkronisasi, 48);
      verify(
        mockDb.query(namaTabel, where: 'id = ?', whereArgs: [id]),
      ).called(1);
    });

    test(
      '02. harus membuat, menyimpan, dan mengembalikan pengaturan default jika tidak ada di DB',
      () async {
        // Arrange
        when(
          mockDb.query(
            namaTabel,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenAnswer((_) async => []); // Mengembalikan list kosong

        when(
          mockBaseOpSqlite.sisipkan(
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await settingsOpSqlite.ambilSettings();

        // Assert
        expect(result.id, id); // Harusnya di-set ke id global
        expect(result.modeMaintenance, false);
        verify(
          mockDb.query(namaTabel, where: 'id = ?', whereArgs: [id]),
        ).called(1);
        verify(
          mockBaseOpSqlite.sisipkan(
            namaTabel,
            argThat(isA<Map<String, dynamic>>()),
          ),
        ).called(1);
      },
    );

    test(
      '03. harus mengembalikan model default saat terjadi Exception',
      () async {
        // Arrange
        when(
          mockDb.query(
            any,
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs'),
          ),
        ).thenThrow(Exception('DB Error'));

        // Act
        final result = await settingsOpSqlite.ambilSettings();

        // Assert
        expect(result, const SettingsModel()); // Ekspektasi model default
      },
    );
  });

  group('saveOrUpdateSettings', () {
    test(
      '04. harus memanggil baseOpSqlite.sisipkan dengan data yang benar',
      () async {
        // Arrange
        when(
          mockBaseOpSqlite.sisipkan(
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await settingsOpSqlite.simpanAtauPerbaruiSettings(settingsModel);

        // Assert
        final captured = verify(
          mockBaseOpSqlite.sisipkan(namaTabel, captureAny),
        ).captured;

        final capturedData =
            captured.first as Map<String, dynamic>;
        expect(capturedData[NamaKolom.id], id);
        expect(capturedData[NamaKolom.waktuOtomatisSinkronisasi], 48);
      },
    );

    test(
      '05. harus melempar kembali Exception jika baseOpSqlite gagal',
      () async {
        // Arrange
        when(
          mockBaseOpSqlite.sisipkan(
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenThrow(Exception('Insert failed'));

        // Act & Assert
        expect(
          () => settingsOpSqlite.simpanAtauPerbaruiSettings(settingsModel),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('updateSettings', () {
    test(
      '06. harus memanggil baseOpSqlite.update dengan data parsial yang benar',
      () async {
        // Arrange
        final partialData = {NamaKolom.modeMaintenance: true};
        when(
          mockBaseOpSqlite.update(
            any,
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await settingsOpSqlite.perbaruiSettings(partialData);

        // Assert
        final captured = verify(
          mockBaseOpSqlite.update(namaTabel, captureAny, id),
        ).captured;

        final capturedData =
            captured.first as Map<String, dynamic>;
        expect(capturedData[NamaKolom.modeMaintenance], true);
        expect(capturedData.containsKey(NamaKolom.diperbaruiPada), isTrue);
      },
    );

    test(
      '07. harus melempar kembali Exception jika baseOpSqlite gagal',
      () async {
        // Arrange
        when(
          mockBaseOpSqlite.update(
            any,
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => settingsOpSqlite.perbaruiSettings({}),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('saveOrUpdateSettingsWithBatch', () {
    test(
      '08. harus memanggil baseOpSqlite.sisipkanAtauPerbaruiBatch dengan data yang benar',
      () async {
        // Arrange
        when(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenAnswer((_) async {});

        // Act
        await settingsOpSqlite.simpanAtauPerbaruiSettingsDenganBatch(
          settingsModel,
        );

        // Assert
        final captured = verify(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(namaTabel, captureAny),
        ).captured;

        final capturedList =
            captured.first as List<Map<String, dynamic>>;
        expect(capturedList.length, 1);
        expect(capturedList[0][NamaKolom.id], id);
        expect(capturedList[0][NamaKolom.waktuOtomatisSinkronisasi], 48);
      },
    );

    test(
      '09. harus melempar kembali Exception jika baseOpSqlite gagal',
      () async {
        // Arrange
        when(
          mockBaseOpSqlite.sisipkanAtauPerbaruiBatch(
            any,
            any,
            dariServer: anyNamed('dariServer'),
          ),
        ).thenThrow(Exception('Batch failed'));

        // Act & Assert
        expect(
          () => settingsOpSqlite.simpanAtauPerbaruiSettingsDenganBatch(
            settingsModel,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}

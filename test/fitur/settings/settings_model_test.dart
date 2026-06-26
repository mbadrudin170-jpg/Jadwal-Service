'''// path: test/fitur/settings/settings_model_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';

void main() {
  group('01. SettingsModel', () {
    test('01. harus membuat instance dengan nilai default yang benar', () {
      const settings = SettingsModel();

      expect(settings.id, 'global_config');
      expect(settings.waktuOtomatisSinkronisasi, 24);
      expect(settings.waktuOtomatisHapusDataArsip, 30);
      expect(settings.modeMaintenance, false);
      expect(settings.infoMaintenance, '');
    });

    test('02. harus mendukung perbandingan nilai (value equality)', () {
      const settings1 = SettingsModel();
      const settings2 = SettingsModel();
      const settings3 = SettingsModel(infoMaintenance: 'Toko Baru');

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('03. harus menghasilkan representasi String yang benar', () {
      const settings = SettingsModel();
      expect(
        settings.toString(),
        'SettingsModel(id: global_config, waktuOtomatisSinkronisasi: 24, waktuOtomatisHapusDataArsip: 30, modeMaintenance: false, infoMaintenance: , diperbaruiPada: null)',
      );
    });
  });

  group('02. copyWith', () {
    test('01. harus menyalin instance dengan nilai yang diperbarui', () {
      const original = SettingsModel();
      final copied = original.copyWith(
        infoMaintenance: 'Toko Kopi',
        modeMaintenance: true,
      );

      expect(copied.id, original.id);
      expect(copied.infoMaintenance, 'Toko Kopi');
      expect(copied.modeMaintenance, true);
    });

    test('02. harus mengembalikan instance yang sama jika tidak ada nilai', () {
      const original = SettingsModel();
      final copied = original.copyWith();

      expect(copied, same(original));
    });
  });

  group('03. from/to Map (untuk Sqflite)', () {
    final now = DateTime.now();
    final map = {
      'id': '1',
      'waktu_otomatis_sinkronisasi': 60,
      'waktu_otomatis_hapus_data_arsip': 90,
      'mode_maintenance': 1,
      'info_maintenance': 'Info',
      'diperbarui_pada': now.millisecondsSinceEpoch,
    };

    test('01. fromSqliteMap harus membuat instance yang benar dari map', () {
      final settings = SettingsModel.fromSqlite(map);

      expect(settings.waktuOtomatisSinkronisasi, 60);
      expect(settings.waktuOtomatisHapusDataArsip, 90);
      expect(settings.modeMaintenance, true);
      expect(settings.infoMaintenance, 'Info');
      expect(settings.diperbaruiPada, isNotNull);
    });

    test('02. toSqliteMap harus membuat map yang benar dari instance', () {
      final settings = SettingsModel(
        waktuOtomatisSinkronisasi: 60,
        waktuOtomatisHapusDataArsip: 90,
        modeMaintenance: true,
        infoMaintenance: 'Info',
        diperbaruiPada: now,
      );

      final resultMap = settings.toSqlite();

      expect(resultMap['waktu_otomatis_sinkronisasi'], 60);
      expect(resultMap['mode_maintenance'], 1);
      expect(resultMap['info_maintenance'], 'Info');
      expect(resultMap['diperbarui_pada'], now.millisecondsSinceEpoch);
    });
  });

  group('04. from/to Map (untuk Firebase)', () {
    final now = DateTime.now();
    final map = {
      'id': '1',
      'waktu_otomatis_sinkronisasi': 60,
      'waktu_otomatis_hapus_data_arsip': 90,
      'mode_maintenance': true,
      'info_maintenance': 'Info',
      'diperbarui_pada': now.toIso8601String(),
    };

    test('01. fromFirebaseMap harus membuat instance yang benar', () {
      final settings = SettingsModel.fromFirebase(map);

      expect(settings.waktuOtomatisSinkronisasi, 60);
      expect(settings.waktuOtomatisHapusDataArsip, 90);
      expect(settings.modeMaintenance, true);
      expect(settings.infoMaintenance, 'Info');
      expect(settings.diperbaruiPada, isNotNull);
    });

    test('02. toFirebaseMap harus membuat map yang benar', () {
      final settings = SettingsModel(
        waktuOtomatisSinkronisasi: 60,
        waktuOtomatisHapusDataArsip: 90,
        modeMaintenance: true,
        infoMaintenance: 'Info',
        diperbaruiPada: now,
      );

      final resultMap = settings.toFirebase();

      expect(resultMap['waktu_otomatis_sinkronisasi'], 60);
      expect(resultMap['mode_maintenance'], true);
      expect(resultMap['info_maintenance'], 'Info');
    });
  });
}
''
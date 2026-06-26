// path: test/fitur/settings/settings_model_test.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';

void main() {
  group('01. SettingsModel', () {
    test('01. harus membuat instance dengan nilai default yang benar', () {
      const settings = SettingsModel();

      expect(settings.id, '1');
      expect(settings.namaToko, 'Wifi');
      expect(settings.telepon, '08123456789');
      expect(settings.alamat, 'Alamat Wifi');
      expect(settings.namaWifi, 'Wifi');
      expect(settings.kataSandiWifi, '12345678');
      expect(settings.tema, ThemeMode.system);
      expect(settings.waktuOtomatisHapusDataArsip, 30);
      expect(settings.sinkronisasiOtomatis, true);
    });

    test('02. harus mendukung perbandingan nilai (value equality)', () {
      const settings1 = SettingsModel();
      const settings2 = SettingsModel();
      const settings3 = SettingsModel(namaToko: 'Toko Baru');

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('03. harus menghasilkan representasi String yang benar', () {
      const settings = SettingsModel();
      expect(
        settings.toString(),
        'SettingsModel(id: 1, namaToko: Wifi, telepon: 08123456789, alamat: Alamat Wifi, namaWifi: Wifi, kataSandiWifi: 12345678, tema: ThemeMode.system, waktuOtomatisHapusDataArsip: 30, sinkronisasiOtomatis: true)',
      );
    });
  });

  group('02. copyWith', () {
    test('01. harus menyalin instance dengan nilai yang diperbarui', () {
      const original = SettingsModel();
      final copied = original.copyWith(
        namaToko: 'Toko Kopi',
        tema: ThemeMode.dark,
      );

      expect(copied.id, original.id);
      expect(copied.namaToko, 'Toko Kopi');
      expect(copied.telepon, original.telepon);
      expect(copied.tema, ThemeMode.dark);
      expect(copied.sinkronisasiOtomatis, original.sinkronisasiOtomatis);
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
      'nama_toko': 'Toko Sqflite',
      'telepon': '111222333',
      'alamat': 'Jl. Sqflite',
      'nama_wifi': 'Wifi Sqflite',
      'kata_sandi_wifi': 'pass_sqflite',
      'tema': 'dark',
      'waktu_otomatis_hapus_data_arsip': 60,
      'sinkronisasi_otomatis': 0,
      'diperbarui_pada': now.millisecondsSinceEpoch,
    };

    test('01. fromSqliteMap harus membuat instance yang benar dari map', () {
      final settings = SettingsModel.fromSqliteMap(map);

      expect(settings.namaToko, 'Toko Sqflite');
      expect(settings.telepon, '111222333');
      expect(settings.tema, ThemeMode.dark);
      expect(settings.waktuOtomatisHapusDataArsip, 60);
      expect(settings.sinkronisasiOtomatis, false);
      expect(settings.diperbaruiPada, isNotNull);
    });

    test('02. toSqliteMap harus membuat map yang benar dari instance', () {
      final settings = SettingsModel(
        namaToko: 'Toko Sqflite',
        telepon: '111222333',
        alamat: 'Jl. Sqflite',
        namaWifi: 'Wifi Sqflite',
        kataSandiWifi: 'pass_sqflite',
        tema: ThemeMode.dark,
        waktuOtomatisHapusDataArsip: 60,
        sinkronisasiOtomatis: false,
        diperbaruiPada: now,
      );

      final resultMap = settings.toSqliteMap();

      expect(resultMap['nama_toko'], 'Toko Sqflite');
      expect(resultMap['tema'], 'dark');
      expect(resultMap['sinkronisasi_otomatis'], 0);
      expect(resultMap['diperbarui_pada'], now.millisecondsSinceEpoch);
    });

    test('03. toSqliteMap harus menangani tema yang tidak diketahui', () {
      final settings = SettingsModel(tema: ThemeMode.system);
      final map = settings.toSqliteMap();
      expect(map['tema'], 'system');
    });

    test('04. fromSqliteMap harus menangani tema yang tidak diketahui', () {
      final mapWithUnknownTheme = {...map, 'tema': 'tidak_diketahui'};
      final settings = SettingsModel.fromSqliteMap(mapWithUnknownTheme);
      expect(settings.tema, ThemeMode.system);
    });
  });

  group('04. from/to Map (untuk Firebase)', () {
    final now = DateTime.now();
    final map = {
      'id': '1',
      'nama_toko': 'Toko Firebase',
      'telepon': '444555666',
      'alamat': 'Jl. Firebase',
      'nama_wifi': 'Wifi Firebase',
      'kata_sandi_wifi': 'pass_firebase',
      'tema': 'light',
      'waktu_otomatis_hapus_data_arsip': 90,
      'sinkronisasi_otomatis': true,
      'diperbarui_pada': now.toIso8601String(),
    };

    test('01. fromFirebaseMap harus membuat instance yang benar', () {
      final settings = SettingsModel.fromFirebaseMap(map);

      expect(settings.namaToko, 'Toko Firebase');
      expect(settings.tema, ThemeMode.light);
      expect(settings.waktuOtomatisHapusDataArsip, 90);
      expect(settings.sinkronisasiOtomatis, isTrue);
      expect(settings.diperbaruiPada, isNotNull);
    });

    test('02. toFirebaseMap harus membuat map yang benar', () {
      final settings = SettingsModel(
        namaToko: 'Toko Firebase',
        telepon: '444555666',
        alamat: 'Jl. Firebase',
        namaWifi: 'Wifi Firebase',
        kataSandiWifi: 'pass_firebase',
        tema: ThemeMode.light,
        waktuOtomatisHapusDataArsip: 90,
        sinkronisasiOtomatis: true,
        diperbaruiPada: now,
      );

      final resultMap = settings.toFirebaseMap();

      expect(resultMap['nama_toko'], 'Toko Firebase');
      expect(resultMap['tema'], 'light');
      expect(resultMap['sinkronisasi_otomatis'], isTrue);
      expect(resultMap['diperbarui_pada'], now.toIso8601String());
    });
  });

  group('05. from/to Json (untuk String)', () {
    final jsonString = '{"id":"1","nama_toko":"Toko JSON"}';

    test('01. fromJson harus membuat instance dari string JSON', () {
      final settings = SettingsModel.fromJson(jsonString);
      expect(settings.namaToko, 'Toko JSON');
    });

    test('02. toJson harus membuat string JSON dari instance', () {
      const settings = SettingsModel(namaToko: 'Toko JSON');
      final encoded = json.decode(settings.toJson());
      expect(encoded['nama_toko'], 'Toko JSON');
    });
  });
}

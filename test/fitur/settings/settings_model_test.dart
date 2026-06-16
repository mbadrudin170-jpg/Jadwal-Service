// path: test/fitur/settings/settings_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('SettingsModel', () {
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);

    test('01. harus membuat instance dengan nilai default', () {
      const settings = SettingsModel();
      expect(settings.id, equals(idGlobalSetting));
      expect(settings.waktuOtomatisSinkronisasi, equals(24));
      expect(settings.waktuOtomatisHapusDataArsip, equals(30));
      expect(settings.modeMaintenance, isFalse);
      expect(settings.infoMaintenance, isEmpty);
      expect(settings.diperbaruiPada, isNull);
    });

    test('02. harus membuat instance dengan nilai custom', () {
      final settings = SettingsModel(
        id: 'custom_id',
        waktuOtomatisSinkronisasi: 12,
        waktuOtomatisHapusDataArsip: 15,
        modeMaintenance: true,
        infoMaintenance: 'Maintenance',
        diperbaruiPada: now,
      );
      expect(settings.id, 'custom_id');
      expect(settings.waktuOtomatisSinkronisasi, 12);
      expect(settings.waktuOtomatisHapusDataArsip, 15);
      expect(settings.modeMaintenance, isTrue);
      expect(settings.infoMaintenance, 'Maintenance');
      expect(settings.diperbaruiPada, now);
    });

    group('fromSqlite', () {
      test('03. harus membuat instance dari map SQLite dengan data lengkap',
          () {
        final map = {
          NamaKolom.id: 'sqlite_id',
          NamaKolom.waktuOtomatisSinkronisasi: 48,
          NamaKolom.waktuOtomatisHapusDataArsip: 60,
          NamaKolom.modeMaintenance: 1,
          NamaKolom.infoMaintenance: 'Dari SQLite',
          NamaKolom.diperbaruiPada: now.millisecondsSinceEpoch,
        };
        final settings = SettingsModel.fromSqlite(map);
        expect(settings.id, 'sqlite_id');
        expect(settings.waktuOtomatisSinkronisasi, 48);
        expect(settings.waktuOtomatisHapusDataArsip, 60);
        expect(settings.modeMaintenance, isTrue);
        expect(settings.infoMaintenance, 'Dari SQLite');
        expect(settings.diperbaruiPada?.millisecondsSinceEpoch,
            now.millisecondsSinceEpoch);
      });

      test(
          '04. harus membuat instance dari map SQLite dengan data tidak lengkap',
          () {
        final map = <String, dynamic>{};
        final settings = SettingsModel.fromSqlite(map);
        expect(settings.id, idGlobalSetting);
        expect(settings.waktuOtomatisSinkronisasi, 24);
        expect(settings.waktuOtomatisHapusDataArsip, 30);
        expect(settings.modeMaintenance, isFalse);
        expect(settings.infoMaintenance, isEmpty);
        expect(settings.diperbaruiPada, isNull);
      });
    });

    test('05. harus mengonversi ke map SQLite', () {
      final settings = SettingsModel(
        id: 'to_sqlite',
        waktuOtomatisSinkronisasi: 8,
        waktuOtomatisHapusDataArsip: 10,
        modeMaintenance: true,
        infoMaintenance: 'Ke SQLite',
        diperbaruiPada: now,
      );
      final map = settings.toSqlite();
      expect(map[NamaKolom.id], 'to_sqlite');
      expect(map[NamaKolom.waktuOtomatisSinkronisasi], 8);
      expect(map[NamaKolom.waktuOtomatisHapusDataArsip], 10);
      expect(map[NamaKolom.modeMaintenance], 1);
      expect(map[NamaKolom.infoMaintenance], 'Ke SQLite');
      expect(map[NamaKolom.diperbaruiPada], now.millisecondsSinceEpoch);
    });

    group('fromFirebase', () {
      test('06. harus membuat instance dari map Firebase dengan data lengkap',
          () {
        final map = {
          NamaKolom.id: 'firebase_id',
          NamaKolom.waktuOtomatisSinkronisasi: 72,
          NamaKolom.waktuOtomatisHapusDataArsip: 90,
          NamaKolom.modeMaintenance: true,
          NamaKolom.infoMaintenance: 'Dari Firebase',
          NamaKolom.diperbaruiPada: timestamp,
        };
        final settings = SettingsModel.fromFirebase(map);
        expect(settings.id, 'firebase_id');
        expect(settings.waktuOtomatisSinkronisasi, 72);
        expect(settings.waktuOtomatisHapusDataArsip, 90);
        expect(settings.modeMaintenance, isTrue);
        expect(settings.infoMaintenance, 'Dari Firebase');
        expect(settings.diperbaruiPada, now);
      });

      test(
          '07. harus membuat instance dari map Firebase dengan data tidak lengkap',
          () {
        final map = <String, dynamic>{};
        final settings = SettingsModel.fromFirebase(map);
        expect(settings.id, idGlobalSetting);
        expect(settings.waktuOtomatisSinkronisasi, 24);
        expect(settings.waktuOtomatisHapusDataArsip, 30);
        expect(settings.modeMaintenance, isFalse);
        expect(settings.infoMaintenance, isEmpty);
        expect(settings.diperbaruiPada, isNull);
      });
    });

    test('08. harus mengonversi ke map Firebase', () {
      final settings = SettingsModel(
        id: 'to_firebase',
        waktuOtomatisSinkronisasi: 3,
        waktuOtomatisHapusDataArsip: 5,
        modeMaintenance: false,
        infoMaintenance: 'Ke Firebase',
        diperbaruiPada: now,
      );
      final map = settings.toFirebase();
      expect(map[NamaKolom.id], 'to_firebase');
      expect(map[NamaKolom.waktuOtomatisSinkronisasi], 3);
      expect(map[NamaKolom.waktuOtomatisHapusDataArsip], 5);
      expect(map[NamaKolom.modeMaintenance], isFalse);
      expect(map[NamaKolom.infoMaintenance], 'Ke Firebase');
      expect((map[NamaKolom.diperbaruiPada] as Timestamp).toDate().toUtc(),
          now.toUtc());
    });
  });
}

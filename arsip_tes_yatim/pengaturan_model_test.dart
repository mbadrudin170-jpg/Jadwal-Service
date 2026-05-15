// path: test/shared/model/sqlite_model/pengaturan_model_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';

void main() {
  group('PengaturanModel', () {
    test('konstruktor default harus memiliki nilai yang benar', () {
      final model = PengaturanModel();
      expect(model.id, idPengaturanGlobal);
      expect(model.intervalSinkronisasiOtomatis, 24);
      expect(model.hapusOtomatisDataArsip, 30);
      expect(model.modePemeliharaan, false);
      expect(model.infoPemeliharaan, '');
      expect(model.diperbarui, null);
    });

    test('fromSqlite harus membuat model dengan benar', () {
      final now = DateTime.now();
      final map = {
        'interval_sinkronisasi_otomatis': 48,
        'hapus_otomatis_data_arsip': 60,
        'mode_pemeliharaan': 1,
        'info_pemeliharaan': 'Pemeliharaan terjadwal',
        'diperbarui': now.millisecondsSinceEpoch,
      };
      final model = PengaturanModel.fromSqlite(map);

      expect(model.intervalSinkronisasiOtomatis, 48);
      expect(model.hapusOtomatisDataArsip, 60);
      expect(model.modePemeliharaan, true);
      expect(model.infoPemeliharaan, 'Pemeliharaan terjadwal');
      expect(model.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('toSqlite harus mengonversi model dengan benar', () {
      final now = DateTime.now();
      final model = PengaturanModel(
        intervalSinkronisasiOtomatis: 48,
        hapusOtomatisDataArsip: 60,
        modePemeliharaan: true,
        infoPemeliharaan: 'Pemeliharaan terjadwal',
        diperbarui: now,
      );
      final map = model.toSqlite();

      expect(map['id'], idPengaturanGlobal);
      expect(map['interval_sinkronisasi_otomatis'], 48);
      expect(map['hapus_otomatis_data_arsip'], 60);
      expect(map['mode_pemeliharaan'], 1);
      expect(map['info_pemeliharaan'], 'Pemeliharaan terjadwal');
      expect(map['diperbarui'], now.millisecondsSinceEpoch);
    });

    test('fromFirebase harus membuat model dengan benar', () {
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      final data = {
        'id': idPengaturanGlobal,
        'interval_sinkronisasi_otomatis': 48,
        'hapus_otomatis_data_arsip': 60,
        'mode_pemeliharaan': true,
        'info_pemeliharaan': 'Pemeliharaan terjadwal',
        'diperbarui': timestamp,
      };
      final model = PengaturanModel.fromFirebase(data);

      expect(model.id, idPengaturanGlobal);
      expect(model.intervalSinkronisasiOtomatis, 48);
      expect(model.hapusOtomatisDataArsip, 60);
      expect(model.modePemeliharaan, true);
      expect(model.infoPemeliharaan, 'Pemeliharaan terjadwal');
      expect(model.diperbarui, now);
    });

    test('toFirebase harus mengonversi model dengan benar', () {
      final now = DateTime.now();
      final model = PengaturanModel(
        diperbarui: now,
      );
      final map = model.toFirebase();

      expect(map['id'], idPengaturanGlobal);
      expect(map['diperbarui'], isA<FieldValue>());
    });

    test('copyWith harus menyalin dan memperbarui model dengan benar', () {
      final model = PengaturanModel();
      final now = DateTime.now();
      final updatedModel = model.copyWith(
        intervalSinkronisasiOtomatis: 12,
        modePemeliharaan: true,
        diperbarui: now,
      );

      expect(updatedModel.intervalSinkronisasiOtomatis, 12);
      expect(updatedModel.hapusOtomatisDataArsip, model.hapusOtomatisDataArsip);
      expect(updatedModel.modePemeliharaan, true);
      expect(updatedModel.infoPemeliharaan, model.infoPemeliharaan);
      expect(updatedModel.diperbarui, now);
    });
  });
}

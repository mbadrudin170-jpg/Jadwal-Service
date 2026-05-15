// path: test/shared/model/pengaturan_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';

void main() {
  group('PengaturanModel', () {
    final now = DateTime.now();

    // 1. Uji Konstruktor dan Nilai Default
    test('Konstruktor harus menggunakan ID global dan menerapkan nilai default', () {
      final pengaturan = PengaturanModel();

      expect(pengaturan.id, idPengaturanGlobal);
      expect(pengaturan.intervalSinkronisasiOtomatis, 24);
      expect(pengaturan.hapusOtomatisDataArsip, 30);
      expect(pengaturan.modePemeliharaan, isFalse);
      expect(pengaturan.infoPemeliharaan, '');
      expect(pengaturan.diperbarui, isNull);
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin dan memperbarui properti dengan benar', () {
      final pengaturanAsli = PengaturanModel();
      final pengaturanBaru = pengaturanAsli.copyWith(
        intervalSinkronisasiOtomatis: 48,
        modePemeliharaan: true,
        infoPemeliharaan: 'Sedang dalam perbaikan.',
      );

      expect(pengaturanBaru.id, idPengaturanGlobal);
      expect(pengaturanBaru.intervalSinkronisasiOtomatis, 48);
      expect(pengaturanBaru.hapusOtomatisDataArsip, pengaturanAsli.hapusOtomatisDataArsip);
      expect(pengaturanBaru.modePemeliharaan, isTrue);
      expect(pengaturanBaru.infoPemeliharaan, 'Sedang dalam perbaikan.');
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': idPengaturanGlobal,
        'interval_sinkronisasi_otomatis': 12,
        'hapus_otomatis_data_arsip': 60,
        'mode_pemeliharaan': 1,
        'info_pemeliharaan': 'Maintenance SQLite',
        'diperbarui': now.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final pengaturan = PengaturanModel.fromSqlite(sqliteMap);

        expect(pengaturan.id, idPengaturanGlobal);
        expect(pengaturan.intervalSinkronisasiOtomatis, 12);
        expect(pengaturan.hapusOtomatisDataArsip, 60);
        expect(pengaturan.modePemeliharaan, isTrue);
        expect(pengaturan.infoPemeliharaan, 'Maintenance SQLite');
        expect(pengaturan.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toSqlite harus menghasilkan map dengan benar', () {
        final pengaturan = PengaturanModel(
          intervalSinkronisasiOtomatis: 12,
          hapusOtomatisDataArsip: 60,
          modePemeliharaan: true,
          infoPemeliharaan: 'Maintenance SQLite',
          diperbarui: now,
        );

        final hasilMap = pengaturan.toSqlite();
        expect(hasilMap, sqliteMap);
      });

      test('fromSqlite harus menangani nilai null dan menerapkan default', () {
        final mapKosong = <String, dynamic>{}; // Map kosong
        final pengaturan = PengaturanModel.fromSqlite(mapKosong);

        expect(pengaturan.intervalSinkronisasiOtomatis, 24); // Default
        expect(pengaturan.hapusOtomatisDataArsip, 30); // Default
        expect(pengaturan.modePemeliharaan, isFalse); // Default
        expect(pengaturan.infoPemeliharaan, ''); // Default
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final firebaseData = {
        'id': idPengaturanGlobal,
        'interval_sinkronisasi_otomatis': 6,
        'hapus_otomatis_data_arsip': 15,
        'mode_pemeliharaan': true,
        'info_pemeliharaan': 'Firebase Maintenance',
        'diperbarui': Timestamp.fromDate(now),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final pengaturan = PengaturanModel.fromFirebase(firebaseData);

        expect(pengaturan.id, idPengaturanGlobal);
        expect(pengaturan.intervalSinkronisasiOtomatis, 6);
        expect(pengaturan.hapusOtomatisDataArsip, 15);
        expect(pengaturan.modePemeliharaan, isTrue);
        expect(pengaturan.infoPemeliharaan, 'Firebase Maintenance');
        expect(pengaturan.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toFirebase harus menghasilkan map dengan benar', () {
        final pengaturan = PengaturanModel(
          intervalSinkronisasiOtomatis: 6,
          hapusOtomatisDataArsip: 15,
          modePemeliharaan: true,
          infoPemeliharaan: 'Firebase Maintenance',
        );

        final hasilMap = pengaturan.toFirebase();

        // 'diperbarui' akan berbeda, jadi kita cek manual
        expect(hasilMap['id'], idPengaturanGlobal);
        expect(hasilMap['interval_sinkronisasi_otomatis'], 6);
        expect(hasilMap['hapus_otomatis_data_arsip'], 15);
        expect(hasilMap['mode_pemeliharaan'], isTrue);
        expect(hasilMap['info_pemeliharaan'], 'Firebase Maintenance');
        expect(hasilMap['diperbarui'], isA<FieldValue>());
      });

       test('fromFirebase harus menangani nilai null dan menerapkan default', () {
        final dataKosong = <String, dynamic>{}; // Data kosong
        final pengaturan = PengaturanModel.fromFirebase(dataKosong);

        expect(pengaturan.intervalSinkronisasiOtomatis, 24);
        expect(pengaturan.hapusOtomatisDataArsip, 30);
        expect(pengaturan.modePemeliharaan, isFalse);
        expect(pengaturan.infoPemeliharaan, '');
      });
    });
  });
}

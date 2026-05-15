// path: test/shared/model/pelanggan_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';

void main() {
  group('PelangganModel', () {
    final now = DateTime.now();
    final pelangganTest = PelangganModel(
      id: 'user-1',
      nama: 'Budi Santoso',
      telepon: '08123456789',
      alamat: 'Jl. Merdeka No. 1',
      password: 'Rahasia123',
      macAddress: '00:1A:2B:3C:4D:5E',
      diperbarui: now,
      diarsipkan: now,
    );

    // 1. Uji Konstruktor
    test('Konstruktor harus membuat ID jika null dan menerapkan nilai default', () {
      final pelanggan = PelangganModel(
        nama: 'Ani',
        telepon: '08987654321',
        alamat: 'Jl. Baru',
        password: 'password',
      );
      expect(pelanggan.id, isNotNull);
      expect(pelanggan.macAddress, ''); // Default
      expect(pelanggan.isDeleted, isFalse); // Default
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin dan memperbarui field dengan benar', () {
      final pelangganBaru = pelangganTest.copyWith(
        nama: 'Budi Gunawan',
        alamat: 'Jl. Kemerdekaan No. 10',
        isDeleted: true,
      );
      expect(pelangganBaru.nama, 'Budi Gunawan');
      expect(pelangganBaru.alamat, 'Jl. Kemerdekaan No. 10');
      expect(pelangganBaru.isDeleted, isTrue);
      expect(pelangganBaru.telepon, pelangganTest.telepon);
    });

    // 3. Uji toJson
    test('toJson harus menyembunyikan password', () {
      final json = pelangganTest.toJson();
      expect(json['password'], '[TERSEMBUNYI]');
      expect(json['nama'], 'Budi Santoso');
      expect(json['id'], 'user-1');
    });

    // 4. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': 'sqlite-1',
        'nama': 'Siti',
        'telepon': '0811',
        'alamat': 'Jl. SQLite',
        'password': 'dbpass',
        'mac_address': 'FF:FF:FF:FF:FF:FF',
        'isDeleted': 1,
        'diperbarui': now.millisecondsSinceEpoch,
        'diarsipkan': now.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final pelanggan = PelangganModel.fromSqlite(sqliteMap);
        expect(pelanggan.id, 'sqlite-1');
        expect(pelanggan.nama, 'Siti');
        expect(pelanggan.telepon, '0811');
        expect(pelanggan.alamat, 'Jl. SQLite');
        expect(pelanggan.password, 'dbpass');
        expect(pelanggan.macAddress, 'FF:FF:FF:FF:FF:FF');
        expect(pelanggan.isDeleted, isTrue);
        expect(pelanggan.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(pelanggan.diarsipkan?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toSqlite harus membuat map dengan benar', () {
        final pelanggan = PelangganModel.fromSqlite(sqliteMap);
        final hasilMap = pelanggan.toSqlite();
        expect(hasilMap, sqliteMap);
      });

      test('fromSqlite harus menangani nilai null dan default', () {
        final mapKosong = {'id': 'kosong'};
        final pelanggan = PelangganModel.fromSqlite(mapKosong);
        expect(pelanggan.nama, '');
        expect(pelanggan.telepon, '');
        expect(pelanggan.alamat, '');
        expect(pelanggan.password, '');
        expect(pelanggan.macAddress, '');
        expect(pelanggan.isDeleted, isFalse);
      });
    });

    // 5. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final firebaseData = {
        'nama': 'Joko',
        'telepon': '0822',
        'alamat': 'Jl. Firebase',
        'password': 'fbpass',
        'mac_address': 'AA:BB:CC:DD:EE:FF',
        'isDeleted': false,
        'diperbarui': Timestamp.fromDate(now),
        'diarsipkan': Timestamp.fromDate(now),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final pelanggan = PelangganModel.fromFirebase('fb-1', firebaseData);
        expect(pelanggan.id, 'fb-1');
        expect(pelanggan.nama, 'Joko');
        expect(pelanggan.password, 'fbpass');
        expect(pelanggan.macAddress, 'AA:BB:CC:DD:EE:FF');
        expect(pelanggan.isDeleted, false);
        expect(pelanggan.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toFirebase harus membuat map dengan benar', () {
        final pelanggan = PelangganModel(
          nama: 'Joko',
          telepon: '0822',
          alamat: 'Jl. Firebase',
          password: 'fbpass',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          diarsipkan: now,
        );
        final hasilMap = pelanggan.toFirebase();
        expect(hasilMap['nama'], 'Joko');
        expect(hasilMap['password'], 'fbpass');
        expect(hasilMap['mac_address'], 'AA:BB:CC:DD:EE:FF');
        expect(hasilMap['diperbarui'], isA<FieldValue>());
        expect(hasilMap['diarsipkan'], Timestamp.fromDate(now));
      });

      test('toFirebase harus menangani diarsipkan null', () {
          final pelanggan = PelangganModel(nama: 'Test', telepon: '1', alamat: 'a', password: 'p');
          final hasilMap = pelanggan.toFirebase();
          expect(hasilMap['diarsipkan'], isNull);
      });
    });
  });
}

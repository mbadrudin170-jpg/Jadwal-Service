// path: test/shared/model/paket_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/paket_model.dart';

void main() {
  group('TipeDurasi Enum', () {
    test('displayName harus mengembalikan string yang benar', () {
      expect(TipeDurasi.menit.displayName, 'Menit');
      expect(TipeDurasi.jam.displayName, 'Jam');
      expect(TipeDurasi.hari.displayName, 'Hari');
      expect(TipeDurasi.bulan.displayName, 'Bulan');
    });
  });

  group('PaketModel', () {
    final now = DateTime.now();

    // 1. Uji Konstruktor dan Nilai Default
    test('Konstruktor harus membuat ID dan menerapkan nilai default dengan benar', () {
      final paket = PaketModel(
        nama: 'Paket Dasar',
        harga: 50000,
        durasi: 30,
        tipe: TipeDurasi.hari,
      );

      expect(paket.id, isNotNull);
      expect(paket.nama, 'Paket Dasar');
      expect(paket.harga, 50000);
      expect(paket.durasi, 30);
      expect(paket.tipe, TipeDurasi.hari);
      // Pengujian nilai default
      expect(paket.poinHadiah, 0);
      expect(paket.poinPenukaran, 0);
      expect(paket.isPublic, isTrue);
      expect(paket.isDeleted, isFalse);
      expect(paket.diperbarui, isNull);
      expect(paket.diarsipkan, isNull);
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin dan memperbarui field dengan benar', () {
      final paketAsli = PaketModel(nama: 'Lama', harga: 10, durasi: 1, tipe: TipeDurasi.jam);
      final paketBaru = paketAsli.copyWith(
        nama: 'Baru',
        harga: 20,
        isPublic: false,
        poinHadiah: 100,
      );

      expect(paketBaru.id, paketAsli.id);
      expect(paketBaru.nama, 'Baru');
      expect(paketBaru.harga, 20);
      expect(paketBaru.durasi, paketAsli.durasi);
      expect(paketBaru.tipe, paketAsli.tipe);
      expect(paketBaru.isPublic, isFalse);
      expect(paketBaru.poinHadiah, 100);
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': 'sqlite-1',
        'nama': 'Paket SQLite',
        'harga': 75000,
        'durasi': 1,
        'tipe': 'bulan',
        'poin_hadiah': 50,
        'poin_penukaran': 500,
        'isPublic': 0, // false
        'isDeleted': 1, // true
        'diperbarui': now.millisecondsSinceEpoch,
        'diarsipkan': now.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final paket = PaketModel.fromSqlite(sqliteMap);

        expect(paket.id, 'sqlite-1');
        expect(paket.nama, 'Paket SQLite');
        expect(paket.harga, 75000);
        expect(paket.durasi, 1);
        expect(paket.tipe, TipeDurasi.bulan);
        expect(paket.poinHadiah, 50);
        expect(paket.poinPenukaran, 500);
        expect(paket.isPublic, isFalse);
        expect(paket.isDeleted, isTrue);
        expect(paket.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(paket.diarsipkan?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toSqlite harus membuat map dengan benar', () {
        final paket = PaketModel(
          id: 'sqlite-1',
          nama: 'Paket SQLite',
          harga: 75000,
          durasi: 1,
          tipe: TipeDurasi.bulan,
          poinHadiah: 50,
          poinPenukaran: 500,
          isPublic: false,
          isDeleted: true,
          diperbarui: now,
          diarsipkan: now,
        );

        final hasilMap = paket.toSqlite();
        expect(hasilMap, equals(sqliteMap));
      });

      test('fromSqlite harus menangani nilai null dan default', () {
          final mapKosong = {'id': 'id-kosong'};
          final paket = PaketModel.fromSqlite(mapKosong);
          expect(paket.nama, '');
          expect(paket.harga, 0);
          expect(paket.durasi, 0);
          expect(paket.tipe, TipeDurasi.hari); // Default orElse
          expect(paket.poinHadiah, 0);
          expect(paket.isPublic, isFalse);
          expect(paket.isDeleted, isFalse);
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final firebaseData = {
        'id': 'fb-1',
        'nama': 'Paket Firebase',
        'harga': 100000,
        'durasi': 60,
        'tipe': 'menit',
        'poin_hadiah': 10,
        'poin_penukaran': 100,
        'isPublic': true,
        'isDeleted': false,
        'diperbarui': Timestamp.fromDate(now),
        'diarsipkan': Timestamp.fromDate(now),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final paket = PaketModel.fromFirebase('fb-1', firebaseData);

        expect(paket.id, 'fb-1');
        expect(paket.nama, 'Paket Firebase');
        expect(paket.harga, 100000);
        expect(paket.durasi, 60);
        expect(paket.tipe, TipeDurasi.menit);
        expect(paket.poinHadiah, 10);
        expect(paket.poinPenukaran, 100);
        expect(paket.isPublic, isTrue);
        expect(paket.isDeleted, isFalse);
        expect(paket.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(paket.diarsipkan?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toFirebase harus membuat map dengan benar', () {
        final paket = PaketModel(
          id: 'fb-1',
          nama: 'Paket Firebase',
          harga: 100000,
          durasi: 60,
          tipe: TipeDurasi.menit,
          poinHadiah: 10,
          poinPenukaran: 100,
          diarsipkan: now,
        );

        final hasilMap = paket.toFirebase();

        // 'diperbarui' akan berbeda karena merupakan FieldValue, jadi kita cek manual
        expect(hasilMap['id'], 'fb-1');
        expect(hasilMap['nama'], 'Paket Firebase');
        expect(hasilMap['harga'], 100000);
        expect(hasilMap['isPublic'], isTrue);
        expect(hasilMap['diarsipkan'], Timestamp.fromDate(now));
        expect(hasilMap['diperbarui'], isA<FieldValue>());
      });

      test('toFirebase tidak menyertakan diarsipkan jika null', () {
          final paket = PaketModel(nama: 'Test', harga: 1, durasi: 1, tipe: TipeDurasi.jam);
          final hasilMap = paket.toFirebase();
          expect(hasilMap.containsKey('diarsipkan'), isFalse);
      });
    });
  });
}

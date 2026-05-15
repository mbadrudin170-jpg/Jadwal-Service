// path: test/shared/model/pesanan_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/pesanan_model.dart';

void main() {
  group('PesananModel', () {
    final tanggalPesan = DateTime(2023, 10, 26, 10);

    // 1. Uji Konstruktor
    test('Konstruktor harus membuat ID jika null dan menyimpan nilai', () {
      final pesanan = PesananModel(
        idPelanggan: 'p-001',
        idPaket: 'pkt-001',
        tanggal: tanggalPesan,
        status: 'baru',
      );

      expect(pesanan.id, isNotNull);
      expect(pesanan.idPelanggan, 'p-001');
      expect(pesanan.tanggal, tanggalPesan);
      expect(pesanan.status, 'baru');
      expect(pesanan.isDeleted, isFalse); // Default
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin dan memperbarui field dengan benar', () {
      final pesananAsli = PesananModel(
        id: 'order-1',
        idPelanggan: 'p-001',
        idPaket: 'pkt-001',
        tanggal: tanggalPesan,
        status: 'baru',
      );
      final pesananBaru = pesananAsli.copyWith(
        status: 'diproses',
        isDeleted: true,
      );

      expect(pesananBaru.id, pesananAsli.id);
      expect(pesananBaru.idPaket, pesananAsli.idPaket);
      expect(pesananBaru.status, 'diproses');
      expect(pesananBaru.isDeleted, isTrue);
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': 'sqlite-order-1',
        'id_pelanggan': 'p-sqlite',
        'id_paket': 'pkt-sqlite',
        'tanggal': tanggalPesan.millisecondsSinceEpoch,
        'status': 'selesai',
        'isDeleted': 1,
        'diperbarui': tanggalPesan.millisecondsSinceEpoch,
        'diarsipkan': tanggalPesan.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final pesanan = PesananModel.fromSqlite(sqliteMap);

        expect(pesanan.id, 'sqlite-order-1');
        expect(pesanan.idPelanggan, 'p-sqlite');
        expect(pesanan.tanggal.millisecondsSinceEpoch, tanggalPesan.millisecondsSinceEpoch);
        expect(pesanan.status, 'selesai');
        expect(pesanan.isDeleted, isTrue);
        expect(pesanan.diperbarui, isNotNull);
      });

      test('toSqlite harus menghasilkan map dengan benar', () {
        final pesanan = PesananModel.fromSqlite(sqliteMap);
        final hasilMap = pesanan.toSqlite();
        expect(hasilMap, sqliteMap);
      });

      test('fromSqlite harus menangani nilai null dan default', () {
        final mapKosong = {
            'id': 'kosong-1',
            'tanggal': DateTime.now().millisecondsSinceEpoch,
        };
        final pesanan = PesananModel.fromSqlite(mapKosong);
        expect(pesanan.idPelanggan, '');
        expect(pesanan.idPaket, '');
        expect(pesanan.status, 'baru'); // Default
        expect(pesanan.isDeleted, isFalse);
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final firebaseData = {
        'id_pelanggan': 'p-firebase',
        'id_paket': 'pkt-firebase',
        'tanggal': Timestamp.fromDate(tanggalPesan),
        'status': 'dibatalkan',
        'isDeleted': false,
        'diperbarui': Timestamp.fromDate(tanggalPesan),
        'diarsipkan': Timestamp.fromDate(tanggalPesan),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final pesanan = PesananModel.fromFirebase('fb-order-1', firebaseData);

        expect(pesanan.id, 'fb-order-1');
        expect(pesanan.idPelanggan, 'p-firebase');
        expect(pesanan.tanggal, tanggalPesan);
        expect(pesanan.status, 'dibatalkan');
        expect(pesanan.isDeleted, isFalse);
      });

      test('toFirebase harus menghasilkan map dengan benar', () {
        final pesanan = PesananModel(
          id: 'fb-order-2',
          idPelanggan: 'p-fb',
          idPaket: 'pkt-fb',
          tanggal: tanggalPesan,
          status: 'baru',
          diarsipkan: tanggalPesan,
        );

        final hasilMap = pesanan.toFirebase();

        expect(hasilMap['id'], 'fb-order-2');
        expect(hasilMap['id_pelanggan'], 'p-fb');
        expect(hasilMap['tanggal'], Timestamp.fromDate(tanggalPesan));
        expect(hasilMap['diperbarui'], isA<FieldValue>());
        expect(hasilMap['diarsipkan'], Timestamp.fromDate(tanggalPesan));
      });

      test('toFirebase harus menangani diarsipkan null', () {
          final pesanan = PesananModel(idPelanggan: 'p', idPaket: 'pkt', tanggal: DateTime.now(), status: 's');
          final hasilMap = pesanan.toFirebase();
          expect(hasilMap.containsKey('diarsipkan'), isFalse);
      });

      test('fromFirebase harus menangani nilai null dan default', () {
        final dataKosong = {
            'tanggal': Timestamp.now(),
        };
        final pesanan = PesananModel.fromFirebase('id-kosong', dataKosong);
        expect(pesanan.idPelanggan, '');
        expect(pesanan.idPaket, '');
        expect(pesanan.status, 'baru');
      });
    });
  });
}

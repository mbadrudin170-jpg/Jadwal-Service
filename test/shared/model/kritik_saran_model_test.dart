// path: test/shared/model/kritik_saran_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';

void main() {
  group('KritikSaranModel', () {
    final now = DateTime.now();
    const userId = 'user-123';

    // 1. Uji Konstruktor
    test('Konstruktor harus membuat ID jika tidak disediakan', () {
      final kritik = KritikSaranModel(isi: 'Bagus!', userId: userId);
      expect(kritik.id, isNotNull);
      expect(kritik.isi, 'Bagus!');
      expect(kritik.userId, userId);
      expect(kritik.tanggal, isNull); // Default
    });

    test('Konstruktor harus menggunakan nilai yang disediakan', () {
      final kritik = KritikSaranModel(
        id: 'kritik-1',
        isi: 'Perlu perbaikan',
        userId: userId,
        tanggal: now,
        diperbarui: now,
      );
      expect(kritik.id, 'kritik-1');
      expect(kritik.isi, 'Perlu perbaikan');
      expect(kritik.userId, userId);
      expect(kritik.tanggal, now);
      expect(kritik.diperbarui, now);
    });

    // 2. Uji copyWith
    test('copyWith harus memperbarui field yang ditentukan', () {
      final kritikAsli = KritikSaranModel(isi: 'Lama', userId: 'user-lama');
      final tanggalBaru = DateTime(2025);
      final kritikBaru = kritikAsli.copyWith(
        isi: 'Baru',
        userId: 'user-baru',
        tanggal: tanggalBaru,
      );

      expect(kritikBaru.id, kritikAsli.id);
      expect(kritikBaru.isi, 'Baru');
      expect(kritikBaru.userId, 'user-baru');
      expect(kritikBaru.tanggal, tanggalBaru);
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': 'sqlite-1',
        'isi': 'Tes SQLite',
        'userId': userId,
        'tanggal': now.millisecondsSinceEpoch,
        'diperbarui': now.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final kritik = KritikSaranModel.fromSqlite(sqliteMap);
        expect(kritik.id, 'sqlite-1');
        expect(kritik.isi, 'Tes SQLite');
        expect(kritik.userId, userId);
        expect(kritik.tanggal?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(kritik.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toSqlite harus membuat map dengan benar', () {
        final kritik = KritikSaranModel(
          id: 'sqlite-1',
          isi: 'Tes SQLite',
          userId: userId,
          tanggal: now,
          diperbarui: now,
        );
        final hasilMap = kritik.toSqlite();
        expect(hasilMap['id'], 'sqlite-1');
        expect(hasilMap['isi'], 'Tes SQLite');
        expect(hasilMap['userId'], userId);
        expect(hasilMap['tanggal'], now.millisecondsSinceEpoch);
        expect(hasilMap['diperbarui'], now.millisecondsSinceEpoch);
      });

      test('fromSqlite harus menangani nilai null dan default', () {
        final mapKosong = {
          'id': 'id-kosong',
          'isi': null,
          'userId': null,
          'tanggal': null,
        };
        final kritik = KritikSaranModel.fromSqlite(mapKosong);
        expect(kritik.id, 'id-kosong');
        expect(kritik.isi, '');
        expect(kritik.userId, '');
        expect(kritik.tanggal, isNull);
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final firebaseData = {
        'id': 'fb-1', // ID diabaikan di fromFirebase, tapi disertakan untuk kelengkapan
        'isi': 'Tes Firebase',
        'userId': userId,
        'tanggal': Timestamp.fromDate(now),
        'diperbarui': Timestamp.fromDate(now),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final kritik = KritikSaranModel.fromFirebase('fb-1', firebaseData);
        expect(kritik.id, 'fb-1');
        expect(kritik.isi, 'Tes Firebase');
        expect(kritik.userId, userId);
        expect(kritik.tanggal?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(kritik.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toFirebase harus membuat map dengan benar (dengan tanggal)', () {
        final kritik = KritikSaranModel(
          id: 'fb-1',
          isi: 'Tes Firebase',
          userId: userId,
          tanggal: now,
        );
        final hasilMap = kritik.toFirebase();
        expect(hasilMap['id'], 'fb-1');
        expect(hasilMap['isi'], 'Tes Firebase');
        expect(hasilMap['userId'], userId);
        expect(hasilMap['tanggal'], Timestamp.fromDate(now));
        expect(hasilMap['diperbarui'], isA<FieldValue>());
      });

      test('toFirebase harus menggunakan server timestamp jika tanggal null', () {
        final kritik = KritikSaranModel(
          id: 'fb-2',
          isi: 'Tes tanpa tanggal',
          userId: userId,
        );
        final hasilMap = kritik.toFirebase();
        expect(hasilMap['tanggal'], isA<FieldValue>());
        expect(hasilMap['tanggal'], FieldValue.serverTimestamp());
      });

       test('fromFirebase harus menangani nilai null dan default', () {
        final dataKosong = {
          'isi': null,
          'userId': null,
          'tanggal': null,
        };
        final kritik = KritikSaranModel.fromFirebase('kosong-fb', dataKosong);
        expect(kritik.id, 'kosong-fb');
        expect(kritik.isi, '');
        expect(kritik.userId, '');
        // Default ke DateTime.now() jika tanggal null
        expect(kritik.tanggal, isA<DateTime>()); 
      });
    });
  });
}

// path: test/shared/model/dompet_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/dompet_model.dart';

void main() {
  group('DompetModel', () {
    // 1. Uji Konstruktor
    test('Konstruktor harus membuat ID jika tidak disediakan', () {
      final dompet = DompetModel(namaDompet: 'Test', saldo: 100);
      expect(dompet.id, isNotNull);
      expect(dompet.id, isA<String>());
      expect(dompet.namaDompet, 'Test');
      expect(dompet.saldo, 100);
      expect(dompet.isDeleted, isFalse);
    });

    test('Konstruktor harus menggunakan ID yang disediakan', () {
      final dompet = DompetModel(id: 'custom-id', namaDompet: 'Test', saldo: 100);
      expect(dompet.id, 'custom-id');
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin instance dengan benar', () {
      final now = DateTime.now();
      final dompetAsli = DompetModel(
        id: '123',
        namaDompet: 'Dompet Utama',
        saldo: 500.0,
        diperbarui: now,
      );

      final salinanDompet = dompetAsli.copyWith();

      expect(salinanDompet.id, dompetAsli.id);
      expect(salinanDompet.namaDompet, dompetAsli.namaDompet);
      expect(salinanDompet.saldo, dompetAsli.saldo);
      expect(salinanDompet.diperbarui, dompetAsli.diperbarui);
      expect(salinanDompet.isDeleted, dompetAsli.isDeleted);
      expect(salinanDompet.diarsipkan, dompetAsli.diarsipkan);
    });

    test('copyWith harus memperbarui field yang ditentukan', () {
      final now = DateTime.now();
      final diperbaruiBaru = now.add(const Duration(days: 1));
      final dompetAsli = DompetModel(namaDompet: 'Lama', saldo: 10);
      final dompetBaru = dompetAsli.copyWith(
        namaDompet: 'Baru',
        saldo: 20,
        isDeleted: true,
        diperbarui: diperbaruiBaru,
      );

      expect(dompetBaru.id, dompetAsli.id);
      expect(dompetBaru.namaDompet, 'Baru');
      expect(dompetBaru.saldo, 20);
      expect(dompetBaru.isDeleted, isTrue);
      expect(dompetBaru.diperbarui, diperbaruiBaru);
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final now = DateTime.now();
      final sqliteMap = {
        'id': 'sqlite-1',
        'namaDompet': 'Dompet SQLite',
        'saldo': 250.5,
        'diperbarui': now.millisecondsSinceEpoch,
        'isDeleted': 1,
        'diarsipkan': now.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final dompet = DompetModel.fromSqlite(sqliteMap);

        expect(dompet.id, 'sqlite-1');
        expect(dompet.namaDompet, 'Dompet SQLite');
        expect(dompet.saldo, 250.5);
        expect(dompet.isDeleted, isTrue);
        // Membandingkan dalam millisecondsSinceEpoch untuk presisi
        expect(dompet.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(dompet.diarsipkan?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toSqlite harus membuat map dengan benar', () {
        final dompet = DompetModel(
          id: 'sqlite-1',
          namaDompet: 'Dompet SQLite',
          saldo: 250.5,
          diperbarui: now,
          isDeleted: true,
          diarsipkan: now,
        );

        final hasilMap = dompet.toSqlite();
        expect(hasilMap['id'], 'sqlite-1');
        expect(hasilMap['namaDompet'], 'Dompet SQLite');
        expect(hasilMap['saldo'], 250.5);
        expect(hasilMap['isDeleted'], 1);
        expect(hasilMap['diperbarui'], now.millisecondsSinceEpoch);
        expect(hasilMap['diarsipkan'], now.millisecondsSinceEpoch);
      });

      test('fromSqlite harus menangani nilai null dan default', () {
        final mapKosong = {
          'id': 'kosong-id',
          'namaDompet': null,
          'saldo': null,
          'isDeleted': 0,
        };
        final dompet = DompetModel.fromSqlite(mapKosong);

        expect(dompet.id, 'kosong-id');
        expect(dompet.namaDompet, ''); // Default ke string kosong
        expect(dompet.saldo, 0.0); // Default ke 0.0
        expect(dompet.isDeleted, isFalse);
        expect(dompet.diperbarui, isNull);
        expect(dompet.diarsipkan, isNull);
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final now = DateTime.now();
      // Firestore mengembalikan Timestamp, jadi kita simulasikan itu
      final firebaseData = {
        'namaDompet': 'Dompet Firebase',
        'saldo': 300.0,
        'diperbarui': Timestamp.fromDate(now),
        'isDeleted': false,
        'diarsipkan': Timestamp.fromDate(now),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final dompet = DompetModel.fromFirebase('firebase-1', firebaseData);
        expect(dompet.id, 'firebase-1');
        expect(dompet.namaDompet, 'Dompet Firebase');
        expect(dompet.saldo, 300.0);
        expect(dompet.isDeleted, isFalse);
        // Membandingkan dalam millisecondsSinceEpoch untuk menghindari masalah presisi zona waktu
        expect(dompet.diperbarui?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
        expect(dompet.diarsipkan?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      });

      test('toFirebase harus membuat map dengan benar', () {
        final dompet = DompetModel(
          id: 'firebase-1',
          namaDompet: 'Dompet Firebase',
          saldo: 300.0,
          diarsipkan: now,
        );

        final hasilMap = dompet.toFirebase();

        expect(hasilMap['id'], 'firebase-1');
        expect(hasilMap['namaDompet'], 'Dompet Firebase');
        expect(hasilMap['saldo'], 300.0);
        expect(hasilMap['isDeleted'], false);
        expect(hasilMap['diperbarui'], isA<FieldValue>());
        expect(hasilMap['diperbarui'], FieldValue.serverTimestamp());
        expect(hasilMap['diarsipkan'], Timestamp.fromDate(now));
      });

      test('toFirebase tidak menyertakan diarsipkan jika null', () {
        final dompet = DompetModel(
          id: 'firebase-1',
          namaDompet: 'Dompet Firebase',
          saldo: 300.0,
        );
        final hasilMap = dompet.toFirebase();
        expect(hasilMap.containsKey('diarsipkan'), isFalse);
      });

      test('fromFirebase harus menangani nilai null dan default', () {
        final dataKosong = {
          'namaDompet': null,
          'saldo': null,
          'isDeleted': null,
        };
        final dompet = DompetModel.fromFirebase('kosong-fb', dataKosong);

        expect(dompet.id, 'kosong-fb');
        expect(dompet.namaDompet, ''); // Default ke string kosong
        expect(dompet.saldo, 0.0); // Default ke 0.0
        expect(dompet.isDeleted, isFalse); // Default ke false
        expect(dompet.diperbarui, isNull);
        expect(dompet.diarsipkan, isNull);
      });
    });
  });
}

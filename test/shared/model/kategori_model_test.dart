// path: test/shared/model/kategori_model_test.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';

void main() {
  group('KategoriModel', () {
    final subKategori1 =
        SubKategoriModel(id: 'sub-1', nama: 'Gaji', idKategori: 'kat-1');
    final subKategori2 =
        SubKategoriModel(id: 'sub-2', nama: 'Bonus', idKategori: 'kat-1');

    // 1. Uji Konstruktor
    test(
      'Konstruktor harus membuat ID dan list subKategori kosong secara default',
      () {
        final kategori = KategoriModel(
          nama: 'Pemasukan',
          tipe: TipeKategori.pemasukan,
        );
        expect(kategori.id, isNotNull);
        expect(kategori.nama, 'Pemasukan');
        expect(kategori.tipe, TipeKategori.pemasukan);
        expect(kategori.subKategori, isEmpty);
        expect(kategori.isDeleted, isFalse);
      },
    );

    test('Konstruktor harus menggunakan nilai yang disediakan', () {
      final now = DateTime.now();
      final kategori = KategoriModel(
        id: 'custom-id',
        nama: 'Transportasi',
        tipe: TipeKategori.pengeluaran,
        subKategori: [subKategori1],
        diperbarui: now,
        isDeleted: true,
      );
      expect(kategori.id, 'custom-id');
      expect(kategori.nama, 'Transportasi');
      expect(kategori.tipe, TipeKategori.pengeluaran);
      expect(kategori.subKategori, [subKategori1]);
      expect(kategori.isDeleted, isTrue);
      expect(kategori.diperbarui, now);
    });

    // 2. Uji copyWith
    test('copyWith harus memperbarui field yang ditentukan', () {
      final kategoriAsli = KategoriModel(
        nama: 'Makanan',
        tipe: TipeKategori.pengeluaran,
      );
      final kategoriBaru = kategoriAsli.copyWith(
        nama: 'Minuman',
        tipe: TipeKategori.pemasukan,
        subKategori: [subKategori2],
      );

      expect(kategoriBaru.id, kategoriAsli.id);
      expect(kategoriBaru.nama, 'Minuman');
      expect(kategoriBaru.tipe, TipeKategori.pemasukan);
      expect(kategoriBaru.subKategori, [subKategori2]);
    });

    // 3. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final now = DateTime.now();
      final subKategoriJson = jsonEncode([
        subKategori1.toSqlite(),
        subKategori2.toSqlite(),
      ]);
      final sqliteMap = {
        'id': 'sqlite-1',
        'nama': 'Pendapatan',
        'tipe': 'pemasukan',
        'id_sub_kategori': subKategoriJson,
        'diperbarui': now.millisecondsSinceEpoch,
        'isDeleted': 1,
        'diarsipkan': now.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final kategori = KategoriModel.fromSqlite(sqliteMap);

        expect(kategori.id, 'sqlite-1');
        expect(kategori.nama, 'Pendapatan');
        expect(kategori.tipe, TipeKategori.pemasukan);
        expect(kategori.subKategori.length, 2);
        expect(kategori.subKategori[0].id, 'sub-1');
        expect(kategori.subKategori[1].nama, 'Bonus');
        expect(kategori.isDeleted, isTrue);
        expect(
          kategori.diperbarui?.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        );
        expect(
          kategori.diarsipkan?.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        );
      });

      test('toSqlite harus membuat map dengan benar', () {
        final kategori = KategoriModel(
          id: 'sqlite-1',
          nama: 'Pendapatan',
          tipe: TipeKategori.pemasukan,
          subKategori: [subKategori1, subKategori2],
          diperbarui: now,
          isDeleted: true,
          diarsipkan: now,
        );

        final hasilMap = kategori.toSqlite();
        expect(hasilMap['id'], 'sqlite-1');
        expect(hasilMap['nama'], 'Pendapatan');
        expect(hasilMap['tipe'], 'pemasukan');
        expect(hasilMap['id_sub_kategori'], isA<String>());
        expect(hasilMap['diperbarui'], now.millisecondsSinceEpoch);
        expect(hasilMap['isDeleted'], 1);
        expect(hasilMap['diarsipkan'], now.millisecondsSinceEpoch);
      });

      test('fromSqlite harus menangani nilai null dan default', () {
        final mapKosong = {
          'id': 'kosong-id',
          'nama': null,
          'tipe': 'TipeSalah', // Enum tidak valid
          'id_sub_kategori': null,
          'isDeleted': null,
        };
        final kategori = KategoriModel.fromSqlite(mapKosong);

        expect(kategori.id, 'kosong-id');
        expect(kategori.nama, '');
        // Harus default ke pengeluaran jika enum tidak valid
        expect(kategori.tipe, TipeKategori.pengeluaran);
        expect(kategori.subKategori, isEmpty);
        expect(kategori.isDeleted, isFalse);
        expect(kategori.diperbarui, isNull);
        expect(kategori.diarsipkan, isNull);
      });

      test('fromSqlite harus menangani json subkategori yang salah format', () {
        final mapJsonSalah = {
          'id': 'json-salah',
          'nama': 'Test',
          'tipe': 'pengeluaran',
          'id_sub_kategori': '[{id:1,}', // JSON tidak valid
        };
        final kategori = KategoriModel.fromSqlite(mapJsonSalah);
        expect(kategori.subKategori, isEmpty);
      });
    });

    // 4. Uji Konversi Firebase
    group('Konversi Firebase', () {
      final now = DateTime.now();
      final List<Map<String, dynamic>> subKategoriMapList = [
        subKategori1.toFirebase(),
        subKategori2.toFirebase(),
      ];
      final firebaseData = {
        'nama': 'Belanja',
        'tipe': 'pengeluaran',
        'id_sub_kategori': subKategoriMapList,
        'diperbarui': Timestamp.fromDate(now),
        'isDeleted': false,
        'diarsipkan': Timestamp.fromDate(now),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final kategori = KategoriModel.fromFirebase('firebase-1', firebaseData);
        expect(kategori.id, 'firebase-1');
        expect(kategori.nama, 'Belanja');
        expect(kategori.tipe, TipeKategori.pengeluaran);
        expect(kategori.subKategori.length, 2);
        expect(kategori.subKategori[0].nama, 'Gaji');
        expect(kategori.isDeleted, isFalse);
        expect(
          kategori.diperbarui?.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        );
        expect(
          kategori.diarsipkan?.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        );
      });

      test('toFirebase harus membuat map dengan benar', () {
        final kategori = KategoriModel(
          id: 'firebase-1',
          nama: 'Belanja',
          tipe: TipeKategori.pengeluaran,
          subKategori: [subKategori1, subKategori2],
          diperbarui: now,
          diarsipkan: now,
        );

        final hasilMap = kategori.toFirebase();
        expect(hasilMap['nama'], 'Belanja');
        expect(hasilMap['tipe'], 'pengeluaran');
        expect(hasilMap['id_sub_kategori'], isA<List<Map<String, dynamic>>>());
        final listSub =
            hasilMap['id_sub_kategori'] as List<Map<String, dynamic>>;
        expect(listSub.length, 2);
        expect(listSub[0]['nama'], 'Gaji');
        expect(hasilMap['diperbarui'], isA<FieldValue>());
        expect(hasilMap['isDeleted'], false);
        expect(hasilMap['diarsipkan'], isA<Timestamp>());
      });

      test('toFirebase harus menangani diarsipkan null', () {
        final kategori = KategoriModel(
          nama: 'Test',
          tipe: TipeKategori.pengeluaran,
        );
        final hasilMap = kategori.toFirebase();
        expect(hasilMap['diarsipkan'], isNull);
      });
    });
  });
}

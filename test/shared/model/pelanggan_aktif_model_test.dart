// path: test/shared/model/pelanggan_aktif_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';

void main() {
  group('PelangganAktifModel', () {
    final tanggalMulai = DateTime(2024);
    final tanggalBerakhir = DateTime(2024, 2);

    // 1. Uji Konstruktor
    test('Konstruktor harus membuat ID jika null dan menyimpan nilai', () {
      final model = PelangganAktifModel(
        idPelanggan: 'p-001',
        idPaket: 'pkt-001',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.lunas,
      );

      expect(model.id, isNotNull);
      expect(model.idPelanggan, 'p-001');
      expect(model.idPaket, 'pkt-001');
      expect(model.status, StatusPembayaranEnum.lunas);
      expect(model.isDeleted, isFalse);
      expect(model.idTransaksi, isNull);
    });

    // 2. Uji copyWith
    test('copyWith harus menyalin dan memperbarui field dengan benar', () {
      final modelAsli = PelangganAktifModel(
        id: 'aktif-1',
        idPelanggan: 'p-001',
        idPaket: 'pkt-001',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.lunas,
      );

      final modelBaru = modelAsli.copyWith(
        status: StatusPembayaranEnum.belumLunas,
        isDeleted: true,
        idTransaksi: 'trans-123',
      );

      expect(modelBaru.id, modelAsli.id);
      expect(modelBaru.idPelanggan, modelAsli.idPelanggan);
      expect(modelBaru.status, StatusPembayaranEnum.belumLunas);
      expect(modelBaru.isDeleted, isTrue);
      expect(modelBaru.idTransaksi, 'trans-123');
    });

    // 3. Uji toJson
    test('toJson harus menghasilkan map yang benar', () {
      final model = PelangganAktifModel(
        id: 'aktif-json',
        idPelanggan: 'p-002',
        idPaket: 'pkt-002',
        idTransaksi: 'trans-456',
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.belumLunas, // Diganti dari cicilan
      );

      final json = model.toJson();
      expect(json['id'], 'aktif-json');
      expect(json['idPelanggan'], 'p-002');
      expect(json['idTransaksi'], 'trans-456');
      expect(json['tanggalMulai'], tanggalMulai.toIso8601String());
      expect(json['status'], 'belumLunas'); // Diganti dari cicilan
    });

    // 4. Uji Konversi SQLite
    group('Konversi SQLite', () {
      final sqliteMap = {
        'id': 'sqlite-1',
        'id_pelanggan': 'p-sqlite',
        'id_paket': 'pkt-sqlite',
        'id_transaksi': 'trans-sqlite',
        'tanggal_mulai': tanggalMulai.millisecondsSinceEpoch,
        'tanggal_berakhir': tanggalBerakhir.millisecondsSinceEpoch,
        'status': 'lunas',
        'isDeleted': 1,
        'diperbarui': tanggalMulai.millisecondsSinceEpoch,
        'diarsipkan': tanggalBerakhir.millisecondsSinceEpoch,
      };

      test('fromSqlite harus membuat model dengan benar', () {
        final model = PelangganAktifModel.fromSqlite(sqliteMap);
        expect(model.id, 'sqlite-1');
        expect(model.idPelanggan, 'p-sqlite');
        expect(model.tanggalMulai, tanggalMulai);
        expect(model.isDeleted, isTrue);
        expect(model.diperbarui, tanggalMulai);
      });

      test('toSqlite harus menghasilkan map dengan benar', () {
        final model = PelangganAktifModel.fromSqlite(sqliteMap);
        final hasilMap = model.toSqlite();
        expect(hasilMap, sqliteMap);
      });

      test('fromSqlite harus melempar error jika tanggal null', () {
        final mapRusak = Map<String, dynamic>.from(sqliteMap);
        mapRusak['tanggal_mulai'] = null;
        expect(
          () => PelangganAktifModel.fromSqlite(mapRusak),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // 5. Uji Konversi Firebase
    group('Konversi Firebase', () {
      // Perhatikan perbedaan penamaan: id_pelanggan di Firebase, idPelanggan di model
      final firebaseData = {
        'id_pelanggan': 'p-firebase',
        'id_paket': 'pkt-firebase',
        'id_transaksi': 'trans-firebase',
        'tanggalMulai': Timestamp.fromDate(tanggalMulai),
        'tanggalBerakhir': Timestamp.fromDate(tanggalBerakhir),
        'status': 'belumLunas',
        'isDeleted': false,
        'diperbarui': Timestamp.fromDate(tanggalMulai),
        'diarsipkan': Timestamp.fromDate(tanggalBerakhir),
      };

      test('fromFirebase harus membuat model dengan benar', () {
        final model = PelangganAktifModel.fromFirebase('fb-1', firebaseData);
        expect(model.id, 'fb-1');
        expect(model.idPelanggan,
            'p-firebase',); // verifikasi penanganan nama field
        expect(model.tanggalBerakhir, tanggalBerakhir);
        expect(model.status, StatusPembayaranEnum.belumLunas);
        expect(model.isDeleted, isFalse);
      });

      test('toFirebase harus menghasilkan map dengan benar', () {
        final model = PelangganAktifModel(
          id: 'fb-2',
          idPelanggan: 'p-fb-2',
          idPaket: 'pkt-fb-2',
          tanggalMulai: tanggalMulai,
          tanggalBerakhir: tanggalBerakhir,
          status: StatusPembayaranEnum.lunas,
          diarsipkan: tanggalBerakhir,
        );

        final hasilMap = model.toFirebase();
        expect(hasilMap['id_pelanggan'],
            'p-fb-2',); // verifikasi penanganan nama field
        expect(hasilMap['tanggalMulai'], Timestamp.fromDate(tanggalMulai));
        expect(hasilMap['diperbarui'], isA<FieldValue>());
        expect(hasilMap['diarsipkan'], Timestamp.fromDate(tanggalBerakhir));
      });

      test('fromFirebase harus melempar error jika tanggal null', () {
        final dataRusak = Map<String, dynamic>.from(firebaseData);
        dataRusak['tanggalBerakhir'] = null;
        expect(
          () => PelangganAktifModel.fromFirebase('id-rusak', dataRusak),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('toFirebase harus menangani diarsipkan null', () {
        final model = PelangganAktifModel(
          idPelanggan: 'p',
          idPaket: 'pk',
          tanggalMulai: DateTime.now(),
          tanggalBerakhir: DateTime.now(),
          status: StatusPembayaranEnum.lunas,
        );
        final hasilMap = model.toFirebase();
        expect(hasilMap.containsKey('diarsipkan'), isFalse);
      });
    });
  });
}

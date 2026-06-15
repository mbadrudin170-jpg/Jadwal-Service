// path: test/shared/model/dompet_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';

void main() {
  group('DompetModel', () {
    final tanggalSekarang = DateTime.now();
    final dataDompetLengkap = DompetModel(
      id: 'dompet-123',
      nama: 'Dompet Utama',
      saldo: 150000.0,
      diperbaruiPada: tanggalSekarang,
      diarsipkanPada: tanggalSekarang,
    );

    test(
        '01. harus membuat instance DompetModel dengan id yang dibuat secara otomatis',
        () {
      final dompet = DompetModel(nama: 'Dompet Baru', saldo: 50000.0);
      expect(dompet.id, isNotNull);
      expect(dompet.nama, 'Dompet Baru');
      expect(dompet.saldo, 50000.0);
    });

    test('02. harus membuat instance DompetModel dengan id yang disediakan',
        () {
      final dompet =
          DompetModel(id: 'custom-id', nama: 'Dompet Custom');
      expect(dompet.id, 'custom-id');
      expect(dompet.nama, 'Dompet Custom');
    });

    test(
        '03. harus membuat instance DompetModel dengan nilai default untuk isDeleted dan archivedAt',
        () {
      final dompet = DompetModel(nama: 'Dompet Default');
      expect(dompet.diHapus, false);
      expect(dompet.diarsipkanPada, isNull);
    });

    test(
        '04. harus menyalin objek dengan semua field tidak berubah jika tidak ada parameter yang diberikan',
        () {
      final salinanDompet = dataDompetLengkap.copyWith();
      expect(salinanDompet.id, dataDompetLengkap.id);
      expect(salinanDompet.nama, dataDompetLengkap.nama);
      expect(salinanDompet.saldo, dataDompetLengkap.saldo);
      expect(salinanDompet.diperbaruiPada, dataDompetLengkap.diperbaruiPada);
      expect(salinanDompet.diHapus, dataDompetLengkap.diHapus);
      expect(salinanDompet.diarsipkanPada, dataDompetLengkap.diarsipkanPada);
    });

    test('05. harus menyalin objek dengan field yang diperbarui', () {
      final tanggalBaru = DateTime(2025);
      final salinanDompet = dataDompetLengkap.copyWith(
        name: 'Dompet Terupdate',
        balance: 200000.0,
        isDeleted: true,
        archivedAt: tanggalBaru,
      );
      expect(salinanDompet.nama, 'Dompet Terupdate');
      expect(salinanDompet.saldo, 200000.0);
      expect(salinanDompet.diHapus, true);
      expect(salinanDompet.diarsipkanPada, tanggalBaru);
    });

    test('06. harus menyalin objek dengan id yang diperbarui', () {
      final salinanDompet = dataDompetLengkap.copyWith(id: 'dompet-baru-456');
      expect(salinanDompet.id, 'dompet-baru-456');
    });

    test('07. harus menyalin objek dengan name yang diperbarui', () {
      final salinanDompet = dataDompetLengkap.copyWith(name: 'Dompet Liburan');
      expect(salinanDompet.nama, 'Dompet Liburan');
    });

    test('08. harus menyalin objek dengan balance yang diperbarui', () {
      final salinanDompet = dataDompetLengkap.copyWith(balance: 50.0);
      expect(salinanDompet.saldo, 50.0);
    });

    test('09. harus menyalin objek dengan updatedAt yang diperbarui', () {
      final tanggalUpdate = DateTime(2024, 1);
      final salinanDompet =
          dataDompetLengkap.copyWith(updatedAt: tanggalUpdate);
      expect(salinanDompet.diperbaruiPada, tanggalUpdate);
    });

    test('10. harus menyalin objek dengan isDeleted yang diperbarui', () {
      final salinanDompet = dataDompetLengkap.copyWith(isDeleted: true);
      expect(salinanDompet.diHapus, true);
    });

    test('11. harus menyalin objek dengan archivedAt yang diperbarui', () {
      final tanggalArsip = DateTime(2025, 1);
      final salinanDompet =
          dataDompetLengkap.copyWith(archivedAt: tanggalArsip);
      expect(salinanDompet.diarsipkanPada, tanggalArsip);
    });

    group('fromSqlite', () {
      test('12. harus membuat DompetModel dari peta SQLite dengan semua field',
          () {
        final mapSqlite = {
          NamaKolom.id: 'sqlite-1',
          NamaKolom.nama: 'Dompet SQLite',
          NamaKolom.saldo: 75000.0,
          NamaKolom.diperbaruiPada: tanggalSekarang.millisecondsSinceEpoch,
          NamaKolom.diHapus: 1,
          NamaKolom.diarsipkanPada: tanggalSekarang.millisecondsSinceEpoch,
        };

        final dompet = DompetModel.fromSqlite(mapSqlite);

        expect(dompet.id, 'sqlite-1');
        expect(dompet.nama, 'Dompet SQLite');
        expect(dompet.saldo, 75000.0);
        expect(
            dompet.diperbaruiPada,
            DateTime.fromMillisecondsSinceEpoch(
                tanggalSekarang.millisecondsSinceEpoch));
        expect(dompet.diHapus, true);
        expect(
            dompet.diarsipkanPada,
            DateTime.fromMillisecondsSinceEpoch(
                tanggalSekarang.millisecondsSinceEpoch));
      });

      test(
          '13. harus membuat DompetModel dari peta SQLite dengan field yang hilang dan menggunakan nilai default',
          () {
        final mapSqlite = {
          NamaKolom.id: 'sqlite-2',
          NamaKolom.nama: 'Dompet Minimal',
        };

        final dompet = DompetModel.fromSqlite(mapSqlite);

        expect(dompet.id, 'sqlite-2');
        expect(dompet.nama, 'Dompet Minimal');
        expect(dompet.saldo, 0.0);
        expect(dompet.diperbaruiPada, isNull);
        expect(dompet.diHapus, false);
        expect(dompet.diarsipkanPada, isNull);
      });

      test('14. harus menangani nilai updatedAt dan archivedAt sebagai integer',
          () {
        final int timestamp = tanggalSekarang.millisecondsSinceEpoch;
        final mapSqlite = {
          NamaKolom.id: 'sqlite-3',
          NamaKolom.nama: 'Dompet Timestamp',
          NamaKolom.diperbaruiPada: timestamp,
          NamaKolom.diarsipkanPada: timestamp,
        };
        final dompet = DompetModel.fromSqlite(mapSqlite);
        expect(dompet.diperbaruiPada,
            DateTime.fromMillisecondsSinceEpoch(timestamp));
        expect(dompet.diarsipkanPada,
            DateTime.fromMillisecondsSinceEpoch(timestamp));
      });
    });

    group('toSqlite', () {
      test(
          '15. harus mengubah DompetModel menjadi peta SQLite dengan semua field',
          () {
        final peta = dataDompetLengkap.toSqlite();

        expect(peta[NamaKolom.id], 'dompet-123');
        expect(peta[NamaKolom.nama], 'Dompet Utama');
        expect(peta[NamaKolom.saldo], 150000.0);
        expect(peta[NamaKolom.diperbaruiPada],
            tanggalSekarang.millisecondsSinceEpoch);
        expect(peta[NamaKolom.diHapus], 0);
        expect(peta[NamaKolom.diarsipkanPada],
            tanggalSekarang.millisecondsSinceEpoch);
      });

      test(
          '16. harus mengubah DompetModel menjadi peta SQLite dan updatedAt menggunakan DateTime.now() jika null',
          () {
        final dompetTanpaUpdate = DompetModel(nama: 'Baru', saldo: 10);
        final peta = dompetTanpaUpdate.toSqlite();

        expect(peta[NamaKolom.diperbaruiPada], isNotNull);
      });

      test('17. harus mengubah isDeleted menjadi 1 jika true dan 0 jika false',
          () {
        final dompetDihapus =
            DompetModel(nama: 'Hapus', diHapus: true);
        final dompetTidakDihapus =
            DompetModel(nama: 'Tidak Hapus');

        expect(dompetDihapus.toSqlite()[NamaKolom.diHapus], 1);
        expect(dompetTidakDihapus.toSqlite()[NamaKolom.diHapus], 0);
      });
    });

    group('fromFirebase', () {
      final timestampFirebase = Timestamp.fromDate(tanggalSekarang);

      test(
          '18. harus membuat DompetModel dari data Firebase dengan semua field',
          () {
        final dataFirebase = {
          NamaKolom.nama: 'Dompet Firebase',
          NamaKolom.saldo: 250000.0,
          NamaKolom.diperbaruiPada: timestampFirebase,
          NamaKolom.diHapus: true,
          NamaKolom.diarsipkanPada: timestampFirebase,
        };
        final dompet = DompetModel.fromFirebase('fb-1', dataFirebase);

        expect(dompet.id, 'fb-1');
        expect(dompet.nama, 'Dompet Firebase');
        expect(dompet.saldo, 250000.0);
        expect(dompet.diperbaruiPada, tanggalSekarang);
        expect(dompet.diHapus, true);
        expect(dompet.diarsipkanPada, tanggalSekarang);
      });

      test(
          '19. harus membuat DompetModel dari data Firebase dengan field yang hilang dan menggunakan nilai default',
          () {
        final dataFirebase = {
          NamaKolom.nama: 'Dompet Firebase Minimal',
        };
        final dompet = DompetModel.fromFirebase('fb-2', dataFirebase);

        expect(dompet.id, 'fb-2');
        expect(dompet.nama, 'Dompet Firebase Minimal');
        expect(dompet.saldo, 0.0);
        expect(dompet.diperbaruiPada, isNull);
        expect(dompet.diHapus, false);
        expect(dompet.diarsipkanPada, isNull);
      });

      test(
          '20. harus menangani nilai updatedAt dan archivedAt sebagai Timestamp',
          () {
        final dataFirebase = {
          NamaKolom.nama: 'Dompet Firebase Timestamp',
          NamaKolom.diperbaruiPada: timestampFirebase,
          NamaKolom.diarsipkanPada: timestampFirebase,
        };
        final dompet = DompetModel.fromFirebase('fb-3', dataFirebase);
        expect(dompet.diperbaruiPada, tanggalSekarang);
        expect(dompet.diarsipkanPada, tanggalSekarang);
      });
    });

    group('toFirebase', () {
      test(
          '21. harus mengubah DompetModel menjadi peta Firebase dengan semua field',
          () {
        final peta = dataDompetLengkap.toFirebase();
        final timestampUTC = Timestamp.fromDate(tanggalSekarang.toUtc());

        expect(peta[NamaKolom.id], 'dompet-123');
        expect(peta[NamaKolom.nama], 'Dompet Utama');
        expect(peta[NamaKolom.saldo], 150000.0);
        expect(peta[NamaKolom.diHapus], false);
        expect(peta[NamaKolom.diperbaruiPada], timestampUTC);
        expect(peta[NamaKolom.diarsipkanPada], timestampUTC);
      });

      test(
          '22. harus mengubah DompetModel menjadi peta Firebase dan updatedAt menggunakan DateTime.now() jika null dan dikonversi ke UTC',
          () {
        final dompetTanpaUpdate = DompetModel(nama: 'Baru', saldo: 10);
        final peta = dompetTanpaUpdate.toFirebase();

        expect(peta[NamaKolom.diperbaruiPada], isA<Timestamp>());
      });

      test(
          '23. harus mengubah archivedAt menjadi Timestamp UTC jika tidak null',
          () {
        final dompetDenganArsip = DompetModel(
            nama: 'Arsip', diarsipkanPada: tanggalSekarang);
        final peta = dompetDenganArsip.toFirebase();

        expect(peta[NamaKolom.diarsipkanPada], isA<Timestamp>());
        expect(peta[NamaKolom.diarsipkanPada],
            Timestamp.fromDate(tanggalSekarang.toUtc()));
      });
    });
  });
}

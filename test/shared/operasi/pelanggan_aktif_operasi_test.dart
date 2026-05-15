// path: test/shared/operasi/pelanggan_aktif_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

import 'pelanggan_aktif_operasi_test.mocks.dart';

@GenerateMocks([NotifikasiServis])
void main() {
  // Initialize FFI for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('PelangganAktifOperasi', () {
    late MockNotifikasiServis mockNotifikasiServis;
    late PelangganAktifOperasi operasi;
    late Database db;

    setUp(() async {
      mockNotifikasiServis = MockNotifikasiServis();

      // Ensure a clean database for each test
      final dbHelper = DatabaseHelper.instance;
      dbHelper.debugSetDatabaseNull();
      db = await dbHelper.database;

      operasi = PelangganAktifOperasi(notifikasiServis: mockNotifikasiServis);

      // Insert a dummy pelanggan so _jadwalkanNotifikasi can find it.
      final testPelanggan = PelangganModel(
        id: 'pelanggan1',
        nama: 'Pelanggan Test',
        telepon: '123456789',
        alamat: 'Alamat Test',
        password: 'password',
        macAddress: '00:00:00:00:00:00',
      );
      await db.insert('pelanggan', testPelanggan.toSqlite());
    });

    tearDown(() async {
      await db.close();
    });

    final tPelangganAktifModel = PelangganAktifModel(
      id: '1',
      idPelanggan: 'pelanggan1',
      idPaket: 'paket1',
      tanggalMulai: DateTime(2023),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 30)),
      status: StatusPembayaranEnum.lunas,
    );

    test(
        'createPelangganAktif harus menambahkan data dan menjadwalkan notifikasi',
        () async {
      // arrange
      when(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .thenAnswer((final _) async => {});

      // act
      final result = await operasi.createPelangganAktif(tPelangganAktifModel);

      // assert
      final dataDiDb = await operasi.ambilSatuPelangganAktif(result.id);
      expect(dataDiDb, isNotNull);
      expect(dataDiDb!.id, result.id);
      expect(dataDiDb.idPelanggan, tPelangganAktifModel.idPelanggan);

      // Verify that notification scheduling was called
      verify(mockNotifikasiServis.jadwalNotifikasi(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
      )).called(greaterThan(0));
    });

    test(
        'ambilSemuaPelangganAktif harus mengembalikan semua data yang tidak diarsipkan',
        () async {
      // arrange
      await operasi.createPelangganAktif(tPelangganAktifModel);
      await operasi
          .createPelangganAktif(tPelangganAktifModel.copyWith(id: '2'));
      final arsipModel = tPelangganAktifModel.copyWith(id: '3');
      await operasi.createPelangganAktif(arsipModel);
      await operasi.arsipkanPelangganAktif(arsipModel.id);

      // act
      final result = await operasi.ambilSemuaPelangganAktif();

      // assert
      expect(result.length, 2);
      expect(result.any((final p) => p.isDeleted), isFalse);
    });

    test(
        'ambilSemuaPelangganAktif harus menampilkan log untuk pelanggan yang akan berakhir',
        () async {
      // arrange
      final expiringModel = PelangganAktifModel(
        id: 'expiring_id',
        idPelanggan: 'pelanggan1',
        idPaket: 'paket1',
        tanggalMulai: DateTime.now().subtract(const Duration(days: 28)),
        tanggalBerakhir: DateTime.now()
            .add(const Duration(days: 2)), // Akan berakhir dalam 2 hari
        status: StatusPembayaranEnum.lunas,
      );
      await operasi.createPelangganAktif(expiringModel);

      // act
      final result = await operasi.ambilSemuaPelangganAktif();

      // assert
      // Saat pengujian ini dijalankan, Anda akan melihat log di konsol.
      // Kita juga bisa memastikan data yang relevan tetap ada di hasil.
      expect(result.any((final p) => p.id == 'expiring_id'), isTrue);
    });

    test('ambilSatuPelangganAktif harus mengembalikan data yang benar',
        () async {
      // arrange
      await operasi.createPelangganAktif(tPelangganAktifModel);

      // act
      final result =
          await operasi.ambilSatuPelangganAktif(tPelangganAktifModel.id);

      // assert
      expect(result, isNotNull);
      expect(result!.id, tPelangganAktifModel.id);
    });

    test('updatePelangganAktif harus memperbarui data di database', () async {
      // arrange
      await operasi.createPelangganAktif(tPelangganAktifModel);
      final updatedModel = tPelangganAktifModel.copyWith(idPaket: 'paketBaru');

      // act
      await operasi.updatePelangganAktif(updatedModel);

      // assert
      final result =
          await operasi.ambilSatuPelangganAktif(tPelangganAktifModel.id);
      expect(result!.idPaket, 'paketBaru');
    });

    test('arsipkanPelangganAktif harus menandai data sebagai dihapus',
        () async {
      // arrange
      await operasi.createPelangganAktif(tPelangganAktifModel);

      // act
      await operasi.arsipkanPelangganAktif(tPelangganAktifModel.id);

      // assert
      final result = await db.query(
        'pelanggan_aktif',
        where: 'id = ?',
        whereArgs: [tPelangganAktifModel.id],
      );
      expect(result.first['isDeleted'], 1);
      verify(mockNotifikasiServis.batalNotifikasi(any)).called(greaterThan(0));
    });

    test('hapusPermanenPelangganYangDiArsipkan harus menghapus data lama',
        () async {
      // arrange
      final oldModel = tPelangganAktifModel.copyWith(
          id: 'old_id',
          diarsipkan: DateTime.now().subtract(const Duration(days: 40)),
          isDeleted: true);
      await db.insert('pelanggan_aktif', oldModel.toSqlite());

      // act
      await operasi.hapusPermanenPelangganYangDiArsipkan();

      // assert
      final result = await db.query(
        'pelanggan_aktif',
        where: 'id = ?',
        whereArgs: [oldModel.id],
      );
      expect(result, isEmpty);
    });
  });
}

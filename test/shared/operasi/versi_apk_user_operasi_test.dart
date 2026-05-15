// path: test/shared/operasi/versi_apk_user_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/enum/arsitektur_apk_enum.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/versi_apk_user_operasi.dart';

import 'versi_apk_user_operasi_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database, OperasiDasar])
void main() {
  late MockOperasiDasar mockOperasiDasar;
  late VersiApkUserOperasi versiApkUserOperasi;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockOperasiDasar = MockOperasiDasar();
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();

    versiApkUserOperasi = VersiApkUserOperasi(
      operasi: mockOperasiDasar,
      dbHelper: mockDatabaseHelper,
    );

    when(mockDatabaseHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  final versiApk = VersiApkUserModel(
    id: '1',
    versiTerbaru: '1.0.0',
    nomorBuildTerbaru: const {ArsitekturApkEnum.universal: 1},
    catatanRilis: 'Catatan rilis',
    diperbarui: DateTime(2023),
  );

  group('Operasi Tulis', () {
    test('tambahVersiApkUser harus memanggil sisipkan pada OperasiDasar', () async {
      when(mockOperasiDasar.sisipkan(any, any)).thenAnswer((final _) async => 1);

      await versiApkUserOperasi.tambahVersiApkUser(versiApk);

      verify(mockOperasiDasar.sisipkan(
        'versi_apk_user',
        versiApk.toSqlite(),
      )).called(1);
    });

    test('perbaruiVersiApkUser harus memanggil perbarui pada OperasiDasar', () async {
      when(mockOperasiDasar.perbarui(any, any, any)).thenAnswer((final _) async => 1);

      await versiApkUserOperasi.perbaruiVersiApkUser(versiApk);

      verify(mockOperasiDasar.perbarui(
        'versi_apk_user',
        versiApk.toSqlite(),
        versiApk.id,
      )).called(1);
    });

    test('arsipkanVersiApkUser harus memperbarui model dengan isDeleted=true', () async {
      final dataFromDb = versiApk.toSqlite();

      when(mockDatabase.query('versi_apk_user', where: 'id = ?', whereArgs: ['1'])).thenAnswer((final _) async => [dataFromDb]);
      when(mockOperasiDasar.perbarui('versi_apk_user', any, versiApk.id)).thenAnswer((final _) async => 1);

      await versiApkUserOperasi.arsipkanVersiApkUser(versiApk.id);

      final verification = verify(mockOperasiDasar.perbarui(
        'versi_apk_user',
        captureAny,
        versiApk.id,
      ));
      
      verification.called(1);
      
      final captured = verification.captured.first as Map<String, dynamic>;
      expect(captured['isDeleted'], 1);
      expect(captured['diarsipkan'], isNotNull);
    });

    test('sisipkanAtauPerbaruiBatch harus memanggil sisipkanAtauPerbaruiBatch pada OperasiDasar', () async {
      final listVersi = [versiApk];
      when(mockOperasiDasar.sisipkanAtauPerbaruiBatch(any, any)).thenAnswer((final _) async => {});

      await versiApkUserOperasi.sisipkanAtauPerbaruiBatch(listVersi);

      verify(mockOperasiDasar.sisipkanAtauPerbaruiBatch(
        'versi_apk_user',
        listVersi.map((final e) => e.toSqlite()).toList(),
      )).called(1);
    });
  });

  group('Operasi Baca', () {
    test('ambilSemuaVersiApk mengembalikan daftar model', () async {
      final maps = [versiApk.toSqlite()];
      when(mockDatabase.query('versi_apk_user', orderBy: 'diperbarui DESC')).thenAnswer((final _) async => maps);

      final result = await versiApkUserOperasi.ambilSemuaVersiApk();

      expect(result, isA<List<VersiApkUserModel>>());
      expect(result.first.id, versiApk.id);
    });

    test('ambilSemuaVersiApkAktif mengembalikan daftar model aktif', () async {
      final maps = [versiApk.toSqlite()];
      when(mockDatabase.query('versi_apk_user', where: 'isDeleted = 0', orderBy: 'diperbarui DESC')).thenAnswer((final _) async => maps);

      final result = await versiApkUserOperasi.ambilSemuaVersiApkAktif();

      expect(result.every((final e) => !e.isDeleted), isTrue);
      verify(mockDatabase.query(
        'versi_apk_user',
        where: 'isDeleted = 0',
        orderBy: 'diperbarui DESC',
      )).called(1);
    });

    test('ambilVersiApkTerbaru mengembalikan model terbaru', () async {
      final maps = [versiApk.toSqlite()];
      when(mockDatabase.query('versi_apk_user', where: 'isDeleted = 0', orderBy: 'diperbarui DESC', limit: 1)).thenAnswer((final _) async => maps);

      final result = await versiApkUserOperasi.ambilVersiApkTerbaru();

      expect(result, isA<VersiApkUserModel>());
      expect(result!.id, versiApk.id);
    });

    test('ambilVersiApkById mengembalikan model yang benar', () async {
      final maps = [versiApk.toSqlite()];
      when(mockDatabase.query('versi_apk_user', where: 'id = ? AND isDeleted = 0', whereArgs: ['1'])).thenAnswer((final _) async => maps);

      final result = await versiApkUserOperasi.ambilVersiApkById('1');

      expect(result, isA<VersiApkUserModel>());
      expect(result!.id, '1');
      verify(mockDatabase.query(
        'versi_apk_user',
        where: 'id = ? AND isDeleted = 0',
        whereArgs: ['1'],
      )).called(1);
    });

    test('ambilVersiApkById mengembalikan null jika tidak ditemukan', () async {
      when(mockDatabase.query('versi_apk_user', where: 'id = ? AND isDeleted = 0', whereArgs: ['99'])).thenAnswer((final _) async => []);

      final result = await versiApkUserOperasi.ambilVersiApkById('99');

      expect(result, isNull);
    });
  });
}

// TODO: Rencana selanjutnya adalah memastikan semua edge case diuji,
// seperti error handling (melempar exception) saat database gagal.
// Dan menambahkan pengujian untuk setiap parameter opsional di fungsi.

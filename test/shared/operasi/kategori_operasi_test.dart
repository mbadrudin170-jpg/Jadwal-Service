// path: test/shared/operasi/kategori_operasi_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/category_operation.dart';

import 'kategori_operasi_test.mocks.dart';

@GenerateMocks([DatabaseHelper, OperasiDasar, Database])
void main() {
  group('KategoriOperasi', () {
    late MockDatabaseHelper mockDbHelper;
    late MockOperasiDasar mockOperasiDasar;
    late MockDatabase mockDatabase;
    late KategoriOperasi kategoriOperasi;

    final kategoriContoh = KategoriModel(
      id: '1',
      nama: 'Kategori 1',
      tipe: TipeKategori.pemasukan,
    );

    setUp(() {
      mockDbHelper = MockDatabaseHelper();
      mockOperasiDasar = MockOperasiDasar();
      mockDatabase = MockDatabase();
      kategoriOperasi = KategoriOperasi(
        dbHelper: mockDbHelper,
        operasiDasar: mockOperasiDasar,
      );

      when(mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
    });

    tearDown(resetMockitoState);

    test('createKategori mendelegasikan ke OperasiDasar.sisipkan', () async {
      when(mockOperasiDasar.sisipkan(
        'kategori',
        any,
      )).thenAnswer((final _) => Future.value());

      await kategoriOperasi.createKategori(kategoriContoh);

      final verification = verify(mockOperasiDasar.sisipkan(
        'kategori',
        captureAny,
      ));
      verification.called(1);

      final capturedData = verification.captured.first as Map<String, dynamic>;
      expect(capturedData['id'], kategoriContoh.id);
      expect(capturedData['nama'], kategoriContoh.nama);
      final diperbarui = DateTime.fromMillisecondsSinceEpoch(
        capturedData['diperbarui'] as int,
      );
      expect(
        diperbarui.isAfter(DateTime.now().subtract(const Duration(seconds: 5))),
        isTrue,
      );
    });

    test('getKategori mengambil dari database', () async {
      when(mockDatabase.query('kategori', where: 'diarsipkan IS NULL'))
          .thenAnswer(
        (final _) async => [kategoriContoh.toSqlite()],
      );

      final hasil = await kategoriOperasi.getKategori();

      expect(hasil, isA<List<KategoriModel>>());
      expect(hasil.length, 1);
      expect(hasil.first.nama, 'Kategori 1');
      verify(mockDatabase.query('kategori', where: 'diarsipkan IS NULL'))
          .called(1);
    });

    test('getKategoriById mengambil dari database', () async {
      when(mockDatabase.query(
        'kategori',
        where: 'id = ?',
        whereArgs: ['1'],
      )).thenAnswer((final _) async => [kategoriContoh.toSqlite()]);

      final hasil = await kategoriOperasi.getKategoriById('1');

      expect(hasil, isNotNull);
      expect(hasil.id, '1');
      verify(mockDatabase.query(
        'kategori',
        where: 'id = ?',
        whereArgs: ['1'],
      )).called(1);
    });

    test('getKategoriById melempar exception jika tidak ditemukan', () {
      when(mockDatabase.query(
        'kategori',
        where: 'id = ?',
        whereArgs: ['xxx'],
      )).thenAnswer((final _) async => []);

      expect(
        () async => await kategoriOperasi.getKategoriById('xxx'),
        throwsA(isA<Exception>()),
      );
    });

    test('getKategoriByTipe mengambil dari database berdasarkan tipe',
        () async {
      // 1. Arrange
      final kategoriPemasukan =
          KategoriModel(id: '2', nama: 'Gaji', tipe: TipeKategori.pemasukan);
      when(mockDatabase.query(
        'kategori',
        where: 'tipe = ? AND diarsipkan IS NULL',
        whereArgs: [TipeKategori.pemasukan.name],
      )).thenAnswer((final _) async => [kategoriPemasukan.toSqlite()]);

      // 2. Act
      final hasil =
          await kategoriOperasi.getKategoriByTipe(TipeKategori.pemasukan);

      // 3. Assert
      expect(hasil, isNotEmpty);
      expect(hasil.first.nama, 'Gaji');
      verify(mockDatabase.query(
        'kategori',
        where: 'tipe = ? AND diarsipkan IS NULL',
        whereArgs: [TipeKategori.pemasukan.name],
      )).called(1);
    });

    test('update mendelegasikan ke OperasiDasar.perbarui', () async {
      when(mockOperasiDasar.perbarui(
        'kategori',
        any,
        kategoriContoh.id,
      )).thenAnswer((final _) async {});

      await kategoriOperasi.update(kategoriContoh);

      final verification = verify(mockOperasiDasar.perbarui(
        'kategori',
        captureAny,
        kategoriContoh.id,
      ));

      verification.called(1);
      final capturedData = verification.captured.first as Map<String, dynamic>;
      expect(capturedData['id'], kategoriContoh.id);
      final diperbarui = DateTime.fromMillisecondsSinceEpoch(
        capturedData['diperbarui'] as int,
      );
      expect(
        diperbarui.isAfter(DateTime.now().subtract(const Duration(seconds: 5))),
        isTrue,
      );
    });

    test('delete (hard delete) mendelegasikan ke OperasiDasar.hapus', () async {
      when(mockOperasiDasar.hapus(
        'kategori',
        '1',
        dariServer: true,
      )).thenAnswer((final _) async {});

      await kategoriOperasi.delete('1', dariServer: true);

      verify(mockOperasiDasar.hapus(
        'kategori',
        '1',
        dariServer: true,
      )).called(1);
    });

    test(
      'arsipkanSatuKategori (soft delete) mendelegasikan ke OperasiDasar.perbarui',
      () async {
        when(mockOperasiDasar.perbarui(
          'kategori',
          any,
          '1',
        )).thenAnswer((final _) async {});

        await kategoriOperasi.arsipkanSatuKategori('1');

        final verification = verify(mockOperasiDasar.perbarui(
          'kategori',
          captureAny,
          '1',
        ));

        verification.called(1);
        final capturedData =
            verification.captured.first as Map<String, dynamic>;
        expect(capturedData['isDeleted'], 1);
        final diperbarui = DateTime.fromMillisecondsSinceEpoch(
          capturedData['diperbarui'] as int,
        );
        expect(
          diperbarui.isAfter(
            DateTime.now().subtract(const Duration(seconds: 5)),
          ),
          isTrue,
        );
      },
    );

    test('sisipkanAtauPerbaruiBatch mendelegasikan ke OperasiDasar', () async {
      final List<KategoriModel> items = [
        kategoriContoh,
        KategoriModel(
          id: '2',
          nama: 'Kategori 2',
          tipe: TipeKategori.pengeluaran,
        ),
      ];

      when(mockOperasiDasar.sisipkanAtauPerbaruiBatch(
        'kategori',
        any,
        dariServer: true,
      )).thenAnswer((final _) async {});

      await kategoriOperasi.sisipkanAtauPerbaruiBatch(items, dariServer: true);

      final verification = verify(mockOperasiDasar.sisipkanAtauPerbaruiBatch(
        'kategori',
        captureAny,
        dariServer: true,
      ));

      verification.called(1);
      final capturedList =
          verification.captured.first as List<Map<String, dynamic>>;
      expect(capturedList.length, 2);
      expect(capturedList[0]['id'], '1');
      expect(capturedList[1]['id'], '2');
    });

    test('sisipkanAtauPerbaruiBatch tidak melakukan apa-apa jika list kosong',
        () {
      unawaited(kategoriOperasi.sisipkanAtauPerbaruiBatch([], dariServer: true));

      verifyNever(mockOperasiDasar.sisipkanAtauPerbaruiBatch(
        any,
        any,
        dariServer: anyNamed('dariServer'),
      ));
    });

    test('getPerubahan mengambil data yang lebih baru dari timestamp',
        () async {
      final since = DateTime.now().subtract(const Duration(days: 1));
      final sinceUtc = since.toUtc().millisecondsSinceEpoch;

      when(mockDatabase.query(
        'kategori',
        where: 'diperbarui > ?',
        whereArgs: [sinceUtc],
      )).thenAnswer((final _) async => [
            kategoriContoh.copyWith(diperbarui: DateTime.now()).toSqlite(),
          ]);

      final hasil = await kategoriOperasi.getPerubahan(since);

      expect(hasil.length, 1);
      verify(mockDatabase.query(
        'kategori',
        where: 'diperbarui > ?',
        whereArgs: [sinceUtc],
      )).called(1);
    });
  });
}

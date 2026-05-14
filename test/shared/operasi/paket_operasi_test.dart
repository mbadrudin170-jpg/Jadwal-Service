// path: test/shared/operasi/paket_operasi_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';

// --- Mock ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

class MockOperasiDasar extends Mock implements OperasiDasar {}

// --- Subclass uji yang menginjeksi mock ---
class TestPaketOperasi extends PaketOperasi {
  final MockDatabaseHelper mockDbHelper;
  final MockOperasiDasar mockOperasiDasar;

  TestPaketOperasi(this.mockDbHelper, this.mockOperasiDasar);

  @override
  DatabaseHelper get dbHelper => mockDbHelper;

  @override
  OperasiDasar get _operasiDasar =>
      mockOperasiDasar; // abaikan warning, ini intentional
}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockOperasiDasar mockOperasiDasar;
  late PaketOperasi paketOperasi;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockOperasiDasar = MockOperasiDasar();
    paketOperasi = TestPaketOperasi(mockDbHelper, mockOperasiDasar);
  });

  // ---------- Helper ----------
  PaketModel dummyPaket(String id,
          {bool isDeleted = false, bool isPublic = true}) =>
      PaketModel(
        id: id,
        nama: 'Paket $id',
        durasi: 3,
        tipe: 'hari',
        harga: 10000,
        isPublic: isPublic,
        isDeleted: isDeleted,
        dibuat: DateTime(2024, 1, 1),
        diperbarui: DateTime(2024, 1, 1),
      );

  Map<String, dynamic> dummyMap(PaketModel p) => p.toSqlite();

  // ---------- createPaket ----------
  group('createPaket', () {
    test('memanggil sisipkan dengan data yang benar', () async {
      final paket = dummyPaket('1');
      when(() => mockOperasiDasar.sisipkan('paket', any(), dariServer: false))
          .thenAnswer((_) async {});

      await paketOperasi.createPaket(paket);

      final captured = verify(() => mockOperasiDasar.sisipkan(
            'paket',
            captureAny(),
            dariServer: false,
          )).captured.first as Map<String, dynamic>;

      expect(captured['id'], '1');
      expect(captured['diperbarui'], isNotNull);
    });

    test('melempar exception jika OperasiDasar gagal', () async {
      final paket = dummyPaket('err');
      when(() => mockOperasiDasar.sisipkan('paket', any(), dariServer: false))
          .thenThrow(Exception('DB error'));

      expect(() => paketOperasi.createPaket(paket), throwsException);
    });
  });

  // ---------- getAllPaket ----------
  group('getAllPaket', () {
    test('mengembalikan semua paket termasuk yang dihapus', () async {
      final maps = [
        dummyMap(dummyPaket('1', isDeleted: true)),
        dummyMap(dummyPaket('2'))
      ];
      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) async => maps);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getAllPaket();
      expect(result.length, 2);
      expect(result.first.id, '1');
      expect(result.first.isDeleted, true);
    });

    test('mengembalikan list kosong jika tabel kosong', () async {
      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) async => []);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getAllPaket();
      expect(result, isEmpty);
    });
  });

  // ---------- getPaket (aktif, isDeleted=0) ----------
  group('getPaket', () {
    test('hanya mengembalikan paket yang tidak dihapus', () async {
      final maps = [dummyMap(dummyPaket('3'))]; // isDeleted false
      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) async => maps);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPaket();
      expect(result.length, 1);
      expect(result.first.isDeleted, false);
    });
  });

  // ---------- getPaketByIsPublic ----------
  group('getPaketByIsPublic', () {
    test('hanya mengembalikan paket publik yang tidak dihapus', () async {
      final maps = [dummyMap(dummyPaket('4', isPublic: true))];
      final mockDb = MockDatabase();
      when(() => mockDb.rawQuery(any())).thenAnswer((_) async => maps);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPaketByIsPublic();
      expect(result.length, 1);
      expect(result.first.isPublic, true);
      expect(result.first.isDeleted, false);
    });
  });

  // ---------- getPaketById ----------
  group('getPaketById', () {
    test('mengembalikan paket jika ditemukan', () async {
      final mockDb = MockDatabase();
      when(() => mockDb.query('paket', where: 'id = ?', whereArgs: ['1']))
          .thenAnswer((_) async => [dummyMap(dummyPaket('1'))]);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPaketById('1');
      expect(result, isNotNull);
      expect(result!.id, '1');
    });

    test('mengembalikan null jika tidak ditemukan', () async {
      final mockDb = MockDatabase();
      when(() => mockDb.query('paket', where: 'id = ?', whereArgs: ['x']))
          .thenAnswer((_) async => []);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPaketById('x');
      expect(result, isNull);
    });
  });

  // ---------- updatePaket ----------
  group('updatePaket', () {
    test('memanggil perbarui pada OperasiDasar', () async {
      final paket = dummyPaket('1');
      when(() =>
              mockOperasiDasar.perbarui('paket', any(), '1', dariServer: false))
          .thenAnswer((_) async {});

      await paketOperasi.updatePaket(paket);

      final captured = verify(() => mockOperasiDasar.perbarui(
            'paket',
            captureAny(),
            '1',
            dariServer: false,
          )).captured.first as Map<String, dynamic>;

      expect(captured['id'], '1');
      expect(captured['diperbarui'], isNotNull);
    });
  });

  // ---------- hapusPaket ----------
  group('hapusPaket', () {
    test('memanggil hapus pada OperasiDasar', () async {
      when(() => mockOperasiDasar.hapus('paket', '10', dariServer: false))
          .thenAnswer((_) async {});

      await paketOperasi.hapusPaket('10');

      verify(() => mockOperasiDasar.hapus('paket', '10', dariServer: false))
          .called(1);
    });
  });

  // ---------- hapusSemuaPaket ----------
  group('hapusSemuaPaket', () {
    test('menjalankan operasi kompleks untuk menghapus semua', () async {
      when(() => mockOperasiDasar.jalankanOperasiKompleks(any(),
          dariServer: false)).thenAnswer((_) async => 5);

      await paketOperasi.hapusSemuaPaket();

      verify(() => mockOperasiDasar.jalankanOperasiKompleks(any(),
          dariServer: false)).called(1);
    });
  });

  // ---------- getPerubahan ----------
  group('getPerubahan', () {
    test('mengembalikan paket yang diperbarui setelah since', () async {
      final since = DateTime(2024, 6, 1);
      final maps = [dummyMap(dummyPaket('99'))];
      final mockDb = MockDatabase();
      when(() => mockDb.query('paket',
              where: 'diperbarui > ?',
              whereArgs: [since.toUtc().millisecondsSinceEpoch]))
          .thenAnswer((_) async => maps);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPerubahan(since);
      expect(result.length, 1);
      expect(result.first.id, '99');
    });

    test('mengembalikan list kosong jika tidak ada perubahan', () async {
      final since = DateTime(2025);
      final mockDb = MockDatabase();
      when(() =>
              mockDb.query('paket', where: 'diperbarui > ?', whereArgs: [any]))
          .thenAnswer((_) async => []);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPerubahan(since);
      expect(result, isEmpty);
    });
  });

  // ---------- sisipkanAtauPerbaruiBatch ----------
  group('sisipkanAtauPerbaruiBatch', () {
    test('memanggil metode batch pada OperasiDasar', () async {
      final items = [dummyPaket('1'), dummyPaket('2')];
      when(() => mockOperasiDasar.sisipkanAtauPerbaruiBatch('paket', any(),
          dariServer: false)).thenAnswer((_) async {});

      await paketOperasi.sisipkanAtauPerbaruiBatch(items);

      final captured = verify(() => mockOperasiDasar.sisipkanAtauPerbaruiBatch(
            'paket',
            captureAny(),
            dariServer: false,
          )).captured.first as List<Map<String, dynamic>>;

      expect(captured.length, 2);
      expect(captured[0]['id'], '1');
    });
  });

  // ---------- getPaketByIds ----------
  group('getPaketByIds', () {
    test('mengembalikan paket sesuai daftar id', () async {
      final mockDb = MockDatabase();
      when(() => mockDb
          .query('paket',
              where: 'id IN (?,?)', whereArgs: ['1', '2'])).thenAnswer(
          (_) async => [dummyMap(dummyPaket('1')), dummyMap(dummyPaket('2'))]);
      when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);

      final result = await paketOperasi.getPaketByIds(['1', '2']);
      expect(result.length, 2);
    });

    test('mengembalikan list kosong jika ids kosong', () async {
      final result = await paketOperasi.getPaketByIds([]);
      expect(result, isEmpty);
    });
  });
}

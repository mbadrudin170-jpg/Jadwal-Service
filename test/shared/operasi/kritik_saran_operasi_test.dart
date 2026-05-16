// path: test/shared/operasi/kritik_saran_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/feedback_operation.dart';

import 'kritik_saran_operasi_test.mocks.dart';

@GenerateMocks([DatabaseHelper, OperasiDasar, Database])
void main() {
  late KritikSaranOperasi kritikSaranOperasi;
  late MockDatabaseHelper mockDbHelper;
  late MockOperasiDasar mockOperasiDasar;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockOperasiDasar = MockOperasiDasar();
    mockDatabase = MockDatabase();

    kritikSaranOperasi = KritikSaranOperasi(
      dbHelper: mockDbHelper,
      operasiDasar: mockOperasiDasar,
    );

    when(mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  group('KritikSaranOperasi Unit Tests', () {
    final tKritikSaran = FeedbackModel(
      id: 'ks_001',
      userId: 'user_123',
      isi: 'Aplikasi sangat membantu!',
      tanggal: DateTime.now(),
    );

    test('createKritikSaran harus memanggil OperasiDasar.sisipkan', () async {
      when(mockOperasiDasar.sisipkan(any, any))
          .thenAnswer((final _) async => 1);

      await kritikSaranOperasi.createKritikSaran(tKritikSaran);

      verify(
        mockOperasiDasar.sisipkan(
          'kritik_saran',
          any,
        ),
      ).called(1);
    });

    test('getKritikSaran harus mengembalikan list data dari SQLite', () async {
      when(
        mockDatabase.query(
          'kritik_saran',
          orderBy: anyNamed('orderBy'),
        ),
      ).thenAnswer(
        (final _) async => [
          {
            'id': 'ks_001',
            'userId': 'user_123',
            'isi': 'Bagus!',
            'tanggal': DateTime.now().millisecondsSinceEpoch,
            'diperbarui': DateTime.now().millisecondsSinceEpoch,
          },
        ],
      );

      final result = await kritikSaranOperasi.getKritikSaran();

      expect(result, isA<List<FeedbackModel>>());
      expect(result.first.id, 'ks_001');
      verify(
        mockDatabase.query(
          'kritik_saran',
          orderBy: 'tanggal DESC',
        ),
      ).called(1);
    });

    test('getKritikSaranById harus melempar Exception jika ID tidak ditemukan',
        () {
      when(
        mockDatabase.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        ),
      ).thenAnswer((final _) async => []);

      expect(
        () => kritikSaranOperasi.getKritikSaranById('999'),
        throwsException,
      );
    });

    test('hapusKritikSaran harus memanggil OperasiDasar.hapus', () async {
      when(mockOperasiDasar.hapus(any, any)).thenAnswer((final _) async => 1);

      await kritikSaranOperasi.hapusKritikSaran('ks_001');

      verify(mockOperasiDasar.hapus('kritik_saran', 'ks_001')).called(1);
    });

    test('sisipkanAtauPerbaruiBatch tidak melakukan apa-apa jika list kosong',
        () async {
      await kritikSaranOperasi.sisipkanAtauPerbaruiBatch([]);

      verifyNever(mockOperasiDasar.sisipkanAtauPerbaruiBatch(any, any));
    });

    test('sisipkanAtauPerbaruiBatch harus memanggil operasi dasar', () async {
      when(mockOperasiDasar.sisipkanAtauPerbaruiBatch(any, any))
          .thenAnswer((final _) async => {});

      await kritikSaranOperasi.sisipkanAtauPerbaruiBatch([tKritikSaran]);

      verify(
        mockOperasiDasar.sisipkanAtauPerbaruiBatch(
          'kritik_saran',
          any,
        ),
      ).called(1);
    });
  });
}

// path: test/fitur/investasi/operasi/investasi_op_firebase_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

// ============================================================
// MOCK CLASS
// ============================================================

class MockBaseOpFirebase extends Mock implements BaseOpFirebase {}

// ============================================================
// MAIN TEST
// ============================================================

void main() {
  // ============================================================
  // VARIABEL
  // ============================================================

  late InvestasiOpFirebase investasiOp;
  late MockBaseOpFirebase mockBaseOp;
  late FakeFirebaseFirestore fakeFirestore;

  // ============================================================
  // DATA DUMMY
  // ============================================================

  final dummyInvestasi = InvestasiModel(
    id: 'inv-001',
    idInvestor: 'investor-001',
    idTransaksi: 'trx-001',
    jumlahModal: 5000000,
    jumlahLembar: 50,
    tanggalInvestasi: DateTime(2024, 1, 15),
  );

  final dummyDividen = DividenModel(
    id: 'div-001',
    idInvestasi: 'inv-001',
    idInvestor: 'investor-001',
    jumlahDividen: 500000,
    tanggalPembagian: DateTime(2024, 2, 15),
    sudahDibayar: false,
  );

  // ============================================================
  // SETUP
  // ============================================================

  setUp(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);

    fakeFirestore = FakeFirebaseFirestore();
    mockBaseOp = MockBaseOpFirebase();

    investasiOp = InvestasiOpFirebase(
      firestore: fakeFirestore,
      baseOpFirebase: mockBaseOp,
    );
  });

  // ============================================================
  // TEST INVESTASI
  // ============================================================

  group('InvestasiOpFirebase - tambahInvestasi', () {
    test('harus berhasil menambahkan investasi ke Firebase', () async {
      when(
        () => mockBaseOp.sisipkan(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tambahInvestasi(dummyInvestasi),
        completes,
      );

      verify(
        () => mockBaseOp.sisipkan(any(), any(), any()),
      ).called(1);
    });

    test('harus melempar error jika gagal menambahkan', () async {
      when(
        () => mockBaseOp.sisipkan(any(), any(), any()),
      ).thenThrow(Exception('Firestore error'));

      await expectLater(
        investasiOp.tambahInvestasi(dummyInvestasi),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // TEST AMBIL SEMUA INVESTASI (menggunakan fake firestore)
  // ============================================================

  group('InvestasiOpFirebase - ambilSemuaInvestasi', () {
    test('harus mengembalikan list investasi jika ada data', () async {
      // Tambahkan data ke fake firestore
      final docRef = fakeFirestore.collection('investasi').doc('inv-001');
      await docRef.set({
        'id': 'inv-001',
        'id_investor': 'investor-001',
        'id_transaksi': 'trx-001',
        'jumlah_modal': 5000000,
        'jumlah_lembar': 50,
        'tanggal_investasi': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'is_deleted': false,
      });

      final result = await investasiOp.ambilSemuaInvestasi();

      expect(result, isNotEmpty);
      expect(result.first.id, equals('inv-001'));
      expect(result.first.jumlahModal, equals(5000000));
    });

    test('harus mengembalikan list kosong jika tidak ada data', () async {
      final result = await investasiOp.ambilSemuaInvestasi();

      expect(result, isEmpty);
    });
  });

  // ============================================================
  // TEST AMBIL INVESTASI BERDASARKAN ID
  // ============================================================

  group('InvestasiOpFirebase - ambilInvestasiById', () {
    test('harus mengembalikan investasi jika ditemukan', () async {
      final docRef = fakeFirestore.collection('investasi').doc('inv-001');
      await docRef.set({
        'id': 'inv-001',
        'id_investor': 'investor-001',
        'id_transaksi': 'trx-001',
        'jumlah_modal': 5000000,
        'jumlah_lembar': 50,
        'tanggal_investasi': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'is_deleted': false,
      });

      final result = await investasiOp.ambilInvestasiById('inv-001');

      expect(result, isNotNull);
      expect(result!.id, equals('inv-001'));
    });

    test('harus mengembalikan null jika tidak ditemukan', () async {
      final result = await investasiOp.ambilInvestasiById('inv-999');

      expect(result, isNull);
    });
  });

  // ============================================================
  // TEST AMBIL INVESTASI BERDASARKAN ID INVESTOR
  // ============================================================

  group('InvestasiOpFirebase - ambilInvestasiByIdInvestor', () {
    test('harus mengembalikan list investasi untuk investor tertentu', () async {
      // Tambahkan data ke fake firestore
      final docRef1 = fakeFirestore.collection('investasi').doc('inv-001');
      await docRef1.set({
        'id': 'inv-001',
        'id_investor': 'investor-001',
        'id_transaksi': 'trx-001',
        'jumlah_modal': 5000000,
        'jumlah_lembar': 50,
        'tanggal_investasi': DateTime(2024, 1, 15).millisecondsSinceEpoch,
        'is_deleted': false,
      });

      final docRef2 = fakeFirestore.collection('investasi').doc('inv-002');
      await docRef2.set({
        'id': 'inv-002',
        'id_investor': 'investor-001',
        'id_transaksi': 'trx-002',
        'jumlah_modal': 3000000,
        'jumlah_lembar': 30,
        'tanggal_investasi': DateTime(2024, 2, 15).millisecondsSinceEpoch,
        'is_deleted': false,
      });

      final result = await investasiOp.ambilInvestasiByIdInvestor('investor-001');

      expect(result.length, equals(2));
      expect(result.every((i) => i.idInvestor == 'investor-001'), isTrue);
    });
  });

  // ============================================================
  // TEST PERBARUI INVESTASI
  // ============================================================

  group('InvestasiOpFirebase - perbaruiInvestasi', () {
    test('harus berhasil memperbarui investasi', () async {
      when(
        () => mockBaseOp.update(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.perbaruiInvestasi(dummyInvestasi),
        completes,
      );
    });
  });

  // ============================================================
  // TEST SOFT DELETE INVESTASI
  // ============================================================

  group('InvestasiOpFirebase - softDeleteInvestasi', () {
    test('harus berhasil soft delete investasi', () async {
      when(
        () => mockBaseOp.softDelete(any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.softDeleteInvestasi('inv-001'),
        completes,
      );
    });
  });

  // ============================================================
  // TEST DIVIDEN
  // ============================================================

  group('InvestasiOpFirebase - operasi dividen', () {
    test('ambilSemuaDividen - harus mengembalikan list dividen', () async {
      final docRef = fakeFirestore.collection('dividen').doc('div-001');
      await docRef.set({
        'id': 'div-001',
        'id_investasi': 'inv-001',
        'id_investor': 'investor-001',
        'jumlah_dividen': 500000,
        'tanggal_pembagian': DateTime(2024, 2, 15).millisecondsSinceEpoch,
        'sudah_dibayar': false,
        'is_deleted': false,
      });

      final result = await investasiOp.ambilSemuaDividen();

      expect(result, isNotEmpty);
      expect(result.first.id, equals('div-001'));
    });

    test('ambilDividenByIdInvestor - harus mengembalikan dividen untuk investor',
        () async {
      final docRef = fakeFirestore.collection('dividen').doc('div-001');
      await docRef.set({
        'id': 'div-001',
        'id_investasi': 'inv-001',
        'id_investor': 'investor-001',
        'jumlah_dividen': 500000,
        'tanggal_pembagian': DateTime(2024, 2, 15).millisecondsSinceEpoch,
        'sudah_dibayar': false,
        'is_deleted': false,
      });

      final result = await investasiOp.ambilDividenByIdInvestor('investor-001');

      expect(result, isNotEmpty);
    });

    test('tambahDividen - harus berhasil menambahkan dividen', () async {
      when(
        () => mockBaseOp.sisipkan(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tambahDividen(dummyDividen),
        completes,
      );
    });

    test('perbaruiDividen - harus berhasil memperbarui dividen', () async {
      when(
        () => mockBaseOp.update(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.perbaruiDividen(dummyDividen),
        completes,
      );
    });

    test('softDeleteDividen - harus berhasil soft delete dividen', () async {
      when(
        () => mockBaseOp.softDelete(any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.softDeleteDividen('div-001'),
        completes,
      );
    });

    test('tandaiDividenDibayar - harus berhasil menandai dividen dibayar',
        () async {
      when(
        () => mockBaseOp.update(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tandaiDividenDibayar('div-001'),
        completes,
      );
    });
  });

  // ============================================================
  // TEST BATCH OPERATION
  // ============================================================

  group('InvestasiOpFirebase - batch operation', () {
    test('sisipkanAtauPerbaruiBatch - berhasil untuk list tidak kosong',
        () async {
      when(
        () => mockBaseOp.insertOrUpdateBatch(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatch([dummyInvestasi]),
        completes,
      );
    });

    test('sisipkanAtauPerbaruiBatch - skip untuk list kosong', () async {
      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatch([]),
        completes,
      );

      verifyNever(
        () => mockBaseOp.insertOrUpdateBatch(any(), any(), any()),
      );
    });

    test('sisipkanAtauPerbaruiBatchDividen - berhasil untuk list tidak kosong',
        () async {
      when(
        () => mockBaseOp.insertOrUpdateBatch(any(), any(), any()),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatchDividen([dummyDividen]),
        completes,
      );
    });
  });
}
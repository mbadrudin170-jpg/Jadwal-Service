
// path: test/fitur/investasi/operasi/investasi_op_firebase_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/fitur/investasi/operasi/investasi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

// ============================================================
// MOCK CLASS (Mocktail - tanpa generator)
// ============================================================

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockQuery extends Mock implements Query {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockBaseOpFirebase extends Mock implements BaseOpFirebase {}

// ============================================================
// MAIN TEST
// ============================================================

void main() {
  // ============================================================
  // VARIABEL
  // ============================================================

  late InvestasiOpFirebase investasiOp;
  late MockFirebaseFirestore mockFirestore;
  late MockBaseOpFirebase mockBaseOp;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockQueryDocSnapshot;
  late MockDocumentSnapshot mockDocumentSnapshot;

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

  final dummyInvestasiMap = {
    'id': 'inv-001',
    'id_investor': 'investor-001',
    'id_transaksi': 'trx-001',
    'jumlah_modal': 5000000,
    'jumlah_lembar': 50,
    'tanggal_investasi': DateTime(2024, 1, 15).millisecondsSinceEpoch,
    'is_deleted': false,
  };

  final dummyDividenMap = {
    'id': 'div-001',
    'id_investasi': 'inv-001',
    'id_investor': 'investor-001',
    'jumlah_dividen': 500000,
    'tanggal_pembagian': DateTime(2024, 2, 15).millisecondsSinceEpoch,
    'sudah_dibayar': false,
    'is_deleted': false,
  };

  // ============================================================
  // SETUP
  // ============================================================

  setUp(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);

    mockFirestore = MockFirebaseFirestore();
    mockBaseOp = MockBaseOpFirebase();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDocSnapshot = MockQueryDocumentSnapshot();
    mockDocumentSnapshot = MockDocumentSnapshot();

    // Setup collection
    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);

    // Setup doc
    when(() => mockCollection.doc(any())).thenReturn(mockDocRef);

    // Setup query with where
    when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockQuery);
    when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockQuery);
    when(() => mockCollection.orderBy(any(), descending: any(named: 'descending')))
        .thenReturn(mockQuery);

    // Setup query chaining
    when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockQuery);
    when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
        .thenReturn(mockQuery);
    when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

    // Setup document
    when(() => mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);

    investasiOp = InvestasiOpFirebase(
      firestore: mockFirestore,
      baseOpFirebase: mockBaseOp,
    );
  });

  // ============================================================
  // TEST INVESTASI
  // ============================================================

  group('InvestasiOpFirebase - tambahInvestasi', () {
    test('harus berhasil menambahkan investasi ke Firebase', () async {
      when(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tambahInvestasi(dummyInvestasi),
        completes,
      );

      verify(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          any(),
        ),
      ).called(1);
    });

    test('harus melempar error jika gagal menambahkan', () async {
      when(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception('Firestore error'));

      await expectLater(
        investasiOp.tambahInvestasi(dummyInvestasi),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // TEST AMBIL SEMUA INVESTASI
  // ============================================================

  group('InvestasiOpFirebase - ambilSemuaInvestasi', () {
    test('harus mengembalikan list investasi jika ada data', () async {
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(() => mockQueryDocSnapshot.id).thenReturn('inv-001');
      when(() => mockQueryDocSnapshot.data())
          .thenReturn(dummyInvestasiMap as Map<String, dynamic>);

      final result = await investasiOp.ambilSemuaInvestasi();

      expect(result, isNotEmpty);
      expect(result.first.id, equals('inv-001'));
    });

    test('harus mengembalikan list kosong jika tidak ada data', () async {
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final result = await investasiOp.ambilSemuaInvestasi();

      expect(result, isEmpty);
    });

    test('harus melempar error jika query gagal', () async {
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      await expectLater(
        investasiOp.ambilSemuaInvestasi(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ============================================================
  // TEST AMBIL INVESTASI BERDASARKAN ID
  // ============================================================

  group('InvestasiOpFirebase - ambilInvestasiById', () {
    test('harus mengembalikan investasi jika ditemukan', () async {
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.id).thenReturn('inv-001');
      when(() => mockDocumentSnapshot.data())
          .thenReturn(dummyInvestasiMap as Map<String, dynamic>);

      final result = await investasiOp.ambilInvestasiById('inv-001');

      expect(result, isNotNull);
      expect(result!.id, equals('inv-001'));
    });

    test('harus mengembalikan null jika tidak ditemukan', () async {
      when(() => mockDocumentSnapshot.exists).thenReturn(false);

      final result = await investasiOp.ambilInvestasiById('inv-999');

      expect(result, isNull);
    });
  });

  // ============================================================
  // TEST AMBIL INVESTASI BERDASARKAN ID INVESTOR
  // ============================================================

  group('InvestasiOpFirebase - ambilInvestasiByIdInvestor', () {
    test('harus mengembalikan list investasi untuk investor tertentu', () async {
      when(() => mockQuerySnapshot.docs).thenReturn([
        mockQueryDocSnapshot,
      ]);
      when(() => mockQueryDocSnapshot.id).thenReturn('inv-001');
      when(() => mockQueryDocSnapshot.data())
          .thenReturn(dummyInvestasiMap as Map<String, dynamic>);

      final result = await investasiOp.ambilInvestasiByIdInvestor('investor-001');

      expect(result, isNotEmpty);
      expect(result.first.idInvestor, equals('investor-001'));
    });
  });

  // ============================================================
  // TEST PERBARUI INVESTASI
  // ============================================================

  group('InvestasiOpFirebase - perbaruiInvestasi', () {
    test('harus berhasil memperbarui investasi', () async {
      when(
        () => mockBaseOp.update(
          any(),
          any(),
          any(),
        ),
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
        () => mockBaseOp.softDelete(
          any(),
          any(),
        ),
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
    test('tambahDividen - harus berhasil menambahkan dividen', () async {
      when(
        () => mockBaseOp.sisipkan(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tambahDividen(dummyDividen),
        completes,
      );
    });

    test('ambilSemuaDividen - harus mengembalikan list dividen', () async {
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(() => mockQueryDocSnapshot.id).thenReturn('div-001');
      when(() => mockQueryDocSnapshot.data())
          .thenReturn(dummyDividenMap as Map<String, dynamic>);

      final result = await investasiOp.ambilSemuaDividen();

      expect(result, isNotEmpty);
      expect(result.first.id, equals('div-001'));
    });

    test('ambilDividenByIdInvestor - harus mengembalikan dividen untuk investor',
        () async {
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);
      when(() => mockQueryDocSnapshot.id).thenReturn('div-001');
      when(() => mockQueryDocSnapshot.data())
          .thenReturn(dummyDividenMap as Map<String, dynamic>);

      final result = await investasiOp.ambilDividenByIdInvestor('investor-001');

      expect(result, isNotEmpty);
    });

    test('tandaiDividenDibayar - harus berhasil menandai dividen dibayar',
        () async {
      when(
        () => mockBaseOp.update(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.tandaiDividenDibayar('div-001'),
        completes,
      );
    });

    test('softDeleteDividen - harus berhasil soft delete dividen', () async {
      when(
        () => mockBaseOp.softDelete(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.softDeleteDividen('div-001'),
        completes,
      );
    });
  });

  // ============================================================
  // TEST BATCH OPERATION
  // ============================================================

  group('InvestasiOpFirebase - batch operation', () {
    test('sisipkanAtauPerbaruiBatch - harus berhasil untuk list tidak kosong',
        () async {
      when(
        () => mockBaseOp.insertOrUpdateBatch(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatch([dummyInvestasi]),
        completes,
      );
    });

    test('sisipkanAtauPerbaruiBatch - harus skip untuk list kosong', () async {
      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatch([]),
        completes,
      );

      verifyNever(
        () => mockBaseOp.insertOrUpdateBatch(
          any(),
          any(),
          any(),
        ),
      );
    });

    test('sisipkanAtauPerbaruiBatchDividen - harus berhasil untuk list tidak kosong',
        () async {
      when(
        () => mockBaseOp.insertOrUpdateBatch(
          any(),
          any(),
          any(),
        ),
      ).thenAnswer((_) async => Future.value());

      await expectLater(
        investasiOp.sisipkanAtauPerbaruiBatchDividen([dummyDividen]),
        completes,
      );
    });
  });
}
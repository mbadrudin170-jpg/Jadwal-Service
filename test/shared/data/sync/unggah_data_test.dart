// path: test/shared/data/sync/unggah_data_test.dart
// ignore_for_file: avoid_implementing_value_types, subtype_of_sealed_class

@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/data/sync/unggah_data.dart';
import 'package:wifi/shared/model/memiliki_id.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// --- Mocks ---
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockSyncManager extends Mock implements SyncManager {}

class FakeDocumentReference<T> extends Fake implements DocumentReference<T> {}

/// Model dummy untuk testing unggahDataGenerik.
class MemilikiIdTest implements MemilikiId {
  @override
  final String id;
  final String nama;

  MemilikiIdTest({required this.id, required this.nama});

  factory MemilikiIdTest.fromSqlite(final Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw ArgumentError('id tidak boleh null');
    }
    return MemilikiIdTest(
      id: map['id'] as String,
      nama: (map['nama'] as String?) ?? '',
    );
  }
}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late LayananUnggahData layanan;

  final waktuSinkronisasi = DateTime(2024, 8, 1, 12);

  setUpAll(() {
    registerFallbackValue(SetOptions(merge: true));
    registerFallbackValue(FakeDocumentReference<Map<String, dynamic>>());
  });

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();

    when(() => mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
    when(() => mockSyncManager.getTerakhirUnggah())
        .thenAnswer((final _) async => waktuSinkronisasi);

    layanan = LayananUnggahData(
      dbHelper: mockDbHelper,
      firestore: mockFirestore,
      syncManager: mockSyncManager,
    );
  });

  group('LayananUnggahData', () {
    group('unggahSemuaData', () {
      test('memanggil semua 11 fungsi unggah secara paralel', () async {
        when(
          () => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          ),
        ).thenAnswer((final _) async => []);

        await layanan.unggahSemuaData();

        verify(() => mockSyncManager.getTerakhirUnggah()).called(11);
      });

      test('melempar exception jika salah satu unggah gagal', () {
        when(
          () => mockDatabase.query(
            'dompet',
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          ),
        ).thenThrow(Exception('DB error'));

        when(
          () => mockDatabase.query(
            any(that: isNot(equals('dompet'))),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          ),
        ).thenAnswer((final _) async => []);

        expect(
          () => layanan.unggahSemuaData(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('unggahDataGenerik', () {
      late MockWriteBatch mockBatch;
      late MockCollectionReference<Map<String, dynamic>> mockCollection;
      late MockDocumentReference<Map<String, dynamic>> mockDocRef;

      setUp(() {
        mockBatch = MockWriteBatch();
        mockCollection = MockCollectionReference<Map<String, dynamic>>();
        mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(
          () => mockBatch.set(
            any<DocumentReference<Map<String, dynamic>>>(),
            any<Map<String, dynamic>>(),
            any<SetOptions>(),
          ),
        ).thenAnswer((final _) {});
        when(() => mockBatch.commit()).thenAnswer((final _) async => <dynamic>[]);
        when(() => mockFirestore.collection(any<String>()))
            .thenReturn(mockCollection);
        when(() => mockCollection.doc(any<String>())).thenReturn(mockDocRef);
      });

      Map<String, dynamic> dummyToFirebase(final MemilikiIdTest m) {
        return {'id': m.id, 'nama': 'test'};
      }

      test('tidak melakukan apa-apa jika tidak ada data baru', () async {
        when(
          () => mockDatabase.query(
            'test_table',
            where: 'diperbarui > ?',
            whereArgs: [waktuSinkronisasi.toIso8601String()],
          ),
        ).thenAnswer((final _) async => []);

        await layanan.unggahDataGenerik<MemilikiIdTest>(
          'test_table',
          'test_collection',
          MemilikiIdTest.fromSqlite,
          dummyToFirebase,
          waktuSinkronisasi,
        );

        verifyNever(() => mockFirestore.batch());
      });

      test('mengunggah data yang diperbarui', () async {
        final dataMap = {
          'id': '1',
          'nama': 'Test',
          'diperbarui': '2024-08-02T00:00:00.000',
        };

        when(
          () => mockDatabase.query(
            'test_table',
            where: 'diperbarui > ?',
            whereArgs: [waktuSinkronisasi.toIso8601String()],
          ),
        ).thenAnswer((final _) async => [dataMap]);
        when(() => mockFirestore.collection('test_collection'))
            .thenReturn(mockCollection);
        when(() => mockCollection.doc('1')).thenReturn(mockDocRef);

        await layanan.unggahDataGenerik<MemilikiIdTest>(
          'test_table',
          'test_collection',
          MemilikiIdTest.fromSqlite,
          dummyToFirebase,
          waktuSinkronisasi,
        );

        verify(() => mockFirestore.batch()).called(1);
        verify(
          () => mockBatch.set(
            mockDocRef,
            any<Map<String, dynamic>>(),
            any<SetOptions>(),
          ),
        ).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('tetap commit meski ada data yang gagal dikonversi', () async {
        final validMap = {
          'id': 'valid',
          'nama': 'Valid',
          'diperbarui': '2024-08-02T00:00:00.000',
        };
        final invalidMap = {
          'id': null,
          'nama': 'Invalid',
        };

        when(
          () => mockDatabase.query(
            'test_table',
            where: 'diperbarui > ?',
            whereArgs: [waktuSinkronisasi.toIso8601String()],
          ),
        ).thenAnswer((final _) async => [validMap, invalidMap]);
        when(() => mockFirestore.collection('test_collection'))
            .thenReturn(mockCollection);
        when(() => mockCollection.doc('valid')).thenReturn(mockDocRef);

        await layanan.unggahDataGenerik<MemilikiIdTest>(
          'test_table',
          'test_collection',
          MemilikiIdTest.fromSqlite,
          dummyToFirebase,
          waktuSinkronisasi,
        );

        verify(
          () => mockBatch.set(
            mockDocRef,
            any<Map<String, dynamic>>(),
            any<SetOptions>(),
          ),
        ).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('tidak commit jika semua data gagal', () async {
        final invalidMaps = [
          {'id': null},
          {'id': null},
        ];

        when(
          () => mockDatabase.query(
            'test_table',
            where: 'diperbarui > ?',
            whereArgs: [waktuSinkronisasi.toIso8601String()],
          ),
        ).thenAnswer((final _) async => invalidMaps);

        await layanan.unggahDataGenerik<MemilikiIdTest>(
          'test_table',
          'test_collection',
          MemilikiIdTest.fromSqlite,
          dummyToFirebase,
          waktuSinkronisasi,
        );

        verify(() => mockFirestore.batch()).called(1);
        verifyNever(() => mockBatch.set(
            any<DocumentReference<Map<String, dynamic>>>(),
            any<Map<String, dynamic>>(),
            any<SetOptions>()));
        verifyNever(() => mockBatch.commit());
      });

      test('melempar exception jika query database gagal', () {
        when(
          () => mockDatabase.query(
            'test_table',
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          ),
        ).thenThrow(Exception('DB error'));

        expect(
          () => layanan.unggahDataGenerik<MemilikiIdTest>(
            'test_table',
            'test_collection',
            MemilikiIdTest.fromSqlite,
            dummyToFirebase,
            waktuSinkronisasi,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('unggahDataDompet', () {
      test('memanggil unggahDataGenerik dengan parameter yang benar', () async {
        when(
          () => mockDatabase.query(
            'dompet',
            where: 'diperbarui > ?',
            whereArgs: [waktuSinkronisasi.toIso8601String()],
          ),
        ).thenAnswer((final _) async => []);

        await layanan.unggahDataDompet();

        verify(() => mockSyncManager.getTerakhirUnggah()).called(1);
        verify(
          () => mockDatabase.query(
            'dompet',
            where: 'diperbarui > ?',
            whereArgs: [waktuSinkronisasi.toIso8601String()],
          ),
        ).called(1);
      });

      test('melempar exception jika gagal', () {
        when(
          () => mockDatabase.query(
            'dompet',
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
          ),
        ).thenThrow(Exception('Gagal query dompet'));

        expect(
          () => layanan.unggahDataDompet(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// path: test/shared/operasi/firebase_operasi/pelanggan_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/pelanggan_op_firebase.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot
])
import 'pelanggan_op_firebase_test.mocks.dart';

/// Subclass untuk injeksi mock collection
class TestPelangganOpFirebase extends PelangganOpFirebase {
  final CollectionReference mockCollection;

  TestPelangganOpFirebase(this.mockCollection);

  @override
  CollectionReference get _koleksiPelanggan => mockCollection;
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;
  late TestPelangganOpFirebase opFirebase;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    opFirebase = TestPelangganOpFirebase(mockCollection);
  });

  // Helper: buat dummy PelangganModel
  PelangganModel dummyPelanggan(String id) => PelangganModel(
        id: id,
        nama: 'Nama $id',
        email: '$id@test.com',
        nomorHp: '08123456789',
        dibuat: DateTime(2024, 1, 1),
        diperbarui: DateTime(2024, 1, 1),
      );

  // ===================== perbaruiPelanggan =====================
  group('perbaruiPelanggan', () {
    test('berhasil memperbarui dokumen dengan data yang benar', () async {
      final pelanggan = dummyPelanggan('123');
      // Setup mock
      when(mockCollection.doc('123')).thenReturn(mockDocRef);
      when(mockDocRef.update(any)).thenAnswer((_) async => {});

      await opFirebase.perbaruiPelanggan(pelanggan);

      // Verifikasi update dipanggil dengan map yang mengandung 'diperbarui'
      final captured = verify(mockDocRef.update(captureAny)).captured.first
          as Map<String, dynamic>;
      expect(captured['id'],
          null); // ID mungkin tidak ada, yang penting diperbarui ada
      expect(captured['diperbarui'],
          isA<FieldValue>()); // FieldValue.serverTimestamp()
    });

    test('melempar ulang error jika Firestore gagal', () async {
      final pelanggan = dummyPelanggan('error');
      when(mockCollection.doc('error')).thenReturn(mockDocRef);
      when(mockDocRef.update(any)).thenThrow(FirebaseException(
          plugin: 'cloud_firestore', message: 'Permission denied'));

      expect(() => opFirebase.perbaruiPelanggan(pelanggan),
          throwsA(isA<FirebaseException>()));
    });
  });

  // ===================== ambilPelangganStream =====================
  group('ambilPelangganStream', () {
    test('mengembalikan PelangganModel jika dokumen ada', () async {
      final userId = 'user1';
      final data = <String, dynamic>{
        'nama': 'Budi',
        'email': 'budi@test.com',
        'nomorHp': '08123456789',
        'dibuat': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'diperbarui': Timestamp.fromDate(DateTime(2024, 1, 1)),
      };
      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.snapshots()).thenAnswer(
        (_) => Stream.value(mockDocSnapshot),
      );
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.id).thenReturn(userId);
      when(mockDocSnapshot.data()).thenReturn(data);

      final stream = opFirebase.ambilPelangganStream(userId);
      final result = await stream.first;

      expect(result, isNotNull);
      expect(result!.id, userId);
      expect(result.nama, 'Budi');
    });

    test('mengembalikan null jika dokumen tidak ada', () async {
      final userId = 'userX';
      when(mockCollection.doc(userId)).thenReturn(mockDocRef);
      when(mockDocRef.snapshots()).then
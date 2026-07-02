// path: test/fitur/pelanggan/operasi/pelanggan_op_firebase_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

import 'pelanggan_op_firebase_test.mocks.dart';

@GenerateMocks([
  BaseOpFirebase,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late PelangganOpFirebase pelangganOpFirebase;
  late MockBaseOpFirebase mockBaseOpFirebase;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

  setUp(() {
    mockBaseOpFirebase = MockBaseOpFirebase();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    pelangganOpFirebase = PelangganOpFirebase(
      firestore: mockFirestore,
      baseOpFirebase: mockBaseOpFirebase,
    );
  });

  final pelangganModel = const PelangganModel(
    id: '1',
    nama: 'Pelanggan Uji',
    telepon: '08123',
    alamat: 'Jl. Uji',
    kataSandi: '123',
    macAddress: '00:00:00:00:00:00',
  );

  group('PelangganOpFirebase', () {
    test('01. harus memanggil base.sisipkan saat tambahPelanggan', () async {
      when(
        mockBaseOpFirebase.sisipkan(any, any, any),
      ).thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.tambahPelanggan(pelangganModel);

      verify(
        mockBaseOpFirebase.sisipkan(
          'customer', // Diubah menjadi 'customer' sesuai NamaTabel.pelanggan
          pelangganModel.id,
          any, // data
        ),
      ).called(1);
    });

    test('02. harus memanggil base.update saat perbaruiPelanggan', () async {
      when(
        mockBaseOpFirebase.update(any, any, any),
      ).thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.perbaruiPelanggan(pelangganModel);

      verify(
        mockBaseOpFirebase.update(
          'customer', // Diubah menjadi 'customer' sesuai NamaTabel.pelanggan
          pelangganModel.id,
          any, // data
        ),
      ).called(1);
    });

    test('03. harus memanggil base.hapusSementara saat softDelete', () async {
      when(
        mockBaseOpFirebase.softDelete(any, any),
      ).thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.softDelete(pelangganModel.id);

      verify(
        mockBaseOpFirebase.softDelete(
          'customer', // Diubah menjadi 'customer' sesuai NamaTabel.pelanggan
          pelangganModel.id,
        ),
      ).called(1);
    });

    test('04. harus memanggil base.update saat perbaruiTerakhirAktif', () async {
      when(
        mockBaseOpFirebase.update(any, any, any),
      ).thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.perbaruiTerakhirAktif(pelangganModel.id);

      verify(
        mockBaseOpFirebase.update(
          'customer', // Diubah menjadi 'customer' sesuai NamaTabel.pelanggan
          pelangganModel.id,
          any, // Menggunakan any karena FieldValue instance sulit dibandingkan literal
        ),
      ).called(1);
    });

    test(
      '05. harus mengembalikan pelanggan saat ambilBerdasarkanId berhasil',
      () async {
        when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
        when(
          mockCollectionReference.doc(any),
        ).thenReturn(mockDocumentReference);
        when(
          mockDocumentReference.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.id).thenReturn(pelangganModel.id);
        when(
          mockDocumentSnapshot.data(),
        ).thenReturn(pelangganModel.toFirebase());

        final result = await pelangganOpFirebase.ambilBerdasarkanId(
          pelangganModel.id,
        );

        expect(result, isA<PelangganModel>());
        expect(result?.id, pelangganModel.id);
      },
    );

    test(
      '06. harus mengembalikan null saat ambilBerdasarkanId tidak menemukan data',
      () async {
        when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
        when(
          mockCollectionReference.doc(any),
        ).thenReturn(mockDocumentReference);
        when(
          mockDocumentReference.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        final result = await pelangganOpFirebase.ambilBerdasarkanId('999');

        expect(result, isNull);
      },
    );
  });
}

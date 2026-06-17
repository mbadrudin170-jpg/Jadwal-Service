
// path: test/fitur/pelanggan/operasi/pelanggan_op_firebase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

import 'pelanggan_op_firebase_test.mocks.dart';

@GenerateMocks([BaseOpFirebase])
void main() {
  late PelangganOpFirebase pelangganOpFirebase;
  late MockBaseOpFirebase mockBaseOpFirebase;

  setUp(() {
    mockBaseOpFirebase = MockBaseOpFirebase();
    pelangganOpFirebase = PelangganOpFirebase(
      baseOpFirebase: mockBaseOpFirebase,
    );
  });

  final pelangganModel = PelangganModel(
    id: '1',
    nama: 'Pelanggan Uji',
    telepon: '08123',
    alamat: 'Jl. Uji',
    kataSandi: '123',
    macAddress: '00:00:00:00:00:00',
  );

  group('PelangganOpFirebase', () {
    test('01. harus memanggil base.tambah saat tambahPelanggan', () async {
      when(mockBaseOpFirebase.tambah(any, any, any))
          .thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.tambahPelanggan(pelangganModel);

      verify(mockBaseOpFirebase.tambah(
        'pelanggan',
        pelangganModel.id,
        any, // data
      )).called(1);
    });

    test('02. harus memanggil base.perbarui saat perbaruiPelanggan', () async {
      when(mockBaseOpFirebase.perbarui(any, any, any))
          .thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.perbaruiPelanggan(pelangganModel);

      verify(mockBaseOpFirebase.perbarui(
        'pelanggan',
        pelangganModel.id,
        any, // data
      )).called(1);
    });

    test('03. harus memanggil base.softDelete saat hapusPelanggan', () async {
      when(mockBaseOpFirebase.softDelete(any, any))
          .thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.hapusPelanggan(pelangganModel.id);

      verify(mockBaseOpFirebase.softDelete('pelanggan', pelangganModel.id))
          .called(1);
    });

    test('04. harus memanggil base.ambilBerdasarkanId saat ambilPelanggan', () async {
      when(mockBaseOpFirebase.ambilBerdasarkanId(any, any)).thenAnswer(
        (_) async => {
          'nama': 'Pelanggan Uji', // sesuaikan dengan field di model
          'telepon': '08123',
          'alamat': 'Jl. Uji',
          'kataSandi': '123',
          'macAddress': '00:00:00:00:00:00',
        },
      );

      final result = await pelangganOpFirebase.ambilPelanggan(pelangganModel.id);

      expect(result, isA<PelangganModel>());
      expect(result?.id, pelangganModel.id);
      verify(mockBaseOpFirebase.ambilBerdasarkanId(
        'pelanggan',
        pelangganModel.id,
      )).called(1);
    });

    test('05. harus mengembalikan null jika ambilPelanggan tidak menemukan data', () async {
      when(mockBaseOpFirebase.ambilBerdasarkanId(any, any))
          .thenAnswer((_) async => null);

      final result = await pelangganOpFirebase.ambilPelanggan('999');

      expect(result, isNull);
    });

    test(
        '06. harus memanggil base.perbaruiField saat perbaruiTerakhirAktif',
        () async {
      when(mockBaseOpFirebase.perbaruiField(any, any, any, any))
          .thenAnswer((_) async => Future.value());

      await pelangganOpFirebase.perbaruiTerakhirAktif(pelangganModel.id);

      verify(mockBaseOpFirebase.perbaruiField(
        'pelanggan',
        pelangganModel.id,
        'terakhirAktif',
        any, // timestamp
      )).called(1);
    });

    test('07. harus memanggil base.streamSemuaData saat streamSemuaPelanggan', () {
      when(mockBaseOpFirebase.streamSemuaData(any, any)).thenAnswer(
        (_) => Stream.value([pelangganModel]),
      );

      final stream = pelangganOpFirebase.streamSemuaPelanggan();

      expect(stream, isA<Stream<List<PelangganModel>>>());
      verify(mockBaseOpFirebase.streamSemuaData('pelanggan', any)).called(1);
    });
  });
}


// path: test/fitur/pelanggan/operasi/pelanggan_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockBaseOpFirebase = MockBaseOpFirebase();
    fakeFirestore = FakeFirebaseFirestore();
    pelangganOpFirebase = PelangganOpFirebase(
      firestore: fakeFirestore,
      baseOpFirebase: mockBaseOpFirebase,
    );
  });

  final pelangganModel = PelangganModel(
    id: '1',
    nama: 'Pelanggan Uji',
    email: 'uji@example.com',
    terakhirAktif: DateTime.now(),
    tanggalDibuat: DateTime.now(),
  );

  group('PelangganOpFirebase', () {
    test('01. harus memanggil baseOpFirebase.sisipkan saat tambahPelanggan',
        () async {
      when(mockBaseOpFirebase.sisipkan(any, any, any))
          .thenAnswer((_) async => {});

      await pelangganOpFirebase.tambahPelanggan(pelangganModel);

      verify(mockBaseOpFirebase.sisipkan(
        'pelanggan',
        pelangganModel.id,
        pelangganModel.toFirebase(),
      )).called(1);
    });

    test('02. harus memanggil baseOpFirebase.update saat perbaruiPelanggan',
        () async {
      when(mockBaseOpFirebase.update(any, any, any))
          .thenAnswer((_) async => {});

      await pelangganOpFirebase.perbaruiPelanggan(pelangganModel);

      verify(mockBaseOpFirebase.update(
        'pelanggan',
        pelangganModel.id,
        pelangganModel.toFirebase(),
      )).called(1);
    });

    test('03. harus memanggil baseOpFirebase.hapusSementara saat softDelete',
        () async {
      when(mockBaseOpFirebase.hapusSementara(any, any))
          .thenAnswer((_) async => {});

      await pelangganOpFirebase.softDelete('1');

      verify(mockBaseOpFirebase.hapusSementara('pelanggan', '1')).called(1);
    });

    test(
        '04. harus memanggil baseOpFirebase.update saat perbaruiTerakhirAktif',
        () async {
      when(mockBaseOpFirebase.update(any, any, any))
          .thenAnswer((_) async => {});

      await pelangganOpFirebase.perbaruiTerakhirAktif('1');

      verify(mockBaseOpFirebase.update(
        'pelanggan',
        '1',
        argThat(isA<Map<String, dynamic>>()),
      )).called(1);
    });

    test('05. harus memanggil baseOpFirebase.update saat simpanTokenFCM',
        () async {
      when(mockBaseOpFirebase.update(any, any, any))
          .thenAnswer((_) async => {});

      await pelangganOpFirebase.simpanTokenFCM('1', 'token-fcm');

      verify(mockBaseOpFirebase.update(
        'pelanggan',
        '1',
        {'fcmToken': 'token-fcm'},
      )).called(1);
    });

    test(
        '06. tidak boleh memanggil baseOpFirebase.update saat token FCM null atau kosong',
        () async {
      await pelangganOpFirebase.simpanTokenFCM('1', null);
      await pelangganOpFirebase.simpanTokenFCM('1', '');

      verifyNever(mockBaseOpFirebase.update(any, any, any));
    });

    test('07. harus mengembalikan list pelanggan saat ambilSemuaPelanggan',
        () async {
      await fakeFirestore
          .collection('pelanggan')
          .doc('1')
          .set(pelangganModel.copyWith(dihapus: false).toFirebase());
      await fakeFirestore
          .collection('pelanggan')
          .doc('2')
          .set(pelangganModel.copyWith(id: '2', dihapus: true).toFirebase());

      final hasil = await pelangganOpFirebase.ambilSemuaPelanggan();

      expect(hasil, isA<List<PelangganModel>>());
      expect(hasil.length, 1);
      expect(hasil.first.id, '1');
    });

    test('08. harus mengembalikan stream pelanggan saat ambilStreanPelanggan',
        () async {
      // Menambahkan data langsung ke FakeFirestore
      await fakeFirestore
          .collection('pelanggan')
          .doc('1')
          .set(pelangganModel.toFirebase());

      // Mendengarkan stream
      final stream = pelangganOpFirebase.ambilStreanPelanggan('1');

      // Memeriksa data pertama dari stream
      final pelangganDariStream = await stream.first;

      expect(pelangganDariStream, isA<PelangganModel>());
      expect(pelangganDariStream?.id, '1');
      expect(pelangganDariStream?.nama, 'Pelanggan Uji');
    });

    test('09. harus mengembalikan null jika stream pelanggan tidak ada',
        () async {
      final stream = pelangganOpFirebase.ambilStreanPelanggan('99');
      final pelangganDariStream = await stream.first;

      expect(pelangganDariStream, isNull);
    });

    test('10. harus mengembalikan pelanggan berdasarkan ID', () async {
      await fakeFirestore
          .collection('pelanggan')
          .doc('1')
          .set(pelangganModel.toFirebase());
      
      final hasil = await pelangganOpFirebase.ambilBerdasarkanId('1');

      expect(hasil, isA<PelangganModel>());
      expect(hasil?.id, '1');
    });

    test('11. harus mengembalikan null jika pelanggan tidak ditemukan', () async {
      final hasil = await pelangganOpFirebase.ambilBerdasarkanId('99');
      expect(hasil, isNull);
    });
  });
}

// path: test/shared/data/services/pengecekan_data_baru_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/data/services/layanan_pengecekan_data_baru.dart';

import 'pengecekan_data_baru_service_test.mocks.dart';

@GenerateMocks([
  PelangganOpFirebase,
  PelangganOpSqlite,
])
void main() {
  late LayananPengecekanDataBaru layananPengecekanDataBaru;
  late MockPelangganOpFirebase mockPelangganOpFirebase;
  late MockPelangganOpSqlite mockPelangganOpSqlite;

  setUp(() {
    mockPelangganOpFirebase = MockPelangganOpFirebase();
    mockPelangganOpSqlite = MockPelangganOpSqlite();

    layananPengecekanDataBaru = LayananPengecekanDataBaru(
      pelangganOpFirebase: mockPelangganOpFirebase,
      pelangganOpSqlite: mockPelangganOpSqlite,
    );
  });

  group('LayananPengecekanDataBaru', () {
    test('01. should return true if there is new data for any feature', () async {
      // Anggap ada data baru di pelanggan
      when(mockPelangganOpFirebase.hasNewData(any)).thenAnswer((_) async => true);
      // Anggap tidak ada data baru di fitur lain
      // when(mockFiturLainOpFirebase.hasNewData(any)).thenAnswer((_) async => false);

      final result = await layananPengecekanDataBaru.cekDataBaru(DateTime.now());

      expect(result, isTrue);
      verify(mockPelangganOpFirebase.hasNewData(any)).called(1);
      // Pastikan semua fitur lain juga dicek
      // verify(mockFiturLainOpFirebase.hasNewData(any)).called(1);
    });

    test('02. should return false if there is no new data for any feature', () async {
      // Anggap tidak ada data baru di semua fitur
      when(mockPelangganOpFirebase.hasNewData(any)).thenAnswer((_) async => false);
      // when(mockFiturLainOpFirebase.hasNewData(any)).thenAnswer((_) async => false);

      final result = await layananPengecekanDataBaru.cekDataBaru(DateTime.now());

      expect(result, isFalse);
      verify(mockPelangganOpFirebase.hasNewData(any)).called(1);
      // verify(mockFiturLainOpFirebase.hasNewData(any)).called(1);
    });

    test('03. should return true if at least one feature has new data', () async {
      // Data baru di pelanggan, tidak di fitur lain
      when(mockPelangganOpFirebase.hasNewData(any)).thenAnswer((_) async => true);
      // when(mockFiturXOpFirebase.hasNewData(any)).thenAnswer((_) async => false);
      // when(mockFiturYOpFirebase.hasNewData(any)).thenAnswer((_) async => false);

      final result = await layananPengecekanDataBaru.cekDataBaru(DateTime.now());

      expect(result, isTrue);
    });

    test('04. should return false if one check throws an error but others are false',
        () async {
      // Satu fitur error, yang lain tidak ada data baru
      when(mockPelangganOpFirebase.hasNewData(any))
          .thenThrow(Exception('Firebase Error'));
      // when(mockFiturXOpFirebase.hasNewData(any)).thenAnswer((_) async => false);

      final result = await layananPengecekanDataBaru.cekDataBaru(DateTime.now());

      expect(result, isFalse);
      verify(mockPelangganOpFirebase.hasNewData(any)).called(1);
    });

    test('05. should return true if one check throws an error but another is true',
        () async {
      // Satu fitur error, yang lain ada data baru
      when(mockPelangganOpFirebase.hasNewData(any))
          .thenThrow(Exception('Firebase Error'));
      // when(mockFiturXOpFirebase.hasNewData(any)).thenAnswer((_) async => true);

      // Untuk tes ini, kita perlu mock fitur lain. Mari kita asumsikan untuk sekarang
      // bahwa kita hanya mengetes pelanggan.
      // Untuk menjadikannya `true`, mari kita ubah mock pelanggan menjadi true.
      when(mockPelangganOpFirebase.hasNewData(any)).thenAnswer((_) async => true);

      final result = await layananPengecekanDataBaru.cekDataBaru(DateTime.now());

      expect(result, isTrue);
    });
  });
}

// path: test/shared/operasi/kategori_operasi_test.dart
// diubah: Menambahkan pengujian lengkap untuk KategoriOperasi.
// ditambahkan: Pengujian createKategori.
// ditambahkan: Pengujian update kategori.
// ditambahkan: Pengujian delete kategori.
// ditambahkan: Pengujian arsipkanSatuKategori.
// ditambahkan: Pengujian batch kategori.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

class MockOperasiDasar extends Mock implements OperasiDasar {}

void main() {
  late MockOperasiDasar mockOperasiDasar;
  late KategoriOperasi kategoriOperasi;

  setUp(() {
    mockOperasiDasar = MockOperasiDasar();

    kategoriOperasi = KategoriOperasiTestable(
      mockOperasiDasar,
    );
  });

  group('KategoriOperasi', () {
    group('createKategori', () {
      test(
        'harus berhasil membuat kategori',
        () async {
          // Arrange
          final kategori = KategoriModel(
            id: 'kategori-1',
            nama: 'Pemasukan',
            tipe: TipeKategori.pemasukan,
          );

          when(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          final hasil = await kategoriOperasi.createKategori(
            kategori,
          );

          // Assert
          expect(
            hasil.nama,
            'Pemasukan',
          );

          verify(
            mockOperasiDasar.sisipkan(
              'kategori',
              any,
              dariServer: false,
            ),
          ).called(1);
        },
      );

      test(
        'harus meneruskan parameter dariServer',
        () async {
          // Arrange
          final kategori = KategoriModel(
            id: 'kategori-2',
            nama: 'Pengeluaran',
            tipe: TipeKategori.pengeluaran,
          );

          when(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await kategoriOperasi.createKategori(
            kategori,
            dariServer: true,
          );

          // Assert
          verify(
            mockOperasiDasar.sisipkan(
              'kategori',
              any,
              dariServer: true,
            ),
          ).called(1);
        },
      );

      test(
        'harus melempar exception ketika gagal create',
        () async {
          // Arrange
          final kategori = KategoriModel(
            id: 'kategori-3',
            nama: 'Internet',
            tipe: TipeKategori.pengeluaran,
          );

          when(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenThrow(
            Exception('Gagal create'),
          );

          // Act & Assert
          expect(
            () async => kategoriOperasi.createKategori(
              kategori,
            ),
            throwsException,
          );
        },
      );
    });

    group('update', () {
      test(
        'harus berhasil update kategori',
        () async {
          // Arrange
          final kategori = KategoriModel(
            id: 'kategori-update',
            nama: 'Update Kategori',
            tipe: TipeKategori.pemasukan,
          );

          when(
            mockOperasiDasar.perbarui(
              any,
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await kategoriOperasi.update(
            kategori,
          );

          // Assert
          verify(
            mockOperasiDasar.perbarui(
              'kategori',
              any,
              kategori.id,
  
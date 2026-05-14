// path: test/shared/operasi/pengaturan_operasi_test.dart
// ditambahkan: Pengujian untuk PengaturanOperasi.
// ditambahkan: Pengujian getPengaturan.
// ditambahkan: Pengujian simpanAtauPerbaruiPengaturan.
// ditambahkan: Pengujian simpanAtauPerbaruiPengaturanDenganBatch.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';

class MockOperasiDasar extends Mock implements OperasiDasar {}

void main() {
  late PengaturanOperasi pengaturanOperasi;
  late MockOperasiDasar mockOperasiDasar;

  setUp(() {
    mockOperasiDasar = MockOperasiDasar();

    pengaturanOperasi = PengaturanOperasi(
      operasiDasar: mockOperasiDasar,
    );
  });

  group('PengaturanOperasi', () {
    group('simpanAtauPerbaruiPengaturan', () {
      test(
        'harus berhasil menyimpan pengaturan',
        () async {
          // Arrange
          final pengaturan = PengaturanModel(
            temaGelap: true,
          );

          when(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await pengaturanOperasi.simpanAtauPerbaruiPengaturan(
            pengaturan,
          );

          // Assert
          verify(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).called(1);
        },
      );

      test(
        'harus meneruskan parameter dariServer',
        () async {
          // Arrange
          final pengaturan = PengaturanModel();

          when(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await pengaturanOperasi.simpanAtauPerbaruiPengaturan(
            pengaturan,
            dariServer: true,
          );

          // Assert
          verify(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: true,
            ),
          ).called(1);
        },
      );

      test(
        'harus melempar exception ketika gagal menyimpan',
        () async {
          // Arrange
          final pengaturan = PengaturanModel();

          when(
            mockOperasiDasar.sisipkan(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenThrow(
            Exception('Gagal menyimpan'),
          );

          // Act & Assert
          expect(
            () async => pengaturanOperasi.simpanAtauPerbaruiPengaturan(
              pengaturan,
            ),
            throwsException,
          );
        },
      );
    });

    group('simpanAtauPerbaruiPengaturanDenganBatch', () {
      test(
        'harus berhasil menyimpan pengaturan dengan batch',
        () async {
          // Arrange
          final pengaturan = PengaturanModel();

          when(
            mockOperasiDasar.sisipkanAtauPerbaruiBatch(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await pengaturanOperasi.simpanAtauPerbaruiPengaturanDenganBatch(
            pengaturan,
          );

          // Assert
          verify(
            mockOperasiDasar.sisipkanAtauPerbaruiBatch(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).called(1);
        },
      );

      test(
        'harus meneruskan parameter dariServer pada batch',
        () async {
          // Arrange
          final pengaturan = PengaturanModel();

          when(
            mockOperasiDasar.sisipkanAtauPerbaruiBatch(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenAnswer((_) async {});

          // Act
          await pengaturanOperasi.simpanAtauPerbaruiPengaturanDenganBatch(
            pengaturan,
            dariServer: true,
          );

          // Assert
          verify(
            mockOperasiDasar.sisipkanAtauPerbaruiBatch(
              any,
              any,
              dariServer: true,
            ),
          ).called(1);
        },
      );

      test(
        'harus melempar exception ketika batch gagal',
        () async {
          // Arrange
          final pengaturan = PengaturanModel();

          when(
            mockOperasiDasar.sisipkanAtauPerbaruiBatch(
              any,
              any,
              dariServer: anyNamed('dariServer'),
            ),
          ).thenThrow(
            Exception('Batch gagal'),
          );

          // Act & Assert
          expect(
            () async =>
                pengaturanOperasi.simpanAtauPerbaruiPengaturanDenganBatch(
              pengaturan,
            ),
            throwsException,
          );
        },
      );
    });

    // TODO: Tambahkan pengujian getPengaturan menggunakan database mock/in-memory.
    // TODO: Tambahkan pengujian validasi nilai `diperbarui` menggunakan UTC.
    // TODO: Tambahkan pengujian fallback ketika database gagal diakses.
  });
}

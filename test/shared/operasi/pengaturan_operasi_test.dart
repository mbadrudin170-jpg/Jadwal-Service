// path: test/shared/operasi/pengaturan_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';

import 'pengaturan_operasi_test.mocks.dart';

@GenerateMocks([OperasiDasar])
void main() {
  late PengaturanOperasi pengaturanOperasi;
  late MockOperasiDasar mockOperasiDasar;

  setUp(() {
    mockOperasiDasar = MockOperasiDasar();
    pengaturanOperasi = PengaturanOperasi(operasiDasar: mockOperasiDasar);
  });

  // Data dummy yang sesuai dengan properti model PengaturanModel
  final tPengaturanModel = PengaturanModel(
    intervalSinkronisasiOtomatis: 12,
    hapusOtomatisDataArsip: 60,
    modePemeliharaan: true,
    infoPemeliharaan: 'Dalam perbaikan',
    diperbarui: DateTime.now(),
  );

  group('simpanAtauPerbaruiPengaturan', () {
    test('should call sisipkan on OperasiDasar with correct data', () async {
      when(mockOperasiDasar.sisipkan(any, any))
          .thenAnswer((final _) async => 1);

      await pengaturanOperasi.simpanAtauPerbaruiPengaturan(tPengaturanModel);

      verify(
        mockOperasiDasar.sisipkan(
          'pengaturan',
          any,
        ),
      ).called(1);
    });
  });

  group('simpanAtauPerbaruiPengaturanDenganBatch', () {
    test('should call sisipkanAtauPerbaruiBatch on OperasiDasar', () async {
      when(mockOperasiDasar.sisipkanAtauPerbaruiBatch(any, any))
          .thenAnswer((final _) async => {});

      await pengaturanOperasi
          .simpanAtauPerbaruiPengaturanDenganBatch(tPengaturanModel);

      verify(
        mockOperasiDasar.sisipkanAtauPerbaruiBatch(
          'pengaturan',
          any,
        ),
      ).called(1);
    });
  });
}

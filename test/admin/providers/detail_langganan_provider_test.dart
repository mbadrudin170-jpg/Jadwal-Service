'''// path: test/admin/providers/detail_langganan_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

import 'detail_langganan_provider_test.mocks.dart';

@GenerateMocks([
  PelangganOpSqlite,
  PaketOpSqlite,
  TransaksiOpSqlite,
])
void main() {
  late MockPelangganOpSqlite mockPelangganOp;
  late MockPaketOpSqlite mockPaketOp;
  late MockTransaksiOpSqlite mockTransaksiOp;
  late ProviderContainer container;

  final transaksi = TransaksiModel(
    id: 'trx1',
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
    tanggal: DateTime.now(),
    deskripsi: 'test',
    idDompet: 'd1',
    idKategori: 'k1',
    jumlah: 100,
    tanggalBerakhir: DateTime.now(),
    tanggalMulai: DateTime.now(),
    tipe: TipeTransaksi.expense,
  );

  setUp(() {
    mockPelangganOp = MockPelangganOpSqlite();
    mockPaketOp = MockPaketOpSqlite();
    mockTransaksiOp = MockTransaksiOpSqlite();

    container = ProviderContainer(
      overrides: [
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOp),
        paketOpSqliteProvider.overrideWithValue(mockPaketOp),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOp),
      ],
    );
  });

  group('hapusLanggananProvider', () {
    test(
      '01. harus memanggil softDelete pada semua operasi yang relevan',
      () async {
        when(mockTransaksiOp.softDelete(transaksi.id))
            .thenAnswer((_) async => 1);

        final result = await container.read(
          hapusLanggananProvider(transaksi).future,
        );

        expect(result, 1);

        verify(mockTransaksiOp.softDelete(transaksi.id))
            .called(1);
      },
    );

    test('02. harus melempar exception jika salah satu operasi gagal', () async {
      final exception = Exception('Gagal hapus');
      when(mockTransaksiOp.softDelete(transaksi.id))
          .thenThrow(exception);

      await expectLater(
        container.read(hapusLanggananProvider(transaksi).future),
        throwsA(exception),
      );
    });
  });
}
''
// path: test/admin/providers/detail_langganan_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';

import 'detail_langganan_provider_test.mocks.dart';

@GenerateMocks([
  TransaksiOpSqlite,
  PelangganOpSqlite,
  PaketOpSqlite,
])
void main() {
  group('ambilDetailLangganan', () {
    late MockTransaksiOpSqlite mockTransaksiOpSqlite;
    late MockPelangganOpSqlite mockPelangganOpSqlite;
    late MockPaketOpSqlite mockPaketOpSqlite;
    late ProviderContainer container;

    setUp(() {
      mockTransaksiOpSqlite = MockTransaksiOpSqlite();
      mockPelangganOpSqlite = MockPelangganOpSqlite();
      mockPaketOpSqlite = MockPaketOpSqlite();

      container = ProviderContainer(
        overrides: [
          transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpSqlite),
          pelangganOpSqliteProvider.overrideWithValue(mockPelangganOpSqlite),
          paketOpSqliteProvider.overrideWithValue(mockPaketOpSqlite),
        ],
      );
    });

    const idTransaksi = 'trx1';
    final transaksi = TransaksiModel(
      id: idTransaksi,
      idPelanggan: 'cust1',
      idPaket: 'pkg1',
      tanggal: DateTime.now(),
      deskripsi: 'deskripsi',
      jumlah: 50000,
      tipe: TipeTransaksi.income,
      idDompet: 'dompet1',
      idKategori: 'kategori1',
      statusPembayaran: StatusPembayaran.paid,
    );

    final pelanggan = PelangganModel(
      id: 'cust1',
      nama: 'Pelanggan 1',
      alamat: 'Alamat 1',
      telepon: '08123',
      macAddress: 'mac1',
      kataSandi: 'pass1',
    );

    final paket = PaketModel(
      id: 'pkg1',
      nama: 'Paket 1',
      harga: 50000,
      durasi: 1,
      tipe: TipeDurasiPaket.months,
    );

    test('01. should return DetailLanggananState when all data is available',
        () async {
      when(mockTransaksiOpSqlite.ambilBerdasarkanId(idTransaksi))
          .thenAnswer((_) async => transaksi);
      when(mockPelangganOpSqlite.ambilBerdasarkanId('cust1'))
          .thenAnswer((_) async => pelanggan);
      when(mockPaketOpSqlite.ambilBerdasarkanId('pkg1'))
          .thenAnswer((_) async => paket);

      final result = await container.read(ambilDetailLanggananProvider(idTransaksi).future);

      expect(result, isA<DetailLanggananState>());
      expect(result!.transaction, transaksi);
      expect(result.customer, pelanggan);
      expect(result.package, paket);
    });

    test('02. should return null when transaction is not found', () async {
      when(mockTransaksiOpSqlite.ambilBerdasarkanId(idTransaksi))
          .thenAnswer((_) async => null);

      try {
        await container.read(ambilDetailLanggananProvider(idTransaksi).future);
      } catch (e) {
        expect(e, isA<Exception>());
      }

      verifyNever(mockPelangganOpSqlite.ambilBerdasarkanId(any));
      verifyNever(mockPaketOpSqlite.ambilBerdasarkanId(any));
    });

    test('03. should return state with null customer and package when ids are null',
        () async {
      final transaksiTanpaRelasi = transaksi.copyWith(idPelanggan: null, idPaket: null);
      when(mockTransaksiOpSqlite.ambilBerdasarkanId(idTransaksi))
          .thenAnswer((_) async => transaksiTanpaRelasi);

      final result = await container.read(ambilDetailLanggananProvider(idTransaksi).future);

      expect(result, isA<DetailLanggananState>());
      expect(result!.transaction, transaksiTanpaRelasi);
      expect(result.customer, isNull);
      expect(result.package, isNull);

      verifyNever(mockPelangganOpSqlite.ambilBerdasarkanId(any));
      verifyNever(mockPaketOpSqlite.ambilBerdasarkanId(any));
    });
  });
}
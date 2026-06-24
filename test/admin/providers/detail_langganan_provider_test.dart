// path: test/admin/providers/detail_langganan_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

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
      tanggalMulai: DateTime.now(),
      tanggalBerakhir: DateTime.now().add(const Duration(days: 30)),
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

    test('01. harus mengembalikan DetailLanggananState ketika semua data tersedia',
        () async {
      when(mockTransaksiOpSqlite.ambilBerdasarkanId(idTransaksi))
          .thenAnswer((_) async => transaksi);
      when(mockPelangganOpSqlite.ambilBerdasarkanId('cust1'))
          .thenAnswer((_) async => pelanggan);
      when(mockPaketOpSqlite.ambilBerdasarkanId('pkg1'))
          .thenAnswer((_) async => paket);

      final result = await container.read(ambilDetailLanggananProvider(idTransaksi).future);

      expect(result, isA<DetailLanggananState>());
      expect(result!.transaksi, transaksi);
      expect(result.pelanggan, pelanggan);
      expect(result.paket, paket);
    });

    test('02. harus mengembalikan null ketika transaksi tidak ditemukan', () async {
      when(mockTransaksiOpSqlite.ambilBerdasarkanId(idTransaksi))
          .thenAnswer((_) async => null);

      final result = await container.read(ambilDetailLanggananProvider(idTransaksi).future);
      expect(result, isNull);

      verifyNever(mockPelangganOpSqlite.ambilBerdasarkanId(any));
      verifyNever(mockPaketOpSqlite.ambilBerdasarkanId(any));
    });

    test('03. harus mengembalikan state dengan pelanggan dan paket null ketika id-nya null',
        () async {
      final transaksiTanpaRelasi = transaksi.copyWith(idPelanggan: null, idPaket: null);
      when(mockTransaksiOpSqlite.ambilBerdasarkanId(idTransaksi))
          .thenAnswer((_) async => transaksiTanpaRelasi);

      final result = await container.read(ambilDetailLanggananProvider(idTransaksi).future);

      expect(result, isA<DetailLanggananState>());
      expect(result!.transaksi, transaksiTanpaRelasi);
      expect(result.pelanggan, isNull);
      expect(result.paket, isNull);

      verifyNever(mockPelangganOpSqlite.ambilBerdasarkanId(any));
      verifyNever(mockPaketOpSqlite.ambilBerdasarkanId(any));
    });
  });
}
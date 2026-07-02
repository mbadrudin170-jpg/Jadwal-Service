// path: test/admin/providers/detail_langganan_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
// PERBAIKAN: Tambahkan import yang hilang
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/riwayat_aktivasi/provider/detail_langganan_provider.dart';
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

  tearDown(() {
    container.dispose();
  });

  group('ambilDetailLanggananProvider', () {
    test('01. harus mengembalikan DetailLanggananState jika transaksi ditemukan', () async {
      when(mockTransaksiOp.ambilBerdasarkanId('trx1'))
          .thenAnswer((_) async => transaksi);
      when(mockPelangganOp.ambilBerdasarkanId('cust1'))
          .thenAnswer((_) async => null);
      when(mockPaketOp.ambilBerdasarkanId('pkg1'))
          .thenAnswer((_) async => null);

      final result = await container.read(
        ambilDetailLanggananProvider('trx1').future,
      );

      expect(result, isNotNull);
      expect(result?.transaksi?.id, 'trx1');
    });

    test('02. harus mengembalikan null jika transaksi tidak ditemukan', () async {
      when(mockTransaksiOp.ambilBerdasarkanId('trx99'))
          .thenAnswer((_) async => null);

      final result = await container.read(
        ambilDetailLanggananProvider('trx99').future,
      );

      expect(result, isNull);
    });

    test('03. harus mengembalikan pelanggan dan paket jika ada', () async {
      final mockPelanggan = PelangganModel(
        id: 'cust1',
        nama: 'Pelanggan Test',
        telepon: '08123456789',
        alamat: 'Jl. Test',
        kataSandi: 'password',
        macAddress: '00:00:00:00:00:00',
      );
      final mockPaket = PaketModel(
        id: 'pkg1',
        nama: 'Paket Test',
        harga: 100000,
        durasi: 30,
        tipe: TipeDurasiPaket.days,
      );

      when(mockTransaksiOp.ambilBerdasarkanId('trx1'))
          .thenAnswer((_) async => transaksi);
      when(mockPelangganOp.ambilBerdasarkanId('cust1'))
          .thenAnswer((_) async => mockPelanggan);
      when(mockPaketOp.ambilBerdasarkanId('pkg1'))
          .thenAnswer((_) async => mockPaket);

      final result = await container.read(
        ambilDetailLanggananProvider('trx1').future,
      );

      expect(result, isNotNull);
      expect(result?.transaksi?.id, 'trx1');
      expect(result?.pelanggan?.id, 'cust1');
      expect(result?.paket?.id, 'pkg1');
    });
  });
}
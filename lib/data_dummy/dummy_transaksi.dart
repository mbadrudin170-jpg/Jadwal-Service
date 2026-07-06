// path: lib/data_dummy/dummy_transaksi.dart

import 'package:wifi/data_dummy/dummy_dompet.dart';
import 'package:wifi/data_dummy/dummy_kategori.dart';
import 'package:wifi/data_dummy/dummy_paket.dart';
import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

/// Data dummy untuk transaksi

const String idTransaksi1 = 'trans-001';
const String idTransaksi2 = 'trans-002';
const String idTransaksi3 = 'trans-003';
const String idTransaksi4 = 'trans-004';
const String idTransaksi5 = 'trans-005';
const String idTransaksi6 = 'trans-006';
const String idTransaksi7 = 'trans-007';
const String idTransaksi8 = 'trans-008';
const String idTransaksi9 = 'trans-009';
const String idTransaksi10 = 'trans-010';
const String idTransaksi11 = 'trans-011';
const String idTransaksi12 = 'trans-012';

List<TransaksiModel> get daftarTransaksi {
  final now = DateTime.now();
  final satuHariLalu = now.subtract(const Duration(days: 1));
  final tigaHariLalu = now.subtract(const Duration(days: 3));
  final limaHariLalu = now.subtract(const Duration(days: 5));
  final tujuhHariLalu = now.subtract(const Duration(days: 7));
  final sepuluhHariLalu = now.subtract(const Duration(days: 10));
  final empatBelasHariLalu = now.subtract(const Duration(days: 14));
  final duaPuluhHariLalu = now.subtract(const Duration(days: 20));
  final tigaPuluhHariLalu = now.subtract(const Duration(days: 30));

  return [
    // ============================================================
    // 1. Transaksi Pemasukan - Gaji Budi
    // ============================================================
    TransaksiModel(
      id: idTransaksi1,
      tanggal: now,
      deskripsi: 'Gaji Bulan Juni',
      jumlah: 5000000,
      tipe: TipeTransaksi.income,
      idDompet: DummyDompet.idDompetUtama,
      idKategori: DummyKategori.idKategoriPemasukan,
      idSubKategori: DummyKategori.idSubKategoriGaji,
      idPelanggan: idBudi,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),

    // ============================================================
    // 2. Transaksi Pemasukan - Bonus Budi
    // ============================================================
    TransaksiModel(
      id: idTransaksi2,
      tanggal: satuHariLalu,
      deskripsi: 'Bonus Kinerja',
      jumlah: 1000000,
      tipe: TipeTransaksi.income,
      idDompet: DummyDompet.idDompetUtama,
      idKategori: DummyKategori.idKategoriPemasukan,
      idSubKategori: DummyKategori.idSubKategoriBonus,
      idPelanggan: idBudi,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),

    // ============================================================
    // 3. Transaksi Pengeluaran - Makanan Budi
    // ============================================================
    TransaksiModel(
      id: idTransaksi3,
      tanggal: tigaHariLalu,
      deskripsi: 'Belanja Makanan',
      jumlah: 500000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetUtama,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriMakanan,
      idPelanggan: idBudi,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),

    // ============================================================
    // 4. Transaksi Aktivasi Paket Hemat - Budi
    // ============================================================
    TransaksiModel(
      id: idTransaksi4,
      tanggal: tigaHariLalu,
      deskripsi: 'Aktivasi Paket Hemat',
      jumlah: 150000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetUtama,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriInternet,
      idPelanggan: idBudi,
      idPaket: DummyPaket.idPaketHemat,
      poinDidapat: 50,
      durasiPaket: 30,
      tipeDurasiPaket: TipeDurasiPaket.days,
      tanggalMulai: tigaHariLalu,
      tanggalBerakhir: tigaHariLalu.add(const Duration(days: 30)),
      statusAktivasi: true,
    ),

    // ============================================================
    // 5. Transaksi Aktivasi Paket Bisnis - Siti
    // ============================================================
    TransaksiModel(
      id: idTransaksi5,
      tanggal: limaHariLalu,
      deskripsi: 'Aktivasi Paket Bisnis',
      jumlah: 250000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetCadangan,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriInternet,
      idPelanggan: idSiti,
      idPaket: DummyPaket.idPaketBisnis,
      poinDidapat: 100,
      durasiPaket: 30,
      tipeDurasiPaket: TipeDurasiPaket.days,
      tanggalMulai: limaHariLalu,
      tanggalBerakhir: limaHariLalu.add(const Duration(days: 30)),
      statusAktivasi: true,
    ),

    // ============================================================
    // 6. Transaksi Aktivasi Paket Premium - Agus (Belum Lunas)
    // ============================================================
    TransaksiModel(
      id: idTransaksi6,
      tanggal: tujuhHariLalu,
      deskripsi: 'Aktivasi Paket Premium',
      jumlah: 350000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetBisnis,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriInternet,
      idPelanggan: idAgus,
      idPaket: DummyPaket.idPaketPremium,
      statusPembayaran: StatusPembayaran.unpaid,
      durasiPaket: 30,
      tipeDurasiPaket: TipeDurasiPaket.days,
      tanggalMulai: tujuhHariLalu,
      tanggalBerakhir: tujuhHariLalu.add(const Duration(days: 30)),
      statusAktivasi: true,
    ),

    // ============================================================
    // 7. Transaksi Aktivasi Paket Gamer - Dewi
    // ============================================================
    TransaksiModel(
      id: idTransaksi7,
      tanggal: sepuluhHariLalu,
      deskripsi: 'Aktivasi Paket Gamer',
      jumlah: 500000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetInvestasi,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriInternet,
      idPelanggan: idDewi,
      idPaket: DummyPaket.idPaketGamer,
      poinDidapat: 200,
      durasiPaket: 30,
      tipeDurasiPaket: TipeDurasiPaket.days,
      tanggalMulai: sepuluhHariLalu,
      tanggalBerakhir: sepuluhHariLalu.add(const Duration(days: 30)),
      statusAktivasi: true,
    ),

    // ============================================================
    // 8. Transaksi Aktivasi Paket Edukasi - Andi
    // ============================================================
    TransaksiModel(
      id: idTransaksi8,
      tanggal: empatBelasHariLalu,
      deskripsi: 'Aktivasi Paket Edukasi',
      jumlah: 100000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetUtama,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriInternet,
      idPelanggan: idAndi,
      idPaket: DummyPaket.idPaketEdukasi,
      poinDidapat: 30,
      durasiPaket: 15,
      tipeDurasiPaket: TipeDurasiPaket.days,
      tanggalMulai: empatBelasHariLalu,
      tanggalBerakhir: empatBelasHariLalu.add(const Duration(days: 15)),
      statusAktivasi: true,
    ),

    // ============================================================
    // 9. Transaksi Aktivasi Paket Ultimate - Joko
    // ============================================================
    TransaksiModel(
      id: idTransaksi9,
      tanggal: duaPuluhHariLalu,
      deskripsi: 'Aktivasi Paket Ultimate',
      jumlah: 750000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetBisnis,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriInternet,
      idPelanggan: idJoko,
      idPaket: DummyPaket.idPaketUltimate,
      poinDidapat: 300,
      durasiPaket: 60,
      tipeDurasiPaket: TipeDurasiPaket.days,
      tanggalMulai: duaPuluhHariLalu,
      tanggalBerakhir: duaPuluhHariLalu.add(const Duration(days: 60)),
      statusAktivasi: true,
    ),

    // ============================================================
    // 10. Transaksi Pengeluaran - Transportasi Rina
    // ============================================================
    TransaksiModel(
      id: idTransaksi10,
      tanggal: tigaPuluhHariLalu,
      deskripsi: 'Transportasi Bulanan',
      jumlah: 300000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetCadangan,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriTransport,
      idPelanggan: idRina,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),

    // ============================================================
    // 11. Transaksi Pengeluaran - Listrik Maya
    // ============================================================
    TransaksiModel(
      id: idTransaksi11,
      tanggal: duaPuluhHariLalu,
      deskripsi: 'Pembayaran Listrik',
      jumlah: 200000,
      tipe: TipeTransaksi.expense,
      idDompet: DummyDompet.idDompetUtama,
      idKategori: DummyKategori.idKategoriPengeluaran,
      idSubKategori: DummyKategori.idSubKategoriListrik,
      idPelanggan: idMaya,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),

    // ============================================================
    // 12. Transaksi Transfer - Rudi ke Lisa
    // ============================================================
    TransaksiModel(
      id: idTransaksi12,
      tanggal: satuHariLalu,
      deskripsi: 'Transfer ke Lisa',
      jumlah: 500000,
      tipe: TipeTransaksi.transfer,
      idDompet: DummyDompet.idDompetUtama,
      idDompetTujuan: DummyDompet.idDompetCadangan,
      idKategori: DummyKategori.idKategoriTransfer,
      idPelanggan: idRudi,
      idPaket: null,
      tanggalMulai: null,
      tanggalBerakhir: null,
    ),
  ];
}

/// Mendapatkan transaksi berdasarkan ID
TransaksiModel? getTransaksiById(String id) {
  try {
    return daftarTransaksi.firstWhere((t) => t.id == id);
  } catch (e) {
    return null;
  }
}

/// Mendapatkan transaksi berdasarkan ID pelanggan
List<TransaksiModel> getTransaksiByCustomerId(String idPelanggan) {
  return daftarTransaksi.where((t) => t.idPelanggan == idPelanggan).toList();
}

/// Mendapatkan transaksi berdasarkan tipe
List<TransaksiModel> getTransaksiByTipe(TipeTransaksi tipe) {
  return daftarTransaksi.where((t) => t.tipe == tipe).toList();
}

/// Mendapatkan transaksi aktivasi paket
List<TransaksiModel> getTransaksiAktivasi() {
  return daftarTransaksi.where((t) => t.statusAktivasi == true).toList();
}

/// Mendapatkan transaksi dengan poin
List<TransaksiModel> getTransaksiDenganPoin() {
  return daftarTransaksi
      .where((t) => t.poinDidapat > 0 || t.poinDigunakan > 0)
      .toList();
}

/// Mendapatkan total pemasukan
double getTotalPemasukan() {
  return daftarTransaksi
      .where((t) => t.tipe == TipeTransaksi.income)
      .fold<double>(0, (sum, t) => sum + t.jumlah);
}

/// Mendapatkan total pengeluaran
double getTotalPengeluaran() {
  return daftarTransaksi
      .where((t) => t.tipe == TipeTransaksi.expense)
      .fold<double>(0, (sum, t) => sum + t.jumlah);
}

/// Mendapatkan total poin per pelanggan
Map<String, int> getTotalPoinPerPelanggan() {
  final poinMap = <String, int>{};
  for (final t in daftarTransaksi) {
    if (t.idPelanggan != null && t.idPelanggan!.isNotEmpty) {
      final id = t.idPelanggan!;
      poinMap[id] = (poinMap[id] ?? 0) + t.poinDidapat - t.poinDigunakan;
    }
  }
  return poinMap;
}
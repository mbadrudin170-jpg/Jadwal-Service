// path: lib/data_dummy/dummy_sub_kategori.dart

import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/data_dummy/dummy_kategori.dart';

/// Data dummy untuk sub-kategori
class DummySubKategori {
  // ID Sub-Kategori - Pemasukan
  static const String idSubGaji = 'sub-gaji-id';
  static const String idSubBonus = 'sub-bonus-id';
  static const String idSubKomisi = 'sub-komisi-id';
  static const String idSubDividen = 'sub-dividen-id';
  static const String idSubSewa = 'sub-sewa-id';
  static const String idSubHadiah = 'sub-hadiah-id';

  // ID Sub-Kategori - Pengeluaran
  static const String idSubMakanan = 'sub-makanan-id';
  static const String idSubTransport = 'sub-transport-id';
  static const String idSubInternet = 'sub-internet-id';
  static const String idSubListrik = 'sub-listrik-id';
  static const String idSubAir = 'sub-air-id';
  static const String idSubGas = 'sub-gas-id';
  static const String idSubPulsa = 'sub-pulsa-id';
  static const String idSubKesehatan = 'sub-kesehatan-id';
  static const String idSubPendidikan = 'sub-pendidikan-id';
  static const String idSubHiburan = 'sub-hiburan-id';
  static const String idSubBelanja = 'sub-belanja-id';
  static const String idSubPerawatan = 'sub-perawatan-id';
  static const String idSubAsuransi = 'sub-asuransi-id';
  static const String idSubCicilan = 'sub-cicilan-id';
  static const String idSubDonasi = 'sub-donasi-id';

  /// Daftar semua sub-kategori
  static List<SubKategoriModel> get daftarSubKategori => [
    // ============================================================
    // SUB-KATEGORI PEMASUKAN (Income)
    // ============================================================
    const SubKategoriModel(
      id: idSubGaji,
      nama: 'Gaji',
      idKategori: DummyKategori.idKategoriPemasukan,
    ),
    const SubKategoriModel(
      id: idSubBonus,
      nama: 'Bonus',
      idKategori: DummyKategori.idKategoriPemasukan,
    ),
    const SubKategoriModel(
      id: idSubKomisi,
      nama: 'Komisi',
      idKategori: DummyKategori.idKategoriPemasukan,
    ),
    const SubKategoriModel(
      id: idSubDividen,
      nama: 'Dividen',
      idKategori: DummyKategori.idKategoriPemasukan,
    ),
    const SubKategoriModel(
      id: idSubSewa,
      nama: 'Sewa',
      idKategori: DummyKategori.idKategoriPemasukan,
    ),
    const SubKategoriModel(
      id: idSubHadiah,
      nama: 'Hadiah',
      idKategori: DummyKategori.idKategoriPemasukan,
    ),

    // ============================================================
    // SUB-KATEGORI PENGELUARAN (Expense)
    // ============================================================
    const SubKategoriModel(
      id: idSubMakanan,
      nama: 'Makanan',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubTransport,
      nama: 'Transportasi',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubInternet,
      nama: 'Internet',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubListrik,
      nama: 'Listrik',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubAir,
      nama: 'Air',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubGas,
      nama: 'Gas',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubPulsa,
      nama: 'Pulsa',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubKesehatan,
      nama: 'Kesehatan',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubPendidikan,
      nama: 'Pendidikan',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubHiburan,
      nama: 'Hiburan',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubBelanja,
      nama: 'Belanja',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubPerawatan,
      nama: 'Perawatan',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubAsuransi,
      nama: 'Asuransi',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubCicilan,
      nama: 'Cicilan',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
    const SubKategoriModel(
      id: idSubDonasi,
      nama: 'Donasi',
      idKategori: DummyKategori.idKategoriPengeluaran,
    ),
  ];

  /// Mendapatkan sub-kategori berdasarkan ID
  static SubKategoriModel? getById(String id) {
    try {
      return daftarSubKategori.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan sub-kategori berdasarkan ID kategori
  static List<SubKategoriModel> getByCategoryId(String idKategori) {
    return daftarSubKategori.where((s) => s.idKategori == idKategori).toList();
  }

  /// Mendapatkan sub-kategori berdasarkan nama (case-insensitive)
  static List<SubKategoriModel> getByName(String nama) {
    return daftarSubKategori
        .where((s) => s.nama.toLowerCase().contains(nama.toLowerCase()))
        .toList();
  }

  /// Mendapatkan sub-kategori pemasukan
  static List<SubKategoriModel> getSubKategoriPemasukan() {
    return daftarSubKategori
        .where((s) => s.idKategori == DummyKategori.idKategoriPemasukan)
        .toList();
  }

  /// Mendapatkan sub-kategori pengeluaran
  static List<SubKategoriModel> getSubKategoriPengeluaran() {
    return daftarSubKategori
        .where((s) => s.idKategori == DummyKategori.idKategoriPengeluaran)
        .toList();
  }

  /// Mendapatkan sub-kategori berdasarkan tipe kategori (income/expense)
  static List<SubKategoriModel> getByTipeKategori(String tipe) {
    if (tipe == 'income') {
      return getSubKategoriPemasukan();
    } else if (tipe == 'expense') {
      return getSubKategoriPengeluaran();
    }
    return [];
  }
}

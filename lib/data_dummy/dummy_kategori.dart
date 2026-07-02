// path: lib/data_dummy/dummy_kategori.dart

import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';

/// Data dummy untuk kategori dan sub-kategori
class DummyKategori {
  // ID Kategori
  static const String idKategoriPemasukan = 'kategori-pemasukan-id';
  static const String idKategoriPengeluaran = 'kategori-pengeluaran-id';
  static const String idKategoriTransfer = 'kategori-transfer-id';
  static const String idKategoriLainnya = 'kategori-lainnya-id';

  // ID Sub-Kategori
  static const String idSubKategoriGaji = 'sub-gaji-id';
  static const String idSubKategoriBonus = 'sub-bonus-id';
  static const String idSubKategoriMakanan = 'sub-makanan-id';
  static const String idSubKategoriTransport = 'sub-transport-id';
  static const String idSubKategoriInternet = 'sub-internet-id';
  static const String idSubKategoriListrik = 'sub-listrik-id';
  static const String idSubKategoriAir = 'sub-air-id';

  static List<KategoriModel> get daftarKategori => [
    // Kategori Pemasukan
    const KategoriModel(
      id: idKategoriPemasukan,
      nama: 'Pemasukan',
      tipe: TipeKategori.income,
      idSubKategori: [
        SubKategoriModel(
          id: idSubKategoriGaji,
          nama: 'Gaji',
          idKategori: idKategoriPemasukan,
        ),
        SubKategoriModel(
          id: idSubKategoriBonus,
          nama: 'Bonus',
          idKategori: idKategoriPemasukan,
        ),
      ],
    ),
    // Kategori Pengeluaran
    const KategoriModel(
      id: idKategoriPengeluaran,
      nama: 'Pengeluaran',
      tipe: TipeKategori.expense,
      idSubKategori: [
        SubKategoriModel(
          id: idSubKategoriMakanan,
          nama: 'Makanan',
          idKategori: idKategoriPengeluaran,
        ),
        SubKategoriModel(
          id: idSubKategoriTransport,
          nama: 'Transportasi',
          idKategori: idKategoriPengeluaran,
        ),
        SubKategoriModel(
          id: idSubKategoriInternet,
          nama: 'Internet',
          idKategori: idKategoriPengeluaran,
        ),
        SubKategoriModel(
          id: idSubKategoriListrik,
          nama: 'Listrik',
          idKategori: idKategoriPengeluaran,
        ),
        SubKategoriModel(
          id: idSubKategoriAir,
          nama: 'Air',
          idKategori: idKategoriPengeluaran,
        ),
      ],
    ),
    // Kategori Transfer
    const KategoriModel(
      id: idKategoriTransfer,
      nama: 'Transfer',
      tipe: TipeKategori.transfer,
    ),
    // Kategori Lainnya
    const KategoriModel(
      id: idKategoriLainnya,
      nama: 'Lainnya',
      tipe: TipeKategori.expense,
    ),
  ];

  static KategoriModel? getById(String id) {
    try {
      return daftarKategori.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<KategoriModel> getByTipe(TipeKategori tipe) {
    return daftarKategori.where((k) => k.tipe == tipe).toList();
  }

  static SubKategoriModel? getSubKategoriById(String id) {
    for (final kategori in daftarKategori) {
      try {
        return kategori.idSubKategori.firstWhere((s) => s.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}
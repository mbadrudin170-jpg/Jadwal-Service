// path: lib/data_dummy/dummy_paket.dart

import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';

/// Data dummy untuk paket
class DummyPaket {
  static const String idPaketHemat = 'paket-hemat-id';
  static const String idPaketBisnis = 'paket-bisnis-id';
  static const String idPaketPremium = 'paket-premium-id';
  static const String idPaketGamer = 'paket-gamer-id';
  static const String idPaketEdukasi = 'paket-edukasi-id';
  static const String idPaketUltimate = 'paket-ultimate-id';

  static List<PaketModel> get daftarPaket => [
    const PaketModel(
      id: idPaketHemat,
      nama: 'Paket Hemat',
      harga: 150000,
      durasi: 30,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 50,
      poinPenukaran: 100,
      statusPublik: true,
    ),
    const PaketModel(
      id: idPaketBisnis,
      nama: 'Paket Bisnis',
      harga: 250000,
      durasi: 30,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 100,
      poinPenukaran: 200,
      statusPublik: true,
    ),
    const PaketModel(
      id: idPaketPremium,
      nama: 'Paket Premium',
      harga: 350000,
      durasi: 30,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 150,
      poinPenukaran: 300,
      statusPublik: true,
    ),
    const PaketModel(
      id: idPaketGamer,
      nama: 'Paket Gamer',
      harga: 500000,
      durasi: 30,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 200,
      poinPenukaran: 400,
      statusPublik: true,
    ),
    const PaketModel(
      id: idPaketEdukasi,
      nama: 'Paket Edukasi',
      harga: 100000,
      durasi: 15,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 30,
      poinPenukaran: 60,
      statusPublik: true,
    ),
    const PaketModel(
      id: idPaketUltimate,
      nama: 'Paket Ultimate',
      harga: 750000,
      durasi: 60,
      tipe: TipeDurasiPaket.days,
      poinHadiah: 300,
      poinPenukaran: 500,
      statusPublik: true,
    ),
  ];

  static PaketModel? getById(String id) {
    try {
      return daftarPaket.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<PaketModel> getByPriceRange(int min, int max) {
    return daftarPaket.where((p) => p.harga >= min && p.harga <= max).toList();
  }

  static List<PaketModel> getPublicPackages() {
    return daftarPaket.where((p) => p.statusPublik).toList();
  }
}

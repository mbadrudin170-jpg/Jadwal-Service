// path: lib/data_dummy/dummy_dompet.dart

import 'package:wifi/fitur/dompet/model/dompet_model.dart';

/// Data dummy untuk dompet
class DummyDompet {
  static const String idDompetUtama = 'dompet-utama-id';
  static const String idDompetCadangan = 'dompet-cadangan-id';
  static const String idDompetBisnis = 'dompet-bisnis-id';
  static const String idDompetInvestasi = 'dompet-investasi-id';

  static List<DompetModel> get daftarDompet => [
    const DompetModel(id: idDompetUtama, nama: 'Dompet Utama', saldo: 5000000),
    const DompetModel(
      id: idDompetCadangan,
      nama: 'Dompet Cadangan',
      saldo: 1500000,
    ),
    const DompetModel(
      id: idDompetBisnis,
      nama: 'Dompet Bisnis',
      saldo: 10000000,
    ),
    const DompetModel(
      id: idDompetInvestasi,
      nama: 'Dompet Investasi',
      saldo: 2500000,
    ),
  ];

  static DompetModel? getById(String id) {
    try {
      return daftarDompet.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}

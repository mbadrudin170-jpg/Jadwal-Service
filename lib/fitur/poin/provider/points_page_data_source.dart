// path: lib/fitur/poin/provider/points_page_data_source.dart

import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';

abstract class PointsPageDataSource {
  Future<int> ambilTotalPoin(String customerId);

  Future<List<PaketModel>> getPublicPackages();

  Future<List<TransaksiModel>> getPointsTransactions(String customerId);

  Future<PaketModel?> getPaketByid(String packageId);

  bool get isFirebase;
}

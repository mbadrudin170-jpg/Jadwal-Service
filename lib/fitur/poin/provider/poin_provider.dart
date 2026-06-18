// path: lib/fitur/poin/provider/poin_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/poin/operasi/firebase_points_data_source.dart';
import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'poin_provider.g.dart';
part 'poin_provider.freezed.dart';

@freezed
abstract class PoinState with _$PoinState {
  const factory PoinState({
    @Default([]) List<PaketModel> hadiah,
    @Default([]) List<TransaksiModel> transaksi,
    @Default(0) int totalPoin,
  }) = _PoinState;
}

@riverpod
class Poin extends _$Poin {
  @override
  FutureOr<PoinState> build(Ref ref, String idPelanggan) async {
    final dataSource = ref.watch(pointsDataSourceProvider);

    final hadiah = await dataSource.getPublicPackages();
    final transaksi = await dataSource.getPointsTransactions(idPelanggan);
    final totalPoin = await dataSource.ambilTotalPoin(idPelanggan);
    return PoinState(
      hadiah: hadiah,
      transaksi: transaksi,
      totalPoin: totalPoin,
    );
  }
}

@riverpod
PointsPageDataSource pointsDataSource(Ref ref) {
  final role = ref.watch(appRoleProvider);
  if (role == AppRole.admin) {
    return ref.watch(sqlitePointsDataSourceProvider);
  } else {
    return ref.watch(firebasePointsDataSourceProvider);
  }
}

typedef PointsPageData = ({int totalPoin, List<PaketModel> rewards});

@riverpod
Future<PointsPageData> pointsPageData(Ref ref, String idPelanggan) async {
  final dataSource = ref.watch(pointsDataSourceProvider);

  final [totalPoin, hadiah] = await Future.wait([
    dataSource.ambilTotalPoin(idPelanggan),
    dataSource.getPublicPackages(),
  ]);

  return (totalPoints: totalPoin as int, rewards: hadiah as List<PaketModel>);
}

@riverpod
Future<List<TransaksiModel>> pointsHistory(Ref ref, String customerId) {
  final dataSource = ref.watch(pointsDataSourceProvider);
  return dataSource.getPointsTransactions(customerId);
}

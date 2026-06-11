// path: lib/fitur/poin/provider/poin_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/poin/operasi/firebase_points_data_source.dart';
import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

part 'poin_provider.g.dart';
part 'poin_provider.freezed.dart';

@freezed
abstract class PoinState with _$PoinState {
  const factory PoinState({
    @Default([]) List<PackageModel> rewards,
    @Default([]) List<TransactionModel> transaksi,
    @Default(0) int totalPoin,
  }) = _PoinState;
}

@riverpod
class Poin extends _$Poin {
  @override
  FutureOr<PoinState> build(String customerId) {
    return _initAwal(ref, customerId);
  }
}

Future<PoinState> _initAwal(Ref ref, String customerId) async {
  final dataSource = ref.watch(pointsDataSourceProvider);

  final rewards = await dataSource.getPublicPackages();
  final transaksi = await dataSource.getPointsTransactions(customerId);
  final totalPoin = await dataSource.getTotalPoints(customerId);
  return PoinState(
    rewards: rewards,
    transaksi: transaksi,
    totalPoin: totalPoin,
  );
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

typedef PointsPageData = ({int totalPoints, List<PackageModel> rewards});

@riverpod
Future<PointsPageData> pointsPageData(Ref ref, String customerId) async {
  final dataSource = ref.watch(pointsDataSourceProvider);

  final [totalPoints, rewards] = await Future.wait([
    dataSource.getTotalPoints(customerId),
    dataSource.getPublicPackages(),
  ]);

  return (
    totalPoints: totalPoints as int,
    rewards: rewards as List<PackageModel>
  );
}

@riverpod
Future<List<TransactionModel>> pointsHistory(Ref ref, String customerId) {
  final dataSource = ref.watch(pointsDataSourceProvider);
  return dataSource.getPointsTransactions(customerId);
}

// path: lib/fitur/poin/poin/points_page_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/poin/poin/firebase_points_data_source.dart';
import 'package:wifi/fitur/poin/poin/points_page_data_source.dart';
import 'package:wifi/fitur/poin/poin/sqlite_points_data_source.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'points_page_providers.g.dart';

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
Future<List<TransactionModel>> pointsHistory(Ref ref, String customerId)  {
  final dataSource = ref.watch(pointsDataSourceProvider);
  return dataSource.getPointsTransactions(customerId);
}

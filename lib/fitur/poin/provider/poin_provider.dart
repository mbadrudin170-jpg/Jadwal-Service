// // path: lib/fitur/poin/provider/poin_provider.dart

// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:wifi/fitur/app_role/role_util.dart';
// import 'package:wifi/fitur/paket/model/paket_model.dart';
// import 'package:wifi/fitur/poin/operasi/firebase_points_data_source.dart';
// import 'package:wifi/fitur/poin/operasi/sqlite_points_data_source.dart';
// import 'package:wifi/fitur/poin/provider/points_page_data_source.dart';
// import 'package:wifi/shared/export/model.dart';

// part 'poin_provider.g.dart';
// part 'poin_provider.freezed.dart';

// @freezed
// abstract class PoinState with _$PoinState {
//   const factory PoinState({
//     @Default([]) List<PaketModel> hadiah,
//     @Default([]) List<TransaksiModel> transaksi,
//     @Default(0) int totalPoin,
//   }) = _PoinState;
// }

// @riverpod
// class Poin extends _$Poin {
//   @override
//   FutureOr<PoinState> build(Ref ref, String idPelanggan) async {
//     final dataSource = ref.watch(pointsDataSourceProvider);

//     final hadiah = await dataSource.getPublicPackages();
//     final transaksi = await dataSource.getPointsTransactions(idPelanggan);
//     final totalPoin = await dataSource.ambilTotalPoin(idPelanggan);
//     return PoinState(
//       hadiah: hadiah,
//       transaksi: transaksi,
//       totalPoin: totalPoin,
//     );
//   }
// }

// typedef PointsPageData = ({int totalPoin, List<PaketModel> hadiah});

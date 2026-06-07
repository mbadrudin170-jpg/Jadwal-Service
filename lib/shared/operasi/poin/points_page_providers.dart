// path: lib/shared/operasi/poin/points_page_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/poin/firebase_points_data_source.dart';
import 'package:wifi/shared/operasi/poin/points_page_data_source.dart';
import 'package:wifi/shared/operasi/poin/sqlite_points_data_source.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'points_page_providers.g.dart';

/// Langkah 2: Provider "Pengalih" (The Switch)
///
/// Provider ini secara dinamis memilih sumber data (`Firebase` atau `SQLite`)
/// berdasarkan peran pengguna saat ini. Widget UI tidak akan menggunakan ini secara langsung,
/// tetapi provider data di bawah akan menggunakannya.
@riverpod
PointsPageDataSource pointsDataSource(Ref ref) {
  final role = ref.watch(appRoleProvider);
  if (role == AppRole.admin) {
    // Jika admin, gunakan implementasi SQLite.
    return ref.watch(sqlitePointsDataSourceProvider);
  } else {
    // Jika user, gunakan implementasi Firebase.
    return ref.watch(firebasePointsDataSourceProvider);
  }
}

/// Tipe data custom untuk data halaman poin agar lebih mudah dikelola.
typedef PointsPageData = ({int totalPoints, List<PackageModel> rewards});

/// Langkah 3.1: Provider Data Utama untuk UI (Tab Penukaran)
///
/// Widget UI akan `watch` provider ini. Provider ini secara otomatis:
/// 1. Mendapatkan sumber data yang benar (Firebase/SQLite) dari `pointsDataSourceProvider`.
/// 2. Memanggil metode yang diperlukan untuk mengambil total poin dan daftar hadiah.
/// 3. Mengembalikan `AsyncValue` yang berisi data, state loading, atau error.
@riverpod
Future<PointsPageData> pointsPageData(Ref ref, String customerId) async {
  final dataSource = ref.watch(pointsDataSourceProvider);

  // Mengambil total poin dan daftar hadiah secara bersamaan.
  final [totalPoints, rewards] = await Future.wait([
    dataSource.getTotalPoints(customerId),
    dataSource.getPublicPackages(),
  ]);

  return (
    totalPoints: totalPoints as int,
    rewards: rewards as List<PackageModel>
  );
}

/// Langkah 3.2: Provider Data untuk Riwayat Transaksi
///
/// Terpisah agar kita hanya memuatnya saat tab "Riwayat" dipilih.
@riverpod
Future<List<TransactionModel>> pointsHistory(Ref ref, String customerId) async {
  final dataSource = ref.watch(pointsDataSourceProvider);
  return dataSource.getPointsTransactions(customerId);
}

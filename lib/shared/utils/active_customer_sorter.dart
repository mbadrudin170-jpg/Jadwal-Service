// path: lib/shared/utils/active_customer_sorter.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan untuk mengurutkan daftar pelanggan aktif di halaman admin.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/enum/payment_status_enum.dart (PaymentStatus)
//   - lib/shared/model/active_customer_model.dart (ActiveCustomerModel)
//   - lib/shared/utils/calculation_util.dart (CalculationUtil)
//   - lib/shared/debug/log.dart (Log)

import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/utils/calculation_util.dart';

/// Opsi pengurutan untuk daftar pelanggan aktif.
enum SortOption {
  /// Urutkan berdasarkan tanggal berakhir (ascending).
  endDate,

  /// Urutkan berdasarkan tanggal mulai (ascending).
  startDate,

  /// Urutkan berdasarkan waktu terakhir diperbarui (descending).
  lastUpdated,

  /// Urutkan berdasarkan nama pelanggan A-Z.
  nameAZ,

  /// Urutkan berdasarkan nama pelanggan Z-A.
  nameZA,

  /// Urutkan dengan pelanggan lunas di atas.
  paid,

  /// Urutkan dengan pelanggan belum lunas di atas.
  unpaid,

  /// Urutkan dengan paket aktif di atas.
  activePackage,

  /// Urutkan dengan paket tidak aktif di atas.
  inactivePackage,
}

/// Utility untuk mengurutkan daftar pelanggan aktif.
///
/// Mendukung berbagai opsi pengurutan melalui [SortOption].
class ActiveCustomerSorter {
  /// Mengurutkan daftar [customers] berdasarkan [sortOption] yang dipilih.
  ///
  /// [customerNameMap] digunakan untuk menerjemahkan ID pelanggan ke nama
  /// saat mengurutkan berdasarkan nama (nameAZ/nameZA).
  ///
  /// Mengembalikan list baru yang sudah terurut.
  static List<ActiveCustomerModel> sort(
    final List<ActiveCustomerModel> customers,
    final SortOption sortOption,
    final Map<String, String> customerNameMap,
  ) {
    Log.info(
      'Mengurutkan ${customers.length} pelanggan berdasarkan: ${sortOption.name}',
    );
    final sortedList = List.of(customers);

    int Function(ActiveCustomerModel, ActiveCustomerModel) comparator;

    switch (sortOption) {
      case SortOption.endDate:
        comparator = (final a, final b) => a.endDate.compareTo(b.endDate);
        break;
      case SortOption.startDate:
        comparator = (final a, final b) => a.startDate.compareTo(b.startDate);
        break;
      case SortOption.lastUpdated:
        comparator = (final a, final b) {
          final dateA = a.updatedAt ?? a.startDate;
          final dateB = b.updatedAt ?? b.startDate;
          return dateB.compareTo(dateA);
        };
        break;
      case SortOption.nameAZ:
      case SortOption.nameZA:
        comparator = (final a, final b) {
          final nameA = customerNameMap[a.customerId] ?? '';
          final nameB = customerNameMap[b.customerId] ?? '';
          return sortOption == SortOption.nameAZ
              ? nameA.compareTo(nameB)
              : nameB.compareTo(nameA);
        };
        break;
      case SortOption.paid:
      case SortOption.unpaid:
        comparator = (final a, final b) {
          final isPaidA = a.status == PaymentStatus.paid;
          final isPaidB = b.status == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            return a.endDate.compareTo(b.endDate);
          }
          return (sortOption == SortOption.paid)
              ? (isPaidA ? -1 : 1)
              : (isPaidA ? 1 : -1);
        };
        break;
      case SortOption.activePackage:
      case SortOption.inactivePackage:
        comparator = (final a, final b) {
          final isActiveA = CalculationUtil.remainingDays(a.endDate) >= 0;
          final isActiveB = CalculationUtil.remainingDays(b.endDate) >= 0;
          if (isActiveA == isActiveB) {
            return a.endDate.compareTo(b.endDate);
          }
          return (sortOption == SortOption.activePackage)
              ? (isActiveA ? -1 : 1)
              : (isActiveA ? 1 : -1);
        };
        break;
    }

    sortedList.sort(comparator);
    return sortedList;
  }
}

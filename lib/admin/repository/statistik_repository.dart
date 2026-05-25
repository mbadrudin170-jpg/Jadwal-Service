// path: lib/admin/repository/statistik_repository.dart
// diubah: Logika diubah untuk menghitung (Total Paid) - (Total Unpaid).
// diubah: Query SQL menggunakan CASE untuk logika penjumlahan & pengurangan.
// ditambahkan: Metode getBestSellingPackages untuk menghitung paket terlaris.

import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/feedback_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';

/// Repository untuk mengelola semua query data statistik dari database SQLite.
class StatistikRepository {
  final ActiveCustomerOperation _activeCustomerOperation =
      ActiveCustomerOperation();
  final FeedbackOperation _feedbackOperation = FeedbackOperation();
  final PackageOperation _packageOperation = PackageOperation();
  final TransactionOperation _transactionOperation = TransactionOperation();

  /// Menghitung paket mana yang paling banyak terjual.
  ///
  /// Proses:
  /// 1. Mengambil semua data paket aktif dan semua data transaksi.
  /// 2. Menghitung frekuensi kemunculan setiap `packageId` dalam transaksi.
  /// 3. Menggabungkan data paket dengan jumlah penjualannya.
  /// 4. Mengurutkan paket dari yang paling laris.
  /// 5. Mengembalikan daftar [BestSellingPackage] yang sudah diurutkan.
  Future<List<BestSellingPackage>> getBestSellingPackages(
      {int limit = 5}) async {
    Log.info('Mulai menghitung paket terlaris.');
    try {
      final allPackages = await _packageOperation.getPackages();
      final allTransactions = await _transactionOperation.getAllTransactions();

      if (allTransactions.isEmpty) {
        Log.warning('Tidak ada transaksi, mengembalikan list paket kosong.');
        return [];
      }

      // Hitung frekuensi penjualan setiap paketId
      final salesCount = allTransactions
          .where((t) => t.packageId != null)
          .groupListsBy((t) => t.packageId!)
          .map((key, value) => MapEntry(key, value.length));

      // Buat list BestSellingPackage
      final bestSellingPackages = allPackages.map((package) {
        return BestSellingPackage(
          package: package,
          totalSold: salesCount[package.id] ?? 0,
        );
      }).toList();

      // Urutkan dari yang paling banyak terjual
      bestSellingPackages.sort((a, b) => b.totalSold.compareTo(a.totalSold));

      // Ambil sejumlah limit, jika lebih
      final result = bestSellingPackages.take(limit).toList();
      Log.info(
          'Berhasil menghitung ${result.length} paket terlaris: ${result.map((p) => '${p.package.name} (${p.totalSold})').toList()}');

      return result;
    } on Exception catch (e, st) {
      Log.error('Gagal menghitung paket terlaris.', e: e, st: st);
      rethrow;
    }
  }

  /// Menghitung total pendapatan bersih (paid - unpaid) dari tabel transaksi untuk bulan ini.
  Future<double> getPendapatanBulanIni() async {
    Log.info(
        'Mulai mengambil pendapatan bersih (paid-unpaid) bulan ini dari SQLite.');
    try {
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfMonthMillis = startOfMonth.millisecondsSinceEpoch;

      final String tableName =
          '"${TableNameValue.get(TableName.transactions)}"';
      final String paidStatus = PaymentStatus.paid.name;
      final String unpaidStatus = PaymentStatus.unpaid.name;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT SUM(
          CASE
            WHEN ${ColumnNames.paymentStatus} = ? THEN ${ColumnNames.amount}
            WHEN ${ColumnNames.paymentStatus} = ? THEN -${ColumnNames.amount}
            ELSE 0
          END
        ) as total
        FROM $tableName
        WHERE ${ColumnNames.date} >= ? AND ${ColumnNames.isDeleted} = 0
        ''',
        [paidStatus, unpaidStatus, startOfMonthMillis],
      );

      Log.info('Query pendapatan bersih selesai. Hasil mentah: $result');

      if (result.isNotEmpty && result.first['total'] != null) {
        final total = (result.first['total'] as num).toDouble();
        Log.info('Total pendapatan bersih yang dihitung: $total');
        return total;
      } else {
        Log.info('Tidak ada transaksi ditemukan bulan ini, mengembalikan 0.0');
        return 0.0;
      }
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil pendapatan bersih bulan ini dari SQLite.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghitung jumlah total pelanggan yang tidak dihapus dari database.
  Future<int> getTotalPelanggan() async {
    Log.info('Mulai mengambil total jumlah pelanggan dari SQLite.');
    try {
      final db = await DatabaseHelper.instance.database;
      final String tableName = '"${TableNameValue.get(TableName.customer)}"';

      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) 
        FROM $tableName 
        WHERE ${ColumnNames.isDeleted} = 0
        ''',
      );

      Log.info('Query total pelanggan selesai. Hasil mentah: $result');

      final count = Sqflite.firstIntValue(result) ?? 0;
      Log.info('Total pelanggan yang dihitung: $count');
      return count;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil total pelanggan dari SQLite.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghitung jumlah langganan aktif dari database.
  Future<int> getJumlahLanggananAktif() async {
    Log.info('Mulai mengambil jumlah langganan aktif.');
    try {
      final activeCustomers =
          await _activeCustomerOperation.getAllActiveCustomers();
      final count = activeCustomers.length;
      Log.info('Jumlah langganan aktif yang dihitung: $count');
      return count;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil jumlah langganan aktif.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghitung jumlah feedback baru (aktif) dari database.
  Future<int> getJumlahFeedbackBaru() async {
    Log.info('Mulai mengambil jumlah feedback baru.');
    try {
      final activeFeedback = await _feedbackOperation.getAllActiveFeedback();
      final count = activeFeedback.length;
      Log.info('Jumlah feedback baru yang dihitung: $count');
      return count;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengambil jumlah feedback baru.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }
}

// path: lib/admin/repository/statistik_repository.dart

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/model/best_selling_package.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_operation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_Op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

final statistikRepositoryProvider = Provider<StatistikRepository>((ref) {
  Log.info('Membuat instance StatistikRepository melalui provider');
  return StatistikRepository(
    activeCustomerOperation: ref.watch(activeCustomerOperationProvider),
    feedbackOperation: ref.watch(feedbackOperationProvider),
    packageOperation: ref.watch(packageOperationProvider),
    transactionOperation: ref.watch(transactionOperationProvider),
  );
});

/// Repos
class StatistikRepository {
  final ActiveCustomerOperation _activeCustomerOperation;
  final FeedbackOperation _feedbackOperation;
  final PaketOpSqlite _packageOperation;
  final TransactionOperation _transactionOperation;

  StatistikRepository({
    required ActiveCustomerOperation activeCustomerOperation,
    required FeedbackOperation feedbackOperation,
    required PaketOpSqlite packageOperation,
    required TransactionOperation transactionOperation,
  })  : _activeCustomerOperation = activeCustomerOperation,
        _feedbackOperation = feedbackOperation,
        _packageOperation = packageOperation,
        _transactionOperation = transactionOperation;
  Future<List<BestSellingPackage>> getBestSellingPackages(
      {final int limit = 5}) async {
    Log.info('Mulai menghitung paket terlaris.');
    try {
      final allPackages = await _packageOperation.ambilBerdasarkanAktif();
      final allTransactions = await _transactionOperation.getAllTransactions();

      if (allTransactions.isEmpty) {
        Log.warning('Tidak ada transaksi, mengembalikan list paket kosong.');
        return [];
      }

      // Hitung frekuensi penjualan setiap paketId
      final salesCount = allTransactions
          .where((final t) => t.packageId != null)
          .groupListsBy((final t) => t.packageId!)
          .map((final key, final value) => MapEntry(key, value.length));

      // Buat list BestSellingPackage
      final bestSellingPackages = allPackages.map((final package) {
        return BestSellingPackage(
          package: package,
          totalSold: salesCount[package.id] ?? 0,
        );
      }).toList();

      // Urutkan dari yang paling banyak terjual
      bestSellingPackages
          .sort((final a, final b) => b.totalSold.compareTo(a.totalSold));

      // Ambil sejumlah limit, jika lebih
      final result = bestSellingPackages.take(limit).toList();
      Log.info(
          'Berhasil menghitung ${result.length} paket terlaris: ${result.map((final p) => '${p.package.name} (${p.totalSold})').toList()}');

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
      final db = await SqliteDatabase.instance.database;
      final String tableName = '"${NamaTabel.get(TableName.transactions)}"';
      final String paidStatus = PaymentStatus.paid.name;
      final String unpaidStatus = PaymentStatus.unpaid.name;

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT SUM(
          CASE
            WHEN ${NamaKolom.paymentStatus} = ? THEN ${NamaKolom.amount}
            WHEN ${NamaKolom.paymentStatus} = ? THEN -${NamaKolom.amount}
            ELSE 0
          END
        ) as total
        FROM $tableName
        WHERE ${NamaKolom.isDeleted} = 0
        ''',
        [paidStatus, unpaidStatus],
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
      final db = await SqliteDatabase.instance.database;
      final String tableName = '"${NamaTabel.get(TableName.customer)}"';

      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) 
        FROM $tableName 
        WHERE ${NamaKolom.isDeleted} = 0
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

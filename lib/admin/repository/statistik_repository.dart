// path: lib/admin/repository/statistik_repository.dart
// diubah: Logika diubah untuk menghitung (Total Paid) - (Total Unpaid).
// diubah: Query SQL menggunakan CASE untuk logika penjumlahan & pengurangan.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

/// Repository untuk mengelola semua query data statistik dari database SQLite.
class StatistikRepository {
  /// Menghitung total pendapatan bersih (paid - unpaid) dari tabel transaksi untuk bulan ini.
  ///
  /// Proses:
  /// 1. Mendapatkan instance database SQLite.
  /// 2. Menentukan tanggal awal bulan ini dalam format Unix Timestamp (milidetik).
  /// 3. Menjalankan query SQL untuk menjumlahkan kolom `amount` secara kondisional:
  ///    - Ditambah jika status pembayaran adalah 'paid'.
  ///    - Dikurangi jika status pembayaran adalah 'unpaid'.
  /// 4. Filter diterapkan untuk transaksi bulan ini yang tidak dihapus.
  /// 5. Mengembalikan hasil kalkulasi atau 0.0 jika tidak ada data.
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

      // Query ini menghitung total pendapatan bersih dengan menjumlahkan `amount`
      // untuk transaksi 'paid' dan menguranginya untuk transaksi 'unpaid'.
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
}

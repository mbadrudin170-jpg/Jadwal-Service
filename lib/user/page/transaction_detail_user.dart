// path: lib/user/page/transaction_detail_user.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman detail transaksi untuk user.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/utils/format_util.dart (FormatUtil, CurrencyFormat)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/utils/format_util.dart';

// TODO: rencana selanjutnya adalah menggunakan detail riwayat langganan seperti admin
/// Halaman untuk menampilkan detail lengkap dari sebuah transaksi.
///
/// Menampilkan semua informasi yang relevan dari [TransactionModel] dan
/// [PackageModel] yang terkait.
class TransactionDetailPage extends StatelessWidget {
  /// Data transaksi yang akan ditampilkan.
  final TransactionModel transaction;

  /// Data paket yang terkait dengan transaksi (jika ada).
  final PackageModel? package;

  /// Membuat instance dari [TransactionDetailPage].
  const TransactionDetailPage(
      {super.key, required this.transaction, this.package});

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman TransactionDetailPage untuk transaksi ID: ${transaction.id}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Tanggal:',
              FormatUtil.formatDateAndTime(transaction.date),
            ),
            _buildInfoRow('Keterangan:', transaction.description),
            _buildInfoRow(
              'Jumlah:',
              CurrencyFormat.formatCurrency(transaction.amount),
            ),
            _buildInfoRow('Tipe:', transaction.type.name),
            if (package != null)
              _buildInfoRow('Paket:', package!.name)
            else if (transaction.packageId != null)
              _buildInfoRow('Paket:', 'Memuat...'),
            _buildInfoRow(
              'Status Pembayaran:',
              transaction.paymentStatus.name,
            ),
            if (transaction.startDate != null)
              _buildInfoRow(
                'Tanggal Mulai:',
                FormatUtil.formatDateBasic(transaction.startDate!),
              ),
            if (transaction.endDate != null)
              _buildInfoRow(
                'Tanggal Berakhir:',
                FormatUtil.formatDateBasic(transaction.endDate!),
              ),
            _buildInfoRow(
              'Poin didapat:',
              transaction.earnedPoints.toString(),
            ),
            _buildInfoRow(
              'Poin digunakan:',
              transaction.usedPoints.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(final String label, final dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: value is Widget ? value : Text(value.toString()),
          ),
        ],
      ),
    );
  }
}

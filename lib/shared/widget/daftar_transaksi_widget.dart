// path: lib/shared/widget/daftar_transaksi_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Mengelompokkan daftar transaksi berdasarkan tanggal (tanpa jam).
Map<DateTime, List<TransaksiModel>> groupTransactionsByDate(
  final List<TransaksiModel> transactions,
) {
  final Map<DateTime, List<TransaksiModel>> grouped = {};
  for (final t in transactions) {
    final date = DateTime(t.date.year, t.date.month, t.date.day);
    grouped[date] ??= [];
    grouped[date]!.add(t);
  }
  return grouped;
}

/// Membangun widget header untuk sebuah seksi transaksi berdasarkan tanggal.
Widget buildSectionHeader(final DateTime date, final double total) {
  return Builder(builder: (final context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            FormatDate.formatDateCompact(date),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            CurrencyFormat.formatCurrency(total),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: total >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  });
}

/// Widget tile untuk menampilkan satu transaksi dalam daftar.
class TransactionTile extends ConsumerStatefulWidget {
  final TransaksiModel transaksi;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaksi,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<TransactionTile> {
  late final CategoryOperation _kategoriOpSqlite;
  late final DompetOpSqlite _dompetOpSqlite;

  @override
  void initState() {
    super.initState();
    _kategoriOpSqlite = ref.read(kategoriOpSqliteProvider);
    _dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    Log.info('TransactionTile initState for ID: ${widget.transaksi.id}');
  }

  @override
  void dispose() {
    Log.info('TransactionTile dispose for ID: ${widget.transaksi.id}');
    super.dispose();
  }

  Future<String> _getCategoryName() async {
    try {
      final kategori = await _kategoriOpSqlite.getCategoryById(
        widget.transaksi.categoryId,
      );
      return kategori.name;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama kategori untuk ID: ${widget.transaksi.categoryId}',
        e: e,
        s: st,
      );
      return 'Error Kategori';
    }
  }

  Future<String> _getWalletName() async {
    try {
      final dompet = await _dompetOpSqlite.getById(
        widget.transaksi.walletId,
      );
      return dompet?.name ?? 'Dompet Dihapus';
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama dompet untuk ID: ${widget.transaksi.walletId}',
        e: e,
        s: st,
      );
      return 'Error Dompet';
    }
  }

  @override
  Widget build(final BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final IconData iconData;
    final Color iconColor;
    if (widget.transaksi.type == TransactionType.income) {
      iconData = Icons.arrow_downward;
      iconColor = Colors.green;
    } else {
      iconData = Icons.arrow_upward;
      iconColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        key: ValueKey(widget.transaksi.id),
        onTap: widget.onTap,
        onLongPress: () {
          if (widget.onEdit == null && widget.onDelete == null) return;

          unawaited(
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Opsi'),
                content: const Text(
                  'Apa yang ingin Anda lakukan dengan transaksi ini?',
                ),
                actions: [
                  if (widget.onEdit != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit!();
                      },
                      child: const Text('Edit'),
                    ),
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete!();
                      },
                      child: const Text('Hapus'),
                    ),
                ],
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withAlpha(25),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(widget.transaksi.description),
        subtitle: FutureBuilder<List<String>>(
          future: Future.wait([_getCategoryName(), _getWalletName()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }
            if (snapshot.hasError) {
              Log.error(
                'Error di FutureBuilder TransactionTile untuk ID: ${widget.transaksi.id}',
                e: snapshot.error,
                s: snapshot.stackTrace,
              );
              return Text('Error memuat data',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.red));
            }
            final namaKategori = snapshot.data?[0] ?? '-';
            final namaDompet = snapshot.data?[1] ?? '-';
            return Text('$namaKategori | $namaDompet');
          },
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormat.formatCurrency(widget.transaksi.amount),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            gapH4,
            Text(
              TimeFormat.formatHourMinute(widget.transaksi.date),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Membangun widget [TransactionTile] dengan parameter yang diberikan.
Widget buildTransactionItem(
  final BuildContext context,
  final TransaksiModel transaksi, {
  final VoidCallback? onTap,
  final VoidCallback? onEdit,
  final VoidCallback? onDelete,
}) {
  return TransactionTile(
    transaksi: transaksi,
    onTap: onTap,
    onEdit: onEdit,
    onDelete: onDelete,
  );
}

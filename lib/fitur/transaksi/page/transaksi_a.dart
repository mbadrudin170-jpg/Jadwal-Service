// path: lib/fitur/transaksi/page/transaksi_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/helper/pengurut_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/widget_ringkasan_keuangan.dart';

// ============================================================
// Halaman Utama
// ============================================================
class TransaksiA extends ConsumerWidget {
  const TransaksiA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(transaksiProvider);

    return Scaffold(
      appBar: const _TransactionAppBar(),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) => _TransactionBody(state: state),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Log.info('FAB tambah transaksi ditekan.');
          _naviagasiKeForm(context);
        },
        child: const Icon(TIcons.add),
      ),
    );
  }

  Future<void> _naviagasiKeForm(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }
}

// ============================================================
// AppBar
// ============================================================
class _TransactionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _TransactionAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSortBy = ref.watch(urutanTransaksiStateProvider);
    return AppBar(
      title: const Text('Transaksi'),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(TIcons.search)),
        IconButton(
          onPressed: () => _tampilkanDialogUrutan(context, ref, currentSortBy),
          icon: const Icon(TIcons.filter),
          tooltip: 'Urutkan',
        ),
        IconButton(
          onPressed: () => _deleteAllTransactions(context, ref),
          icon: const Icon(TIcons.delete),
          tooltip: 'Hapus Semua Transaksi',
        ),
      ],
    );
  }

  Future<void> _tampilkanDialogUrutan(
    BuildContext context,
    WidgetRef ref,
    UrutanTransaksi currentSortBy,
  ) async {
    Log.info('Membuka dialog pengurutan transaksi.');

    final newSort = await showDialog<UrutanTransaksi>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: [
          RadioGroup<UrutanTransaksi>(
            groupValue: currentSortBy,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              children: UrutanTransaksi.values
                  .map(
                    (sortBy) => RadioListTile<UrutanTransaksi>(
                      title: Text(sortBy.displayName),
                      value: sortBy,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );

    if (newSort != null) {
      // Memanggil method di notifier untuk mengubah urutan
      ref.read(urutanTransaksiStateProvider.notifier).ubahUrutan(newSort);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ============================================================
// Dialog Hapus Semua (tidak berubah)
// ============================================================
Future<void> _deleteAllTransactions(BuildContext context, WidgetRef ref) async {
  final konfirmasi = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text(
        'Anda yakin ingin menghapus semua transaksi? Tindakan ini tidak dapat diurungkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if ((konfirmasi ?? false) && context.mounted) {
    try {
      await ref.read(transaksiProvider.notifier).softDeleteAll();
      if (context.mounted) {
        ToastUtil.success(context, 'Semua transaksi berhasil dihapus.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus semua transaksi.', e: e, s: s);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal menghapus transaksi: $e');
      }
    }
  }
}

// ============================================================
// Body (dengan sorting)
// ============================================================
class _TransactionBody extends ConsumerWidget {
  final TransaksiState state;
  const _TransactionBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(urutanTransaksiStateProvider);
    final sortedTransactions = state.transaksi.urutkan(sortBy);
    return RefreshIndicator(
      onRefresh: () => ref.read(transaksiProvider.notifier).refresh(),
      child: Column(
        children: [
          TransactionSummary(
            pemasukan: state.totalPemasukan,
            pengeluaran: state.totalPengeluaran,
            total: state.total,
          ),
          Expanded(
            // ✅ Perbaikan 5: Gunakan sortedTransactions
            child: sortedTransactions.isEmpty
                ? const Center(child: Text('Tidak ada transaksi'))
                : _TransactionListView(transaksi: sortedTransactions),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ListView (tidak berubah)
// ============================================================
class _TransactionListView extends ConsumerStatefulWidget {
  final List<TransaksiModel> transaksi;
  const _TransactionListView({required this.transaksi});

  @override
  ConsumerState<_TransactionListView> createState() =>
      _TransactionListViewState();
}

class _TransactionListViewState extends ConsumerState<_TransactionListView> {
  final ScrollController _pengendaliScroll = ScrollController();
  int _jumlahTampil = 20;

  @override
  void initState() {
    super.initState();
    _pengendaliScroll.addListener(_deteksiScroll);
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    super.dispose();
  }

  void _deteksiScroll() {
    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      if (_jumlahTampil < widget.transaksi.length) {
        setState(() {
          _jumlahTampil += 20;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaksiTampil = widget.transaksi.take(_jumlahTampil).toList();
    final grupTransaksi = kelompokkanTransaksiPerTanggal(transaksiTampil);

    return ListView.builder(
      controller: _pengendaliScroll,
      key: const PageStorageKey('transaction_list_key'),
      itemCount:
          grupTransaksi.length +
          (_jumlahTampil < widget.transaksi.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == grupTransaksi.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final date = grupTransaksi.keys.elementAt(index);
        final transactionsOnDate = grupTransaksi[date]!;
        final totalHarian = transactionsOnDate.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.income ? item.jumlah : -item.jumlah),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderBagian(date, totalHarian),
            ...transactionsOnDate.map(
              (transaksi) => bangunItemTransaksi(
                context,
                transaksi,
                onTap: () => _navigasiKeDetailTransaksi(context, transaksi),
                onEdit: () =>
                    _navigasiKeFormTransaksi(context, transaksi: transaksi),
                onDelete: () => ref
                    .read(transaksiProvider.notifier)
                    .softDelete(transaksi.id),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigasiKeDetailTransaksi(
    BuildContext context,
    TransaksiModel transaksi,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailTransaksiA(transaksi: transaksi),
      ),
    );
  }

  Future<void> _navigasiKeFormTransaksi(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }
}

// ============================================================
// Widget Ringkasan (tidak diubah)
// ============================================================
class TransactionSummary extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;
  final double total;

  const TransactionSummary({
    super.key,
    required this.pemasukan,
    required this.pengeluaran,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            bangunRingkasanInfoKeuangan(
              context: context,
              label: 'Pemasukan',
              jumlah: pemasukan,
              color: Colors.green,
            ),
            bangunRingkasanInfoKeuangan(
              context: context,
              label: 'Pengeluaran',
              jumlah: pengeluaran,
              color: Colors.red,
            ),
            bangunRingkasanInfoKeuangan(
              context: context,
              label: 'Total',
              jumlah: total,
              color: total >= 0 ? Colors.blue : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// path: lib/admin/halaman/tab/active_customer_tab.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/active_customer_detail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/admin/providers/active_customer_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
// import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/theme/app_sizes.dart';

enum AdvancedOption {
  softDeleteAll,
  archiveExpired,
  cancel,
}

class ActiveCustomerPage extends ConsumerStatefulWidget {
  const ActiveCustomerPage({super.key});

  @override
  ActiveCustomerPageState createState() => ActiveCustomerPageState();
}

class ActiveCustomerPageState extends ConsumerState<ActiveCustomerPage>
    with AutomaticKeepAliveClientMixin<ActiveCustomerPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  // final InternetConnectionService _connectionService =
  //     InternetConnectionService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.info('ActiveCustomerPage initState');
    _searchController.addListener(_onSearchChanged);

    // Jalankan pembersihan otomatis saat halaman pertama kali dimuat
    Future.microtask(() async {
      try {
        await _activeCustomerOperation.archiveExpiredCustomers();
      } catch (e) {
        Log.error('Gagal menjalankan arsip otomatis saat aplikasi dibuka',
            e: e);
      }
      await ref.read(activeCustomerProvider.notifier).fetchActiveCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  ActiveCustomerOperation get _activeCustomerOperation =>
      ref.read(activeCustomerOperationProvider);
  TransactionOperation get _transactionOperation =>
      ref.read(transactionOperationProvider);

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> refreshData() async {
    try {
      await _activeCustomerOperation.archiveExpiredCustomers();
    } catch (e) {
      Log.error('Gagal arsip otomatis saat refresh', e: e);
    }
    await ref.read(activeCustomerProvider.notifier).fetchActiveCustomers();
  }

  Future<void> _softDeleteCustomer(
      final ActiveCustomerDetailModel customer) async {
    final customerId = customer.activeCustomer.id;
    final customerName = customer.customerName;
    final transactionId = customer.activeCustomer.transactionId;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (final ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Text('Yakin ingin mengarsipkan pelanggan "$customerName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Arsipkan',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await _activeCustomerOperation.softDelete(customerId);
        if (transactionId != null) {
          await _transactionOperation.softDelete(transactionId);
        }
        Log.info('Berhasil soft delete pelanggan ID: $customerId');
        if (mounted) {
          ToastUtil.success(
              context, 'Pelanggan "$customerName" berhasil diarsipkan.');
        }
        await ref.read(activeCustomerProvider.notifier).fetchActiveCustomers();
      } on Exception catch (e, s) {
        Log.error('Gagal soft delete pelanggan ID: $customerId', e: e, st: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pelanggan: $e');
        }
      }
    } else {
      Log.info('Soft delete pelanggan ID: $customerId dibatalkan oleh user');
    }
  }

  Future<void> _showSortDialog() async {
    final ActiveCustomerState state = ref.watch(activeCustomerProvider);
    await showDialog<SortOption>(
      context: context,
      builder: (final ctx) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: [
          for (final o in SortOption.values)
            SimpleDialogOption(
              onPressed: () {
                ref.read(activeCustomerProvider.notifier).setSortBy(o);
                Navigator.pop(ctx);
              },
              child: Text(
                o.name,
                style: TextStyle(
                    fontWeight: state.sortBy == o
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ],
      ),
    );
  }

  Future<void> _addActiveCustomer() async {
    Log.info('Navigasi ke form tambah pelanggan aktif');
    await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const FormPelangganAktif()));
  }

  Future<void> _advancedOptions() async {
    Log.info('Membuka opsi lanjutan');
    final AdvancedOption? selected = await showDialog<AdvancedOption>(
      context: context,
      builder: (final ctx) => SimpleDialog(
        title: const Text('Opsi Lanjutan'),
        children: [
          SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(ctx, AdvancedOption.archiveExpired),
              child: const Text('Arsipkan pelanggan kadaluarsa')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, AdvancedOption.softDeleteAll),
              child: const Text('Hapus Semua',
                  style: TextStyle(color: Colors.red))),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, AdvancedOption.cancel),
              child: const Text('Batal')),
        ],
      ),
    );

    if (!mounted) return;
    switch (selected) {
      case AdvancedOption.softDeleteAll:
        Log.warning('Opsi arsipkan semua dipilih');
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (final ctx) => AlertDialog(
            title: const Text('Konfirmasi Arsipkan Semua'),
            content:
                const Text('Yakin ingin mengarsipkan SEMUA pelanggan aktif?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Arsipkan Semua')),
            ],
          ),
        );
        if (confirm ?? false) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            await _activeCustomerOperation.softDeleteAll();
            await _transactionOperation.softDeleteAll();
            if (mounted) {
              ToastUtil.success(context, 'Berhasil mengarsipkan  pelanggan.');
            }
            await ref
                .read(activeCustomerProvider.notifier)
                .fetchActiveCustomers();
          } on Exception catch (e, s) {
            Log.error('Gagal mengarsipkan semua pelanggan aktif', e: e, st: s);
            if (mounted) {
              ToastUtil.error(
                  context, 'Gagal mengarsipkan semua pelanggan: $e');
            }
          }
        }
        break;
      case AdvancedOption.archiveExpired:
        try {
          Log.info('Mulai arsipkan pelanggan kadaluarsa');
          final count =
              await _activeCustomerOperation.archiveExpiredCustomers();
          Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
          if (mounted) {
            ToastUtil.success(
                context, '$count pelanggan kadaluarsa diarsipkan.');
          }
          await ref
              .read(activeCustomerProvider.notifier)
              .fetchActiveCustomers();
        } on Exception catch (e, s) {
          Log.error('Gagal mengarsipkan pelanggan kadaluarsa', e: e, st: s);
          if (mounted) {
            ToastUtil.error(
                context, 'Gagal mengarsipkan pelanggan kadaluarsa: $e');
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    final ActiveCustomerState state = ref.watch(activeCustomerProvider);
    final List<ActiveCustomerDetailModel> customersFromProvider =
        state.activeCustomers;
    final query = _searchController.text.toLowerCase();
    List<ActiveCustomerDetailModel> displayedCustomers;
    if (query.isNotEmpty) {
      displayedCustomers = customersFromProvider.where((final c) {
        final name = c.customerName.toLowerCase();
        return name.contains(query);
      }).toList();
    } else {
      displayedCustomers = List.of(customersFromProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Cari nama...', border: InputBorder.none))
            : const Text('Pelanggan Aktif'),
        actions: _isSearching
            ? [
                IconButton(
                    icon: const Icon(TIcons.close),
                    onPressed: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                    })
              ]
            : [
                IconButton(
                    icon: const Icon(TIcons.search),
                    onPressed: () => setState(() => _isSearching = true)),
                IconButton(
                    icon: const Icon(TIcons.filter),
                    onPressed: _showSortDialog),
                IconButton(
                    icon: const Icon(TIcons.settings),
                    onPressed: _advancedOptions),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: displayedCustomers.isEmpty
            ? const Center(child: Text('Tidak ada pelanggan aktif ditemukan.'))
            : displayedCustomers.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text('Pelanggan tidak ditemukan.'))
                : ListView.builder(
                    itemCount: displayedCustomers.length,
                    itemBuilder: (_, i) {
                      final detail = displayedCustomers[i];
                      final c = detail.activeCustomer;

                      return Card(
                        margin: const EdgeInsets.only(
                            left: TSizes.p16,
                            right: TSizes.p16,
                            bottom: TSizes.p12),
                        child: InkWell(
                          onLongPress: () => _softDeleteCustomer(detail),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (final _) =>
                                        ActiveCustomerDetailPage(
                                            activeCustomer: c)));
                            // await _loadData(); // Cukup load data lokal setelah kembali
                          },
                          child: ListTile(
                            title: Text(
                              detail.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(detail.packageName),
                                Text('Pembayaran: ${c.status.displayName}',
                                    style: TextStyle(
                                        color: c.status == PaymentStatus.paid
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Status: ${CalculationUtil.getRemainingActivePeriodText(c.endDate)}',
                                    style: TextStyle(
                                        color: CalculationUtil
                                            .getRemainingActivePeriodColor(
                                                c.endDate))),
                                Text(
                                    'Berakhir: ${FormatDate.formatDateBasic(c.endDate)} ${TimeFormat.formatHourMinute(c.endDate)}'),
                              ],
                            ),
                            trailing: const Icon(TIcons.chevronRight),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'fab_active_customer',
          onPressed: _addActiveCustomer,
          child: const Icon(TIcons.add)),
    );
  }
}

// path: lib/admin/halaman/tab/active_customer_tab.dart
// diubah: Mengganti pemanggilan archiveActiveCustomer dengan softDelete sesuai standardisasi.
// diubah: Mengganti pemanggilan archiveAllActiveCustomers dengan softDeleteAll sesuai standardisasi.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/active_customer_detail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/active_customer_detail_model.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/active_customer_sorter.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Enum untuk opsi lanjutan pada halaman pelanggan aktif.
enum AdvancedOption {
  /// Hapus semua data pelanggan aktif.
  softDeleteAll,

  /// Arsipkan pelanggan yang sudah kadaluarsa.
  archiveExpired,

  /// Batalkan aksi.
  cancel,
}

/// Halaman untuk menampilkan daftar pelanggan yang sedang aktif berlangganan.
class ActiveCustomerPage extends StatefulWidget {
  /// Konstruktor untuk ActiveCustomerPage.
  const ActiveCustomerPage({super.key});

  @override
  State<ActiveCustomerPage> createState() => _ActiveCustomerPageState();
}

class _ActiveCustomerPageState extends State<ActiveCustomerPage>
    with AutomaticKeepAliveClientMixin<ActiveCustomerPage> {
  final ActiveCustomerOperation _activeCustomerOperation =
      ActiveCustomerOperation();

  List<ActiveCustomerDetailModel> _allCustomers = [];
  List<ActiveCustomerDetailModel> _filteredResults = [];
  bool _isLoading = true;
  SortOption _activeSort = SortOption.endDate;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final InternetConnectionService _connectionService =
      InternetConnectionService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.info('ActiveCustomerPage initState');
    unawaited(_loadData());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => _applyFilterAndSort();

  Future<void> _refreshData() => _loadData(forceRefresh: true);

  Future<void> _loadData({final bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    Log.info('Memuat data pelanggan aktif (forceRefresh: $forceRefresh)');

    try {
      final online = await _connectionService.checkConnection();

      if (online && forceRefresh) {
        await SyncCheckService().runSyncCheck().timeout(
              const Duration(seconds: 15),
              onTimeout: () =>
                  throw TimeoutException('Waktu sinkronisasi habis.'),
            );
      } else if (!online && forceRefresh) {
        Log.warning('Jaringan tidak tersedia saat forceRefresh');
        if (mounted) {
          ToastUtil.warning(
            context,
            'Jaringan tidak tersedia. Menampilkan data lokal.',
          );
        }
      }

      _allCustomers =
          await _activeCustomerOperation.getAllActiveCustomersWithDetails();
      _applyFilterAndSort();
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data pelanggan aktif', e: e, st: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilterAndSort() {
    final query = _searchController.text.toLowerCase();
    Log.info('Menerapkan filter (query: "$query") dan urutan (${_activeSort.name})');

    List<ActiveCustomerDetailModel> tempResult;

    if (query.isNotEmpty) {
      tempResult = _allCustomers.where((final c) {
        final name = c.customerName.toLowerCase();
        return name.contains(query);
      }).toList();
    } else {
      tempResult = List.of(_allCustomers);
    }

    final sorted = ActiveCustomerSorter.sort(tempResult, _activeSort);
    if (mounted) setState(() => _filteredResults = sorted);
  }

  Future<void> _softDeleteCustomer(
      final ActiveCustomerDetailModel customer) async {
    final customerId = customer.activeCustomer.id;
    final customerName = customer.customerName;
    Log.info('Memulai soft delete pelanggan ID: $customerId, Nama: $customerName');

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
              child:
                  const Text('Arsipkan', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await _activeCustomerOperation.softDelete(customerId);
        Log.info('Berhasil soft delete pelanggan ID: $customerId');
        if (mounted) {
          ToastUtil.success(context, 'Pelanggan "$customerName" berhasil diarsipkan.');
        }
        setState(() {
          _allCustomers.removeWhere((final p) => p.activeCustomer.id == customerId);
          _filteredResults.removeWhere((final p) => p.activeCustomer.id == customerId);
        });
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
    Log.info('Menampilkan dialog urutkan, urutan aktif: ${_activeSort.name}');
    final SortOption? selected = await showDialog<SortOption>(
      context: context,
      builder: (final ctx) => SimpleDialog(
        title: const Text('Urutkan Berdasarkan'),
        children: [
          ...SortOption.values.map((final o) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, o),
                child: Text(o.name,
                    style: TextStyle(
                        fontWeight: _activeSort == o
                            ? FontWeight.bold
                            : FontWeight.normal)),
              )),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ],
      ),
    );
    if (selected != null && selected != _activeSort) {
      Log.info('Urutan diubah menjadi ${selected.name}');
      setState(() => _activeSort = selected);
      _applyFilterAndSort();
    }
  }

  Future<void> _addActiveCustomer() async {
    Log.info('Navigasi ke form tambah pelanggan aktif');
    final result = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (final _) => FormPelangganAktif()));
    if (result ?? false) {
      Log.info('Pelanggan baru ditambahkan, memuat ulang data');
      await _loadData(forceRefresh: true);
    }
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
              child: const Text('Arsipkan Semua',
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
                  content: const Text('Yakin ingin mengarsipkan SEMUA pelanggan aktif?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Arsipkan Semua')),
                  ],
                ));
        if (confirm ?? false) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            final count = await _activeCustomerOperation.softDeleteAll();
            Log.info('Berhasil mengarsipkan $count pelanggan aktif.');
            if (mounted) {
              ToastUtil.success(context, 'Berhasil mengarsipkan $count pelanggan.');
            }
            await _loadData(forceRefresh: true);
          } on Exception catch (e, s) {
            Log.error('Gagal mengarsipkan semua pelanggan aktif', e: e, st: s);
            if (mounted) {
              ToastUtil.error(context, 'Gagal mengarsipkan semua pelanggan: $e');
            }
          }
        }
        break;
      case AdvancedOption.archiveExpired:
        try {
          Log.info('Mulai arsipkan pelanggan kadaluarsa');
          final count = await _activeCustomerOperation.archiveExpiredCustomers();
          Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
          if (mounted) {
            ToastUtil.success(
                context, '$count pelanggan kadaluarsa diarsipkan.');
          }
          await _loadData(forceRefresh: true);
        } on Exception catch (e, s) {
          Log.error('Gagal mengarsipkan pelanggan kadaluarsa', e: e, st: s);
          if (mounted) {
            ToastUtil.error(context, 'Gagal mengarsipkan pelanggan kadaluarsa: $e');
          }
        }
        break;
      default:
        // batal
        break;
    }
  }

  @override
  Widget build(final BuildContext context) {
    super.build(context);
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
                    icon: const Icon(AppIcons.close),
                    onPressed: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                    })
              ]
            : [
                IconButton(
                    icon: const Icon(AppIcons.search),
                    onPressed: () => setState(() => _isSearching = true)),
                IconButton(
                    icon: const Icon(AppIcons.filter),
                    onPressed: _showSortDialog),
                IconButton(
                    icon: const Icon(AppIcons.settings),
                    onPressed: _advancedOptions),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _allCustomers.isEmpty
                  ? const Center(
                      child: Text('Tidak ada pelanggan aktif ditemukan.'))
                  : _filteredResults.isEmpty &&
                          _searchController.text.isNotEmpty
                      ? const Center(child: Text('Pelanggan tidak ditemukan.'))
                      : ListView.builder(
                          itemCount: _filteredResults.length,
                          itemBuilder: (final _, final i) {
                            final detail = _filteredResults[i];
                            final c = detail.activeCustomer;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: InkWell(
                                onLongPress: () => _softDeleteCustomer(detail),
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                          builder: (final _) =>
                                              ActiveCustomerDetailPage(
                                                  activeCustomer: c)));
                                  await _loadData(forceRefresh: true);
                                },
                                child: ListTile(
                                  title: Text(
                                    detail.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(detail.packageName),
                                      Text('Pembayaran: ${c.status.name}',
                                          style: TextStyle(
                                              color:
                                                  c.status == PaymentStatus.paid
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
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ),
                            );
                          },
                        ),
            ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'fab_active_customer',
          onPressed: _addActiveCustomer,
          child: const Icon(AppIcons.add)),
    );
  }
}

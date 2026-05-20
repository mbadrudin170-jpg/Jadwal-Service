// path: lib/admin/halaman/tab/active_customer_tab.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai tab "Pelanggan Aktif" di navigasi admin.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/active_customer_detail.dart (ActiveCustomerDetailPage)
//   - lib/admin/halaman/form/active_customer_form.dart (FormPelangganAktif)
//   - lib/shared/data/services/sync_check_service.dart (SyncCheckService)
//   - lib/shared/enum/payment_status_enum.dart (PaymentStatus)
//   - lib/shared/model/active_customer_detail_model.dart (ActiveCustomerDetailModel)
//   - lib/shared/operasi/active_customer_operation.dart (ActiveCustomerOperation)
//   - lib/shared/services/internet_connection_check.dart (InternetConnectionService)
//   - lib/shared/utils/active_customer_sorter.dart (ActiveCustomerSorter, SortOption)
//   - lib/shared/utils/calculation_util.dart (CalculationUtil)
//   - lib/shared/utils/format_util.dart (FormatUtil, TimeFormat)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (ToastUtil)

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
import 'package:wifi/shared/utils/toast_util.dart'; // <-- tambahan import

/// Enum untuk opsi lanjutan pada halaman pelanggan aktif.
enum DeleteOption {
  /// Hapus semua data pelanggan aktif.
  hapusSemua,

  /// Arsipkan pelanggan yang sudah kadaluarsa.
  arsipkanKadaluarsa,

  /// Batalkan aksi.
  batal,
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
  /// Operasi untuk data pelanggan aktif.
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
    Log.info('ActiveCustomerPage initState'); // <-- log inisialisasi
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
    Log.info(
        'Memuat data pelanggan aktif forceRefresh=$forceRefresh'); // <-- log info

    try {
      final online = await _connectionService.checkConnection();

      if (online && forceRefresh) {
        await SyncCheckService().runSyncCheck().timeout(
              const Duration(seconds: 15),
              onTimeout: () =>
                  throw TimeoutException('Waktu sinkronisasi habis.'),
            );
      } else if (!online && forceRefresh) {
        // Ganti SnackBar manual dengan ToastUtil.warning + Log.warning
        Log.warning('Jaringan tidak tersedia saat forceRefresh');
        if (mounted) {
          ToastUtil.warning(
            context,
            'Jaringan tidak tersedia. Menampilkan data lokal.',
          );
        }
      }

      // Menggunakan metode query JOIN yang efisien
      _allCustomers =
          await _activeCustomerOperation.getAllActiveCustomersWithDetails();
      _applyFilterAndSort();
    } on Exception catch (e, s) {
      // Error: Log.error + ToastUtil.error
      Log.error('Gagal memuat data pelanggan aktif', e: e, st: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilterAndSort() {
    final query = _searchController.text.toLowerCase();
    // Log.info dengan info singkat (query & sort aktif)
    Log.info('applyFilterAndSort query="$query" sort=${_activeSort.name}');

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

  Future<void> _archiveCustomer(
      final ActiveCustomerDetailModel customer) async {
    final customerId = customer.activeCustomer.id;
    final customerName = customer.customerName;
    Log.info(
        'Mulai arsip pelanggan id=$customerId nama=$customerName'); // <-- log awal

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (final ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Wrap(children: [
          const Text('Yakin ingin mengarsipkan '),
          Text(customerName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text('?'),
        ]),
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
        await _activeCustomerOperation
            .archiveActiveCustomer(customer.activeCustomer.id);
        // Sukses: log info + snackbar success (feedback ke user)
        Log.info('Berhasil arsip pelanggan id=$customerId');
        if (mounted) {
          ToastUtil.success(context, 'Pelanggan berhasil diarsipkan.');
        }
        setState(() {
          _allCustomers.removeWhere(
              (final p) => p.activeCustomer.id == customer.activeCustomer.id);
          _filteredResults.removeWhere(
              (final p) => p.activeCustomer.id == customer.activeCustomer.id);
        });
      } on Exception catch (e, s) {
        // Error: Log.error + ToastUtil.error
        Log.error('Gagal mengarsipkan pelanggan id=$customerId', e: e, st: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pelanggan');
        }
      }
    } else {
      Log.info('Arsip pelanggan id=$customerId dibatalkan oleh user');
    }
  }

  Future<void> _showSortDialog() async {
    Log.info(
        'Menampilkan dialog sort, sort aktif=${_activeSort.name}'); // <-- log
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
      Log.info('Sort diubah menjadi ${selected.name}'); // <-- log perubahan
      setState(() => _activeSort = selected);
      _applyFilterAndSort();
    }
  }

  Future<void> _addActiveCustomer() async {
    Log.info('Navigasi ke form tambah pelanggan aktif'); // <-- log
    final result = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (final _) => FormPelangganAktif()));
    if (result ?? false) {
      Log.info('Pelanggan baru ditambahkan, memuat ulang data');
      await _loadData(forceRefresh: true);
    }
  }

  Future<void> _advancedOptions() async {
    Log.info('Membuka opsi lanjutan'); // <-- log
    final DeleteOption? selected = await showDialog<DeleteOption>(
      context: context,
      builder: (final ctx) => SimpleDialog(
        title: const Text('Opsi Lanjutan'),
        children: [
          SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(ctx, DeleteOption.arsipkanKadaluarsa),
              child: const Text('Arsipkan pelanggan kadaluarsa')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, DeleteOption.hapusSemua),
              child: const Text('Hapus Semua',
                  style: TextStyle(color: Colors.red))),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, DeleteOption.batal),
              child: const Text('Batal')),
        ],
      ),
    );

    if (!mounted) return;
    switch (selected) {
      case DeleteOption.hapusSemua:
        Log.warning('Opsi hapus semua dipilih'); // <-- log warning
        final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (final ctx) => AlertDialog(
                  title: const Text('Konfirmasi Hapus Semua'),
                  content: const Text('Yakin ingin menghapus SEMUA?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus Semua')),
                  ],
                ));
        if (confirm ?? false) {
          Log.warning('Eksekusi hapus semua pelanggan aktif');
          await _activeCustomerOperation.archiveAllActiveCustomers();
          await _loadData(forceRefresh: true);
        }
        break;
      case DeleteOption.arsipkanKadaluarsa:
        Log.info('Mulai arsipkan pelanggan kadaluarsa'); // <-- log
        final count = await _activeCustomerOperation.archiveExpiredCustomers();
        Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
        if (mounted) {
          // Feedback sukses ke user dengan snackbar
          ToastUtil.success(
              context, '$count pelanggan kadaluarsa diarsipkan.');
        }
        await _loadData(forceRefresh: true);
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
                                onLongPress: () => _archiveCustomer(detail),
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

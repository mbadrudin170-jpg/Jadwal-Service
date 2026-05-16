// path: lib/admin/halaman/tab/active_customer_tab.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai tab "Pelanggan Aktif" di navigasi admin.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/active_customer_detail.dart (ActiveCustomerDetailPage)
//   - lib/admin/halaman/form/active_customer_form.dart (FormPelangganAktif)
//   - lib/shared/data/sync/upload_data.dart (UploadDataService)
//   - lib/shared/enum/payment_status_enum.dart (PaymentStatus)
//   - lib/shared/model/active_customer_model.dart (ActiveCustomerModel)
//   - lib/shared/operasi/active_customer_operation.dart (ActiveCustomerOperation)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/services/internet_connection_check.dart (InternetConnectionService)
//   - lib/shared/utils/active_customer_sorter.dart (ActiveCustomerSorter, SortOption)
//   - lib/shared/utils/calculation_util.dart (CalculationUtil)
//   - lib/shared/utils/format_util.dart (FormatUtil, TimeFormat)
//   - lib/shared/utils/sync_manager.dart (SyncManager)
//   - lib/shared/widget/customer_name.dart (CustomerNameWidget)
//   - lib/shared/widget/package_name.dart (PackageNameWidget)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi/admin/halaman/detail/active_customer_detail.dart';
import 'package:wifi/admin/halaman/form/active_customer_form.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/utils/active_customer_sorter.dart';
import 'package:wifi/shared/utils/calculation_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/package_name.dart';

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

  /// Operasi untuk data pelanggan.
  final CustomerOperation _customerOperation = CustomerOperation();

  /// Operasi untuk data paket.
  final PackageOperation _packageOperation = PackageOperation();

  /// Waktu saat ini.
  final now = DateTime.now();
  List<ActiveCustomerModel> _allCustomers = [];
  List<ActiveCustomerModel> _filteredResults = [];
  Map<String, String> _customerNameMap = {};
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

    final syncManager = Provider.of<SyncManager>(context, listen: false);

    try {
      final online = await _connectionService.checkConnection();

      if (online && forceRefresh) {
        await UploadDataService().uploadActiveCustomerData().timeout(
              const Duration(seconds: 15),
              onTimeout: () =>
                  throw TimeoutException('Waktu sinkronisasi habis.'),
            );
        await syncManager.setLastUpload(now);
      } else if (!online && forceRefresh) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Jaringan tidak tersedia. Menampilkan data lokal.'),
                backgroundColor: Colors.orange),
          );
        }
      }

      final customerList = await _customerOperation.getCustomers();
      _customerNameMap = {for (var p in customerList) p.id: p.name};

      _allCustomers = await _activeCustomerOperation.getAllActiveCustomers();
      _applyFilterAndSort();
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data.', e: e, st: s);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilterAndSort() {
    List<ActiveCustomerModel> tempResult;
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      tempResult = _allCustomers.where((final c) {
        final name = _customerNameMap[c.customerId]?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    } else {
      tempResult = List.of(_allCustomers);
    }

    final sorted =
        ActiveCustomerSorter.sort(tempResult, _activeSort, _customerNameMap);
    if (mounted) setState(() => _filteredResults = sorted);
  }

  Future<void> _archiveCustomer(final ActiveCustomerModel customer) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (final ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Wrap(children: [
          const Text('Yakin ingin mengarsipkan '),
          CustomerNameWidget(
              customerId: customer.customerId,
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
        await _activeCustomerOperation.archiveActiveCustomer(customer.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Pelanggan berhasil diarsipkan.'),
            backgroundColor: Colors.green));
        setState(() {
          _allCustomers.removeWhere((final p) => p.id == customer.id);
          _filteredResults.removeWhere((final p) => p.id == customer.id);
        });
      } on Exception catch (e, s) {
        Log.error('Gagal mengarsipkan.', e: e, st: s);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _showSortDialog() async {
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
      setState(() => _activeSort = selected);
      _applyFilterAndSort();
    }
  }

  Future<void> _addActiveCustomer() async {
    final result = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (final _) => FormPelangganAktif()));
    if (result ?? false) await _loadData(forceRefresh: true);
  }

  Future<void> _advancedOptions() async {
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
          await _activeCustomerOperation.archiveAllActiveCustomers();
          await _loadData(forceRefresh: true);
        }
      case DeleteOption.arsipkanKadaluarsa:
        final count = await _activeCustomerOperation.archiveExpiredCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$count pelanggan kadaluarsa diarsipkan.')));
        }
        await _loadData(forceRefresh: true);
      default:
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
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                    })
              ]
            : [
                IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _isSearching = true)),
                IconButton(
                    icon: const Icon(Icons.sort), onPressed: _showSortDialog),
                IconButton(
                    icon: const Icon(Icons.more_vert),
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
                            final c = _filteredResults[i];
                            final packageFuture = c.packageId.isNotEmpty
                                ? _packageOperation.getPackageById(c.packageId)
                                : Future<PackageModel?>.value();
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              child: InkWell(
                                onLongPress: () => _archiveCustomer(c),
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
                                  title: CustomerNameWidget(
                                      customerId: c.customerId,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PackageNameWidget(
                                          packageFuture: packageFuture),
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
                                          'Berakhir: ${FormatUtil.formatDateBasic(c.endDate)} ${TimeFormat.formatHourMinute(c.endDate)}'),
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
          onPressed: _addActiveCustomer, child: const Icon(Icons.add)),
    );
  }
}

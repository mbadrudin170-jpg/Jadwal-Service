// path: lib/admin/halaman/tab/order_page.dart
// digunakan oleh: lib/admin/halaman/tab/admin_tab_page.dart (sebagai tab Pesanan)
// diubah: Refactor total ke Bahasa Inggris (class, method, variabel) dengan komentar Bahasa Indonesia.
// diubah: Memperbaiki import path dari pesanan_model.dart menjadi order_model.dart.
// diubah: Mengganti PesananOperasi menjadi OrderOperation.
// diubah: Menambahkan dokumentasi untuk mengatasi error public_member_api_docs.
// diubah: Mengganti SnackBar dengan ToastUtil.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/order_model.dart';
import 'package:wifi/shared/operasi/order_operation.dart';
import 'package:wifi/shared/utils/toast_util.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/admin_tab_page.dart (sebagai tab Pesanan)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/order_model.dart (OrderModel)
//   - lib/shared/operasi/order_operation.dart (OrderOperation)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (ToastUtil)

/// Halaman untuk menampilkan dan mengelola daftar pesanan.
class OrderPage extends StatefulWidget {
  /// Konstruktor untuk OrderPage.
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderOperation _orderOperation = OrderOperation();

  List<OrderModel> _orderList = [];
  bool _isLoading = true;
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman OrderPage');
    Log.info('Menginisialisasi halaman daftar pesanan.');
    Log.info('Filter default: "semua" (menampilkan seluruh pesanan).');
    Log.info('========================================');
    Log.info(
      'Memanggil _loadOrders() untuk memuat data pesanan dari database.',
    );
    unawaited(_loadOrders());
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman OrderPage');
    Log.info('Membersihkan resource halaman daftar pesanan.');
    Log.info('========================================');
    super.dispose();
  }

  /// Memuat data pesanan dari database berdasarkan filter status.
  Future<void> _loadOrders() async {
    Log.info('========================================');
    Log.info('MEMUAT DATA PESANAN');
    Log.info('Filter status: "$_filterStatus"');
    Log.info('========================================');

    Log.info(
      'Mengatur state _isLoading menjadi true untuk menampilkan indikator loading.',
    );
    setState(() => _isLoading = true);

    try {
      List<OrderModel> orders;
      if (_filterStatus == 'semua') {
        Log.info(
          'Mengambil SEMUA pesanan dari database (tanpa filter status).',
        );
        orders = await _orderOperation.getAllOrders();
        Log.info(
          'Berhasil mengambil semua pesanan. Jumlah: ${orders.length} pesanan.',
        );
      } else {
        Log.info('Mengambil pesanan dengan filter status: "$_filterStatus".');
        orders = await _orderOperation.getOrdersByStatus(_filterStatus);
        Log.info(
          'Berhasil mengambil pesanan dengan status "$_filterStatus". Jumlah: ${orders.length} pesanan.',
        );
      }

      Log.info('Memperbarui state dengan data pesanan yang telah diambil.');
      Log.info('  - _orderList: ${orders.length} item');
      Log.info('  - _isLoading: false');

      setState(() {
        _orderList = orders;
        _isLoading = false;
      });

      Log.info(
        'State berhasil diperbarui. UI akan menampilkan ${orders.length} pesanan.',
      );
    } on Exception catch (e, s) {
      Log.error(
        'Gagal memuat data pesanan dari database. '
        'Filter yang digunakan: "$_filterStatus". '
        'Kemungkinan penyebab: koneksi database gagal, tabel pesanan tidak ditemukan, '
        'atau terjadi error saat query data.',
        e: e,
        st: s,
      );
      Log.info('Mengatur _isLoading menjadi false meskipun terjadi error.');
      setState(() => _isLoading = false);
    }
  }

  /// Mengubah status pesanan.
  Future<void> _updateStatus(
      final OrderModel order, final String newStatus) async {
    Log.info('========================================');
    Log.info('MENGUBAH STATUS PESANAN');
    Log.info('ID Pesanan: ${order.id}');
    Log.info('ID Pelanggan: ${order.customerId}');
    Log.info('ID Paket: ${order.packageId}');
    Log.info('Status Lama: "${order.status}"');
    Log.info('Status Baru: "$newStatus"');
    Log.info('========================================');

    try {
      Log.info(
        'Memanggil _orderOperation.updateOrderStatus() untuk mengubah status di database.',
      );
      await _orderOperation.updateOrderStatus(order.id, newStatus);
      Log.info(
        'Status pesanan berhasil diubah di database dari "${order.status}" menjadi "$newStatus".',
      );

      Log.info(
        'Memanggil _loadOrders() untuk memperbarui tampilan daftar pesanan.',
      );
      await _loadOrders();
      Log.info('Daftar pesanan berhasil dimuat ulang.');

      if (mounted) {
        Log.info('Widget masih mounted. Menampilkan SnackBar sukses.');
        ToastUtil.success(
          context,
          'Status pesanan #${order.id} diubah menjadi "$newStatus"',
        );
        Log.info('SnackBar sukses telah ditampilkan.');
      } else {
        Log.warning(
          'Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar.',
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengubah status pesanan #${order.id} dari "${order.status}" menjadi "$newStatus". '
        'Kemungkinan penyebab: koneksi database gagal, data pesanan tidak ditemukan, '
        'atau nilai status baru tidak valid.',
        e: e,
        st: s,
      );
      if (mounted) {
        Log.info('Menampilkan SnackBar error ke pengguna.');
        ToastUtil.error(context, 'Gagal mengubah status: $e');
        Log.info('SnackBar error telah ditampilkan.');
      }
    }
  }

  /// Menghapus pesanan setelah konfirmasi dari pengguna.
  Future<void> _deleteOrder(final OrderModel order) async {
    Log.info('========================================');
    Log.info('KONFIRMASI HAPUS PESANAN');
    Log.info('ID Pesanan: ${order.id}');
    Log.info('ID Pelanggan: ${order.customerId}');
    Log.info('ID Paket: ${order.packageId}');
    Log.info('Status: "${order.status}"');
    Log.info('Menampilkan dialog konfirmasi kepada pengguna.');
    Log.info('========================================');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: Text('Yakin hapus pesanan dari ${order.customerId}?'),
        actions: [
          TextButton(
            onPressed: () {
              Log.info('Dialog Hapus: Pengguna memilih BATAL.');
              Navigator.pop(context, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Log.info('Dialog Hapus: Pengguna memilih HAPUS.');
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    Log.info(
      'Hasil konfirmasi: ${confirmed ?? false ? "DISETUJUI (true)" : "DIBATALKAN (${confirmed ?? "null"})"}',
    );

    if (confirmed ?? false) {
      Log.info(
        'Pengguna mengkonfirmasi penghapusan. Memproses hapus pesanan...',
      );
      try {
        Log.info(
          'Memanggil _orderOperation.deleteOrder() untuk menghapus pesanan #${order.id} dari database.',
        );
        await _orderOperation.deleteOrder(order.id);
        Log.info('Pesanan #${order.id} berhasil dihapus dari database.');

        Log.info(
          'Memanggil _loadOrders() untuk memperbarui tampilan daftar pesanan.',
        );
        await _loadOrders();
        Log.info('Daftar pesanan berhasil dimuat ulang.');

        if (mounted) {
          Log.info('Widget masih mounted. Menampilkan SnackBar sukses hapus.');
          ToastUtil.success(context, 'Pesanan berhasil dihapus');
          Log.info('SnackBar sukses hapus telah ditampilkan.');
        } else {
          Log.warning(
            'Widget sudah tidak mounted. Tidak dapat menampilkan SnackBar.',
          );
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menghapus pesanan #${order.id}. '
          'Kemungkinan penyebab: koneksi database gagal, data pesanan tidak ditemukan, '
          'atau terjadi constraint violation.',
          e: e,
          st: s,
        );
        if (mounted) {
          Log.info('Menampilkan SnackBar error ke pengguna.');
          ToastUtil.error(context, 'Gagal menghapus pesanan: $e');
          Log.info('SnackBar error telah ditampilkan.');
        }
      }
    } else {
      Log.info(
        'Penghapusan dibatalkan oleh pengguna. Tidak ada perubahan data.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI OrderPage');
    Log.info('Status loading: $_isLoading');
    Log.info('Filter aktif: "$_filterStatus"');
    Log.info('Jumlah pesanan ditampilkan: ${_orderList.length}');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Log.info(
                'AKSI: Tombol Refresh ditekan. Memuat ulang data pesanan.',
              );
              unawaited(_loadOrders());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSummaryCards(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orderList.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada pesanan',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _buildOrderList(),
          ),
        ],
      ),
    );
  }

  /// Membangun widget filter chips untuk memfilter pesanan berdasarkan status.
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Semua', 'semua'),
            const SizedBox(width: 8),
            _filterChip('Baru', 'baru'),
            const SizedBox(width: 8),
            _filterChip('Diproses', 'diproses'),
            const SizedBox(width: 8),
            _filterChip('Selesai', 'selesai'),
            const SizedBox(width: 8),
            _filterChip('Ditolak', 'ditolak'),
          ],
        ),
      ),
    );
  }

  /// Membuat widget FilterChip tunggal.
  Widget _filterChip(final String label, final String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (final selected) {
        Log.info(
          'FILTER: FilterChip "$label" (value: "$value") dipilih. Selected: $selected',
        );
        Log.info('  - Filter sebelumnya: "$_filterStatus"');
        Log.info('  - Filter baru: "$value"');
        setState(() => _filterStatus = value);
        Log.info(
          'State _filterStatus berhasil diperbarui. Memanggil _loadOrders() dengan filter baru.',
        );
        unawaited(_loadOrders());
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// Membangun kartu ringkasan statistik pesanan.
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              'Total Pesanan',
              '${_orderList.length}',
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Membuat widget kartu ringkasan tunggal.
  Widget _summaryCard(final String title, final String value,
      final IconData icon, final Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun daftar pesanan menggunakan ListView.builder.
  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderList.length,
      itemBuilder: (final context, final index) {
        final order = _orderList[index];
        Log.info(
          'Membangun kartu pesanan ke-${index + 1}/${_orderList.length}: '
          '#${order.id} (Status: ${order.status})',
        );
        return _buildOrderCard(order);
      },
    );
  }

  /// Membangun kartu pesanan tunggal.
  Widget _buildOrderCard(final OrderModel order) {
    final Color statusColor = _getStatusColor(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: InkWell(
        onTap: () {
          Log.info(
            'TAP: Kartu pesanan #${order.id} di-tap. Menampilkan detail pesanan.',
          );
          unawaited(_showOrderDetail(order));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withAlpha(25),
                        child: Icon(Icons.person, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerId,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pesanan #${order.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(order),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.wifi, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.packageId,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(order.date),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton('Proses', Icons.play_arrow, Colors.blue, () {
                    Log.info(
                      'AKSI: Tombol "Proses" ditekan untuk pesanan #${order.id}.',
                    );
                    unawaited(_updateStatus(order, 'diproses'));
                  }),
                  const SizedBox(width: 8),
                  _actionButton('Selesai', Icons.check_circle, Colors.green,
                      () {
                    Log.info(
                      'AKSI: Tombol "Selesai" ditekan untuk pesanan #${order.id}.',
                    );
                    unawaited(_updateStatus(order, 'selesai'));
                  }),
                  const SizedBox(width: 8),
                  _actionButton('Tolak', Icons.cancel, Colors.red, () {
                    Log.info(
                      'AKSI: Tombol "Tolak" ditekan untuk pesanan #${order.id}.',
                    );
                    unawaited(_updateStatus(order, 'ditolak'));
                  }),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      Log.info(
                        'AKSI: Tombol "Hapus" ditekan untuk pesanan #${order.id}.',
                      );
                      unawaited(_deleteOrder(order));
                    },
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membuat tombol aksi untuk kartu pesanan.
  Widget _actionButton(
    final String label,
    final IconData icon,
    final Color color,
    final VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// Mendapatkan warna berdasarkan status pesanan.
  Color _getStatusColor(final OrderModel order) {
    switch (order.status) {
      case 'baru':
        return Colors.blue;
      case 'diproses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        Log.warning(
          'Status pesanan tidak dikenal: "${order.status}" untuk pesanan #${order.id}. Menggunakan warna default (grey).',
        );
        return Colors.grey;
    }
  }

  /// Mendapatkan teks status dengan huruf pertama kapital.
  String _getStatusText(final OrderModel order) {
    return order.status.substring(0, 1).toUpperCase() +
        order.status.substring(1);
  }

  /// Menampilkan bottom sheet detail pesanan.
  Future<void> _showOrderDetail(final OrderModel order) async {
    Log.info('========================================');
    Log.info('MENAMPILKAN DETAIL PESANAN (Bottom Sheet)');
    Log.info('ID Pesanan: ${order.id}');
    Log.info('ID Pelanggan: ${order.customerId}');
    Log.info('ID Paket: ${order.packageId}');
    Log.info('Status: "${order.status}"');
    Log.info(
      'Tanggal: ${DateFormat("dd MMM yyyy HH:mm").format(order.date)}',
    );
    Log.info('========================================');

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (final context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail Pesanan #${order.id}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _detailRow('Nama Pelanggan', order.customerId),
            _detailRow('Paket', order.packageId),
            _detailRow(
              'Tanggal',
              DateFormat('dd MMM yyyy HH:mm').format(order.date),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    Log.info('Bottom Sheet detail pesanan #${order.id} ditutup.');
  }

  /// Membuat baris detail untuk bottom sheet.
  Widget _detailRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

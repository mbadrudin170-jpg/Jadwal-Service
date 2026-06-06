// path: lib/admin/halaman/tab/order_page.dart
// diubah: Mengganti deleteOrder dengan softDelete.
// diubah: Menambahkan fungsi dan tombol untuk softDeleteAll.
// diperbaiki: Menambahkan dokumentasi dan kata kunci final.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/order_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk menampilkan dan mengelola daftar pesanan.
class OrderPage extends ConsumerStatefulWidget {
  /// Halaman untuk menampilkan dan mengelola daftar pesanan.
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  List<OrderModel> _orderList = [];
  bool _isLoading = true;
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman OrderPage');
    unawaited(_loadOrders());
  }

  Future<void> _loadOrders() async {
    final orderOperation = ref.read(orderOperationProvider);
    Log.info('Memuat pesanan dengan filter: $_filterStatus');
    setState(() => _isLoading = true);

    try {
      final List<OrderModel> orders;
      if (_filterStatus == 'semua') {
        orders = await orderOperation.getAllActiveOrders();
      } else {
        orders = await orderOperation.getOrdersByStatus(_filterStatus);
      }
      setState(() {
        _orderList = orders;
        _isLoading = false;
      });
    } on Exception catch (e, s) {
      Log.error('Gagal memuat pesanan', e: e, st: s);
      setState(() => _isLoading = false);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat pesanan: $e');
      }
    }
  }

  Future<void> _updateStatus(
      final OrderModel order, final String newStatus) async {
    Log.info('Mengubah status pesanan ID: ${order.id} ke "$newStatus"');
    final orderOperation = ref.read(orderOperationProvider);

    try {
      await orderOperation.updateOrderStatus(order.id, newStatus);
      await _loadOrders();
      if (mounted) {
        ToastUtil.success(context, 'Status pesanan berhasil diubah');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal mengubah status pesanan', e: e, st: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal mengubah status: $e');
      }
    }
  }

  Future<void> _softDeleteOrder(final OrderModel order) async {
    Log.info('Memulai soft delete untuk pesanan ID: ${order.id}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Arsipkan Pesanan'),
        content:
            Text('Yakin ingin mengarsipkan pesanan dari ${order.customerId}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Arsipkan'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final orderOperation = ref.read(orderOperationProvider);
        await orderOperation.softDelete(order.id);
        await _loadOrders();
        if (mounted) {
          ToastUtil.success(context, 'Pesanan berhasil diarsipkan');
        }
      } on Exception catch (e, s) {
        Log.error('Gagal mengarsipkan pesanan', e: e, st: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pesanan: $e');
        }
      }
    }
  }

  Future<void> _softDeleteAllOrders() async {
    Log.info('Memulai soft delete untuk semua pesanan');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Arsipkan Semua Pesanan?'),
        content: const Text(
            'Anda yakin ingin mengarsipkan semua pesanan yang aktif?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Arsipkan Semua'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final orderOperation = ref.read(orderOperationProvider);
        final count = await orderOperation.softDeleteAll();
        await _loadOrders();
        if (mounted) {
          ToastUtil.success(context, 'Berhasil mengarsipkan $count pesanan.');
        }
      } on Exception catch (e, s) {
        Log.error('Gagal mengarsipkan semua pesanan', e: e, st: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan semua pesanan: $e');
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: _softDeleteAllOrders,
            tooltip: 'Arsipkan Semua',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => unawaited(_loadOrders()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orderList.isEmpty
                    ? const Center(child: Text('Belum ada pesanan'))
                    : _buildOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Semua', 'semua'),
            _filterChip('Baru', 'baru'),
            _filterChip('Diproses', 'diproses'),
            _filterChip('Selesai', 'selesai'),
            _filterChip('Ditolak', 'ditolak'),
          ]
              .map((final e) =>
                  Padding(padding: const EdgeInsets.only(right: 8), child: e))
              .toList(),
        ),
      ),
    );
  }

  Widget _filterChip(final String label, final String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (final selected) {
        setState(() => _filterStatus = value);
        unawaited(_loadOrders());
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderList.length,
      itemBuilder: (final context, final index) {
        final order = _orderList[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(final OrderModel order) {
    final Color statusColor = _getStatusColor(order);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withAlpha(80)),
      ),
      child: InkWell(
        onTap: () => unawaited(_showOrderDetail(order)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.customerId,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_getStatusText(order),
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
gapH24,              Text(order.packageId),
gapH8,              Text(DateFormat('dd MMM yyyy HH:mm').format(order.date)),
gapH12,              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton('Proses',
                      () => unawaited(_updateStatus(order, 'diproses'))),
                  _actionButton('Selesai',
                      () => unawaited(_updateStatus(order, 'selesai'))),
                  _actionButton('Tolak',
                      () => unawaited(_updateStatus(order, 'ditolak'))),
                  IconButton(
                    icon: const Icon(Icons.archive, color: Colors.grey),
                    onPressed: () => unawaited(_softDeleteOrder(order)),
                    tooltip: 'Arsipkan',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(final String label, final VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

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
        return Colors.grey;
    }
  }

  String _getStatusText(final OrderModel order) {
    return order.status.substring(0, 1).toUpperCase() +
        order.status.substring(1);
  }

  Future<void> _showOrderDetail(final OrderModel order) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (final context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pesanan #${order.id}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
gapH20,            _detailRow('Nama Pelanggan', order.customerId),
            _detailRow('Paket', order.packageId),
            _detailRow(
                'Tanggal', DateFormat('dd MMM yyyy HH:mm').format(order.date)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value)
        ],
      ),
    );
  }
}

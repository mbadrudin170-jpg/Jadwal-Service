// path lib/fitur/voucher/page/voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/voucher/enum/tipe_voucher.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/fitur/voucher/page/detail_voucher.dart';
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/fitur/paket/widget/nama_paket_widget.dart';

enum SortVoucherBy { kode, status, paket }

class Voucher extends ConsumerStatefulWidget {
  const Voucher({super.key});

  @override
  ConsumerState<Voucher> createState() => _VoucherState();
}

class _VoucherState extends ConsumerState<Voucher> {
  SortVoucherBy _sortBy = SortVoucherBy.kode;
  bool _ascending = true;
  String? _filterPaketId;
  List<VoucherModel> _urutkanVoucher(List<VoucherModel> daftar) {
    var hasil = daftar;
    if (_filterPaketId != null) {
      hasil = hasil.where((v) => v.idPaket == _filterPaketId).toList();
    }
    var sorted = List<VoucherModel>.from(hasil);
    switch (_sortBy) {
      case SortVoucherBy.kode:
        sorted.sort((a, b) => a.voucher.compareTo(b.voucher));
        break;
      case SortVoucherBy.status:
        sorted.sort(
          (a, b) => a.terpakai.toString().compareTo(b.terpakai.toString()),
        );
        break;
      case SortVoucherBy.paket:
        sorted.sort((a, b) => a.idPaket.compareTo(b.idPaket));
        break;
    }
    if (!_ascending) {
      sorted = sorted.reversed.toList();
    }
    return sorted;
  }

  void _navigasiKeDetail(BuildContext context, String idVoucher) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailVoucher(idVoucher: idVoucher),
      ),
    );
  }

  void _navigasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const FormVoucher()),
    );
  }

  Future<void> _konfirmasiHapus(
    BuildContext context,
    WidgetRef ref,
    String idVoucher,
    String kodeVoucher,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Voucher'),
        content: Text('Yakin ingin menghapus voucher "$kodeVoucher"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(voucherProvider.notifier).softDelete(idVoucher);
        if (context.mounted) {
          ToastUtil.success(context, 'Voucher berhasil dihapus');
        }
      } catch (e) {
        if (context.mounted) {
          ToastUtil.error(context, 'Gagal menghapus voucher');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherAsync = ref.watch(voucherProvider);
    final paketAsync = ref.watch(paketProvider);

    // Ambil daftar voucher (jika tersedia) untuk menghitung badge
    final daftarVoucher = voucherAsync.value?.voucher ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher'),
        actions: [
          PopupMenuButton<SortVoucherBy>(
            icon: const Icon(TIcons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortVoucherBy.kode,
                child: Row(
                  children: [
                    const Text('Kode Voucher'),
                    if (_sortBy == SortVoucherBy.kode)
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortVoucherBy.status,
                child: Row(
                  children: [
                    const Text('Status'),
                    if (_sortBy == SortVoucherBy.status)
                      Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips dengan badge jumlah voucher
          paketAsync.when(
            data: (paketState) =>
                _buildDaftarTombolPaket(paketState.daftarPaket, daftarVoucher),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          // Daftar voucher
          Expanded(
            child: voucherAsync.when(
              data: (state) {
                final urut = _urutkanVoucher(state.voucher);
                if (urut.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                }
                return ListView.builder(
                  itemCount: urut.length,
                  itemBuilder: (context, index) {
                    final voucher = urut[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        onTap: () => _navigasiKeDetail(context, voucher.id),
                        onLongPress: () => _konfirmasiHapus(
                          context,
                          ref,
                          voucher.id,
                          voucher.voucher,
                        ),
                        title: Text(voucher.voucher),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NamaPaketWidget(idPaket: voucher.idPaket),
                            Text(
                              voucher.tipeVoucher == TipeVoucher.satu.name
                                  ? 'Satu Perangkat'
                                  : 'Beberapa Perangkat',
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: voucher.terpakai
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: voucher.terpakai
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            voucher.terpakai ? 'Terpakai' : 'Belum Terpakai',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (error, stackTrace) => Text('$error'),
              loading: () => const Center(child: CircularProgressIndicator()),
              skipLoadingOnReload: true,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tambah_voucher',
        onPressed: () => _navigasiKeForm(context),
        child: const Icon(TIcons.add),
      ),
    );
  }

  Widget _buildDaftarTombolPaket(
    List<PaketModel?> daftarPaket,
    List<VoucherModel> daftarVoucher,
  ) {
    final paketValid = daftarPaket.whereType<PaketModel>().toList();
    final totalSemua = daftarVoucher.length;

    // Hitung jumlah voucher per paket
    final countMap = <String, int>{};
    for (final v in daftarVoucher) {
      countMap[v.idPaket] = (countMap[v.idPaket] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          FilterChip(
            avatar: CircleAvatar(
              radius: 10,
              backgroundColor: _filterPaketId == null
                  ? Colors.white
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Text('$totalSemua', style: const TextStyle(fontSize: 10)),
            ),
            showCheckmark: false,
            selected: _filterPaketId == null,
            label: const Text('Semua'),
            onSelected: (_) => setState(() => _filterPaketId = null),
          ),
          ...paketValid.map((paket) {
            final count = countMap[paket.id] ?? 0;
            return FilterChip(
              avatar: CircleAvatar(
                radius: 10,
                backgroundColor: _filterPaketId == paket.id
                    ? Colors.white
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Text('$count', style: const TextStyle(fontSize: 10)),
              ),
              showCheckmark: false,
              selected: _filterPaketId == paket.id,
              label: Text(paket.nama),
              onSelected: (selected) {
                setState(() {
                  _filterPaketId = selected ? paket.id : null;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}

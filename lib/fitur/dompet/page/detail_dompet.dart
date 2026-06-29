// path: lib/fitur/dompet/page/detail_dompet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

class DetailDompet extends ConsumerWidget {
  final DompetModel dompet;
  const DetailDompet({super.key, required this.dompet});

  Future<void> _navigasiKeDetailTransaksi(
    BuildContext context,
    TransaksiModel transaksi,
  ) async {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaksi.id}',
    );
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiA(transaksi: transaksi),
      ),
    );
  }

  Future<void> _navigasiKeFormTransaksi(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) async {
    Log.info(
      'Membuka FormTransaksiPage untuk mengedit transaksi ID: ${transaksi?.id} dari WalletDetail.',
    );
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailDompet = ref.watch(detailDompetProvider(dompet.id));
    return detailDompet.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Gagal memuat transaksi: $err')),
      data: (detailDompet) {
        final daftarTransaksi = detailDompet.daftarTransaksi;
        final totalPemasukan = detailDompet.totalPemasukan;
        final totalPengeluaran = detailDompet.totalPengeluaran;
        final total = detailDompet.totalSaldo;
        return Scaffold(
          appBar: AppBar(title: Text(detailDompet.namaDompet)),
          body: Column(
            children: [
              RingkasanKeuanganWidget(
                pemasukan: totalPemasukan,
                pengeluaran: totalPengeluaran,
                total: total,
              ),
              Expanded(
                child: _bangunDaftarTransaksi(context, ref, daftarTransaksi),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bangunDaftarTransaksi(
    BuildContext context,
    WidgetRef ref,
    List<TransaksiModel> daftarTransaksi,
  ) {
    final transaksiPerTanggal = kelompokkanTransaksiPerTanggal(daftarTransaksi);
    final transaksi = ref.read(transaksiProvider.notifier);
    return ListView.builder(
      itemCount: transaksiPerTanggal.length,
      itemBuilder: (context, index) {
        final tanggal = transaksiPerTanggal.keys.elementAt(index);
        final transaksiPadaTanggal = transaksiPerTanggal[tanggal]!;
        final totalHarian = transaksiPadaTanggal.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item.tipe == TipeTransaksi.income ? item.jumlah : -item.jumlah),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bangunHeaderBagian(tanggal, totalHarian),
            ...transaksiPadaTanggal.map(
              (transaction) => bangunItemTransaksi(
                context,
                transaction,
                onTap: () {
                  unawaited(_navigasiKeDetailTransaksi(context, transaction));
                },
                onEdit: () {
                  unawaited(
                    _navigasiKeFormTransaksi(context, transaksi: transaction),
                  );
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: ${transaction.id}');
                  await transaksi.softDelete(transaction.id);
                  ref.invalidate(detailDompetProvider(dompet.id));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// path: lib/fitur/dompet/page/detail_dompet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/form_dompet.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

class DetailDompet extends ConsumerWidget {
  final DompetModel dompet;
  const DetailDompet({super.key, required this.dompet});

  void _navigasiKeDetailTransaksi(
    BuildContext context,
    TransaksiModel transaksi,
  ) {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaksi.id}',
    );
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiA(transaksi: transaksi),
      ),
    );
  }

  void _navigasiKeFormTransaksi(
    BuildContext context, {
    TransaksiModel? transaksi,
  }) {
    Log.info(
      'Membuka FormTransaksiPage untuk mengedit transaksi ID: ${transaksi?.id} dari WalletDetail.',
    );
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FormTransaksi(transaksi: transaksi),
      ),
    );
  }

  void _navigasiKeFormDompet(
    BuildContext context, {
    required DompetModel dompet,
  }) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => FormDompet(dompet: dompet)),
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
          appBar: AppBar(
            title: Text(detailDompet.namaDompet),
            actions: [
              IconButton(
                onPressed: () {
                  _navigasiKeFormDompet(
                    context,
                    dompet: detailDompet.dompet ?? dompet,
                  );
                },
                icon: Icon(TIcons.edit),
              ),
            ],
          ),
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
                  _navigasiKeDetailTransaksi(context, transaction);
                },
                onEdit: () {
                  _navigasiKeFormTransaksi(context, transaksi: transaction);
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: ${transaction.id}');
                  await ref
                      .read(transaksiOpGlobalProvider)
                      .softDelete(transaction.id);
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

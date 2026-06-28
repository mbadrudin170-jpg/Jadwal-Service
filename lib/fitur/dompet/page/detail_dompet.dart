// path: lib/fitur/dompet/page/detail_dompet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_a.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/fitur/transaksi/widget/daftar_transaksi_widget.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/widget/ringkasan_keuangan_widget.dart';

class DataDetailDompet {
  final DompetModel dompet;
  final List<TransaksiModel> daftarTransaksi;
  final double totalPemasukan;
  final double totalPengeluaran;

  DataDetailDompet({
    required this.dompet,
    required this.daftarTransaksi,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });
}

class DetailDompet extends ConsumerStatefulWidget {
  final DompetModel dompet;
  final DompetOpSqlite? dompetOpSqlite;
  final TransaksiOpSqlite? transaksiOpSqlite;

  const DetailDompet({
    super.key,
    required this.dompet,
    this.dompetOpSqlite,
    this.transaksiOpSqlite,
  });

  @override
  ConsumerState<DetailDompet> createState() => _DetailDompetState();
}

class _DetailDompetState extends ConsumerState<DetailDompet> {
  late Future<DataDetailDompet> _futureDataDetail;
  String? _namaDompetTerbaru;

  @override
  void initState() {
    super.initState();
    Log.info('Membuat state untuk WalletDetail. ID: ${widget.dompet.id}');
    _futureDataDetail = _muatData();
  }

  Future<DataDetailDompet> _muatData() async {
    Log.info('Memuat data detail dompet ID: ${widget.dompet.id}');
    final dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    final transaksiOp = ref.read(transaksiOpGlobalProvider);
    try {
      final hasil = await Future.wait([
        dompetOpSqlite.ambilBerdasarkanId(widget.dompet.id),
        transaksiOp.ambilBerdasarkanIdDompet(widget.dompet.id),
      ]);
      final dompet = hasil[0] as DompetModel?;
      final daftarTransaksi = hasil[1] as List<TransaksiModel>;

      if (dompet == null) {
        throw Exception('Dompet tidak ditemukan.');
      }

      if (mounted) {
        setState(() {
          _namaDompetTerbaru = dompet.nama;
        });
      }

      double pemasukan = 0;
      double pengeluaran = 0;

      for (final trx in daftarTransaksi) {
        if (trx.tipe == TipeTransaksi.income) {
          pemasukan += trx.jumlah;
        } else if (trx.tipe == TipeTransaksi.expense) {
          pengeluaran += trx.jumlah;
        }
      }

      return DataDetailDompet(
        dompet: dompet,
        daftarTransaksi: daftarTransaksi,
        totalPemasukan: pemasukan,
        totalPengeluaran: pengeluaran,
      );
    } catch (e, s) {
      Log.error('Gagal memuat data detail dompet.', e: e, s: s);
      rethrow;
    }
  }

  void _muatUlangData() {
    Log.info('Memicu pemuatan ulang data untuk WalletDetail.');
    setState(() {
      _futureDataDetail = _muatData();
    });
  }

  Future<void> _navigasiKeDetailTransaksi(TransaksiModel transaction) async {
    Log.info(
      'Navigasi ke TransactionDetailPage dari WalletDetail untuk transaksi ID: ${transaction.id}',
    );
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiA(transaksi: transaction),
      ),
    );

    if (hasil ?? false) {
      Log.info(
        'Kembali dari halaman detail transaksi dengan sinyal reload. Memuat ulang data dompet.',
      );
      _muatUlangData();
    } else {
      Log.info('Kembali dari halaman detail transaksi tanpa perubahan.');
    }
  }

  Future<void> _navigasiKeFormTransaksi({TransaksiModel? transaksi}) async {
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
  Widget build(BuildContext context) {
    final transaksiAsync = ref.watch(transaksiProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_namaDompetTerbaru ?? widget.dompet.nama)),
      body: transaksiAsync.when(
        skipLoadingOnReload: true,
        data: (transaksi) {
          return Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor.withAlpha(13),
                padding: const EdgeInsets.all(20.0),
                child: RingkasanKeuanganWidget(
                  pemasukan: transaksi.totalPemasukan,
                  pengeluaran: transaksi.totalPengeluaran,
                  total: transaksi.total,
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _bangunDaftarTransaksi(transaksi.transaksi)),
            ],
          );
        },
        error: (e, s) => Text('e'),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _bangunDaftarTransaksi(List<TransaksiModel> daftarTransaksi) {
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
                  unawaited(_navigasiKeDetailTransaksi(transaction));
                },
                onEdit: () {
                  unawaited(_navigasiKeFormTransaksi(transaksi: transaction));
                },
                onDelete: () async {
                  Log.info('Hapus transaksi: ${transaction.id}');
                  await transaksi.softDelete(transaction.id);
                  _muatUlangData();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// path lib/fitur/paket/page/detail_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/page/form_paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

class DetailPaketPage extends ConsumerStatefulWidget {
  final PaketModel paket;

  const DetailPaketPage({super.key, required this.paket});

  @override
  ConsumerState<DetailPaketPage> createState() => _DetailPaketState();
}

class _DetailPaketState extends ConsumerState<DetailPaketPage> {
  @override
  void initState() {
    super.initState();
    Log.info(
      'DetailPaketPage: Membuka halaman detail paket ID: $widget.paket.id',
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailPaketAsync = ref.watch(detailPaketProvider(widget.paket.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(detailPaketAsync.value?.nama ?? ''),
        actions: [
          IconButton(
            onPressed: () async {
              unawaited(
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => FormPaket(paket: widget.paket),
                  ),
                ),
              );
            },
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: detailPaketAsync.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              gapH16,
              Text(
                'Gagal memuat data paket',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              gapH8,
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              gapH16,
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(detailPaketProvider(widget.paket.id));
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (paket) => _buildContent(context, paket),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaketModel paket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.blueAccent),
                  gapH8,
                  Text(
                    'Informasi Layanan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              gapH20,
              _buildDetailRow('Nama Paket', paket.nama),
              _buildDetailRow('Harga Sewa', 'Rp ${paket.harga}'),
              _buildDetailRow(
                'Masa Aktif',
                '${paket.durasi} ${paket.tipe.displayName}',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 1),
              ),
              Row(
                children: [
                  const Icon(TIcons.points, color: Colors.orange),
                  gapH8,
                  Text(
                    'Sistem Poin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              gapH12,
              _buildDetailRow(
                'Poin Hadiah',
                '${paket.poinHadiah} Poin',
                subTitle: 'Didapat saat beli paket',
              ),
              _buildDetailRow(
                'Poin Penukaran',
                '${paket.poinPenukaran} Poin',
                subTitle: 'Syarat tukar gratis',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 1),
              ),
              _buildDetailRow(
                'Status Publik',
                paket.statusPublik ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                customValueColor: paket.statusPublik
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    final String label,
    final String value, {
    final String? subTitle,
    final Color? customValueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (subTitle != null)
                  Text(
                    subTitle,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TeksIsiSedang(value, rataTeks: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

// path: lib/fitur/paket/page/paket_publik.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/utils/format_util.dart';

class PaketPublik extends ConsumerWidget {
  const PaketPublik({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paketAsync = ref.watch(paketProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Paket Publik')),
      body: paketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Gagal memuat paket publik: $error')),
        data: (paketState) {
          final daftarPaket = paketState.daftarPaketPublik
              .whereType<PaketModel>()
              .toList();

          if (daftarPaket.isEmpty) {
            return const Center(
              child: Text('Tidak ada paket publik yang tersedia.'),
            );
          }

          return ListView.builder(
            itemCount: daftarPaket.length,
            itemBuilder: (context, index) {
              final paket = daftarPaket[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: TeksJudulSedang(
                    paket.nama,
                    tebalFont: FontWeight.bold,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeksIsiKecil(
                        '${FormatUang.formatMataUang(paket.harga.toDouble())} / ${paket.durasi} ${paket.tipe.displayName}',
                      ),
                      if (paket.poinHadiah > 0)
                        TeksIsiKecil('Poin Hadiah: ${paket.poinHadiah}'),
                      if (paket.poinPenukaran > 0)
                        TeksIsiKecil('Poin Penukaran: ${paket.poinPenukaran}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

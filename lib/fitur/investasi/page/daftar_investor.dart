// path: lib/fitur/investasi/page/daftar_investor.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/investasi/page/detail_investor.dart';
import 'package:wifi/fitur/investasi/provider/investasi_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DaftarInvestor extends ConsumerWidget {
  const DaftarInvestor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investasiAsync = ref.watch(investasiProvider);
    final pelangganAsync = ref.watch(pelangganProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Investor')),
      body: investasiAsync.when(
        data: (investasi) {
          return pelangganAsync.when(
            data: (listPelanggan) {
              final daftarInvestor =
                  listPelanggan.ambilBerdasarkanRole(AppRole.investor)
                    ..sort((a, b) {
                      final lembarA = investasi.getTotalLembarInvestor(a.id);
                      final lembarB = investasi.getTotalLembarInvestor(b.id);
                      return lembarB.compareTo(lembarA);
                    });

              if (daftarInvestor.isEmpty) {
                return const Center(child: Text('Belum ada investor'));
              }

              return ListView.builder(
                itemCount: daftarInvestor.length,
                itemBuilder: (context, index) {
                  final investor = daftarInvestor[index];
                  final totalLembar = investasi.getTotalLembarInvestor(
                    investor.id,
                  );
                  final totalModal = investasi.getTotalModalInvestor(
                    investor.id,
                  );

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              DetailInvestor(idInvestor: investor.id),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            investor.nama.isNotEmpty ? investor.nama[0] : '?',
                          ),
                        ),
                        title: Text(
                          investor.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Total Modal: ${FormatUang.formatMataUang(totalModal)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalLembar',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'Lembar',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(TIcons.error, size: 60, color: Colors.red),
                  gapH16,
                  Text('Error: $error', textAlign: TextAlign.center),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TIcons.error, size: 60, color: Colors.red),
              gapH16,
              Text('Error: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

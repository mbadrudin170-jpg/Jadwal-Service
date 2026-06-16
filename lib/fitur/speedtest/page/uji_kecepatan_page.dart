// path: lib/fitur/speedtest/page/uji_kecepatan_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/speedtest/provider/ping_provider.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';
import 'package:wifi/shared/common/text.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

/// Halaman untuk melakukan pengujian kecepatan internet.
class HalamanUjiKecepatan extends ConsumerStatefulWidget {
  const HalamanUjiKecepatan({super.key});

  @override
  ConsumerState<HalamanUjiKecepatan> createState() =>
      _HalamanUjiKecepatanState();
}

class _HalamanUjiKecepatanState extends ConsumerState<HalamanUjiKecepatan> {
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman uji kecepatan');
  }

  @override
  void dispose() {
    Log.info('Menutup halaman uji kecepatan');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusUji = ref.watch(ujiKecepatanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TeksJudulSedang('Uji Kecepatan Internet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KartuHasilUji(
              label: 'Kecepatan Unduh',
              nilai: statusUji.kecepatanUnduh.toStringAsFixed(1),
              satuan: 'Mbps',
              ikon: TIcons.download,
            ),
            gapH16,
            _KartuHasilUji(
              label: 'Kecepatan Unggah',
              nilai: statusUji.kecepatanUnggah.toStringAsFixed(1),
              satuan: 'Mbps',
              ikon: TIcons.upload,
            ),
            gapH16,
            _KartuHasilUji(
              label: 'Ping',
              nilai: statusUji.ping == 0 ? '' : statusUji.ping.toString(),
              satuan: 'ms',
              ikon: TIcons.timer,
            ),
            const Spacer(),
            Center(
              child: Text(
                statusUji
                    .statusPesan, // Menggunakan Text biasa karena style sudah diatur di sini
                textAlign: TextAlign.center,
              ),
            ),
            gapH24,
            if (statusUji.sedangMenguji)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(pingProvider);
                  ref
                      .read(ujiKecepatanProvider.notifier)
                      .mulaiPengujian(context);
                },
                icon: const Icon(TIcons.play),
                label: const Text('Mulai Uji Kecepatan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            gapH32,
          ],
        ),
      ),
    );
  }
}

/// Widget kartu kecil untuk menampilkan hasil pengujian.
class _KartuHasilUji extends StatelessWidget {
  final String label;
  final String nilai;
  final String satuan;
  final IconData ikon;

  const _KartuHasilUji({
    required this.label,
    required this.nilai,
    required this.satuan,
    required this.ikon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
            gapW20,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeksIsiKecil(label, warna: Colors.grey),
                TeksJudulKecil(
                  '$nilai $satuan',
                  tebalFont: FontWeight.bold,
                ), // Menggunakan TeksJudulKecil untuk ukuran 24
              ],
            ),
          ],
        ),
      ),
    );
  }
}

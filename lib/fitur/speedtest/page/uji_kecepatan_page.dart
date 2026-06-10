// path: lib/fitur/speedtest/page/uji_kecepatan_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/speedtest/provider/uji_kecepatan_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

/// Halaman untuk melakukan pengujian kecepatan internet.
class HalamanUjiKecepatan extends ConsumerStatefulWidget {
  const HalamanUjiKecepatan({super.key});

  @override
  ConsumerState<HalamanUjiKecepatan> createState() => _HalamanUjiKecepatanState();
}

class _HalamanUjiKecepatanState extends ConsumerState<HalamanUjiKecepatan> {
  @override
  /// Menginisialisasi keadaan awal halaman.
  void initState() {
    super.initState();
    Log.info('Membuka halaman uji kecepatan');
  }

  @override
  /// Membersihkan sumber daya saat halaman dilepaskan.
  void dispose() {
    Log.info('Menutup halaman uji kecepatan');
    super.dispose();
  }

  @override
  /// Membangun antarmuka pengguna untuk halaman uji kecepatan.
  Widget build(BuildContext konteks) {
    final keadaanUji = ref.watch(ujiKecepatanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uji Kecepatan Internet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KartuHasilUji(
              label: 'Kecepatan Unduh',
              nilai: keadaanUji.kecepatanUnduh.toStringAsFixed(1),
              satuan: 'Mbps',
              ikon: TIcons.download,
            ),
            gapH16,
            _KartuHasilUji(
              label: 'Kecepatan Unggah',
              nilai: keadaanUji.kecepatanUnggah.toStringAsFixed(1),
              satuan: 'Mbps',
              ikon: TIcons.upload,
            ),
            gapH16,
            _KartuHasilUji(
              label: 'Ping',
              nilai: keadaanUji.ping.toString(),
              satuan: 'ms',
              ikon: TIcons.timer,
            ),
            const Spacer(),
            Center(
              child: Text(
                keadaanUji.statusPesan,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            gapH24,
            if (keadaanUji.sedangMenguji)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(ujiKecepatanProvider.notifier)
                    .mulaiPengujian(konteks),
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
  /// Membangun widget kartu untuk menampilkan detail hasil uji.
  Widget build(BuildContext konteks) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              ikon,
              size: 40,
              color: Theme.of(konteks).primaryColor,
            ),
            gapW20,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(
                  '$nilai $satuan',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

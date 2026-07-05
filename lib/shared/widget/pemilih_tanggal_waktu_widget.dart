// path: lib/shared/widget/pemilih_tanggal_waktu_widget.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class PemilihTanggalWaktuWidget extends StatelessWidget {
  final DateTime? tanggalTerpilih;
  final TimeOfDay? waktuTerpilih;
  final VoidCallback? onPilihTanggal;
  final VoidCallback? onPilihWaktu;
  final String teksLabel;

  const PemilihTanggalWaktuWidget({
    super.key,
    required this.tanggalTerpilih,
    required this.waktuTerpilih,
    required this.onPilihTanggal,
    required this.onPilihWaktu,
    this.teksLabel = 'Pilih Tanggal & Waktu',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(teksLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        gapH8,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: onPilihTanggal,
              icon: const Icon(TIcons.calendar),
              label: Text(
                tanggalTerpilih == null
                    ? 'Pilih Tanggal'
                    : FormatTanggal.formatDasar(tanggalTerpilih!),
              ),
            ),
            TextButton.icon(
              onPressed: onPilihWaktu,
              icon: const Icon(TIcons.clock),
              label: Text(
                waktuTerpilih == null
                    ? 'Pilih Jam'
                    : '${waktuTerpilih!.hour.toString().padLeft(2, '0')}:'
                          '${waktuTerpilih!.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

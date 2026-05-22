// path: lib/admin/halaman/widget/date_time_picker_widget.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Widget untuk memilih tanggal dan waktu secara terpisah.
/// Menampilkan dua tombol: Pilih Tanggal dan Pilih Jam.
class DateTimePickerWidget extends StatelessWidget {
  /// Tanggal yang sedang dipilih (bisa null)
  final DateTime? selectedDate;

  /// Waktu yang sedang dipilih (bisa null)
  final TimeOfDay? selectedTime;

  /// Callback ketika tombol pilih tanggal ditekan
  final VoidCallback onSelectDate;

  /// Callback ketika tombol pilih waktu ditekan
  final VoidCallback onSelectTime;

  /// Teks label di atas tombol
  final String labelText;

  /// Widget untuk memilih tanggal dan waktu secara terpisah.
  const DateTimePickerWidget({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
    this.labelText = 'Pilih Tanggal & Waktu Aktif:',
  });

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Text(
          labelText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tombol pilih tanggal
            TextButton.icon(
              onPressed: onSelectDate,
              icon: const Icon(AppIcons.calendar),
              label: Text(
                selectedDate == null
                    ? 'Pilih Tanggal'
                    : FormatDate.formatDateBasic(selectedDate!),
              ),
            ),
            // Tombol pilih waktu
            TextButton.icon(
              onPressed: onSelectTime,
              icon: const Icon(AppIcons.clock),
              label: Text(
                selectedTime == null
                    ? 'Pilih Jam'
                    : '${selectedTime!.hour.toString().padLeft(2, '0')}:'
                        '${selectedTime!.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

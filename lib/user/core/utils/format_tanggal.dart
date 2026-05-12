// path: lib/core/utils/format_tanggal.dart
import 'dart:developer';

/*
 * File: date_formatter.dart
 * Tujuan: Menyimpan fungsi-fungsi utilitas untuk formatting tanggal
 */

// Fungsi untuk format tanggal ke format dd/MM/yyyy
String formatDate(DateTime date) {
  final formattedDate =
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  log(
    '[Format Tanggal] ✅ Memformat tanggal $date menjadi $formattedDate',
    name: 'format_tanggal.dart',
  );
  return formattedDate;
}

// Fungsi untuk format tanggal dengan nama bulan (contoh: 15 Januari 2026)
String formatDateWithMonthName(DateTime date) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  final formattedDate =
      '${date.day.toString().padLeft(2, '0')} ${bulan[date.month - 1]} ${date.year}';
  log(
    '[Format Tanggal] ✅ Memformat tanggal $date menjadi $formattedDate dengan nama bulan',
    name: 'format_tanggal.dart',
  );
  return formattedDate;
}

// Fungsi untuk format tanggal dan waktu
String formatDateTime(DateTime date) {
  final hari = date.day.toString().padLeft(2, '0');
  final bulan = date.month.toString().padLeft(2, '0');
  final jam = date.hour.toString().padLeft(2, '0');
  final menit = date.minute.toString().padLeft(2, '0');
  final formattedDateTime = '$hari/$bulan/${date.year} $jam:$menit';
  log(
    '[Format Tanggal] ✅ Memformat tanggal dan waktu $date menjadi $formattedDateTime',
    name: 'format_tanggal.dart',
  );
  return formattedDateTime;
}

// FUNGSI BARU: Fungsi untuk format tanggal dengan nama bulan dan waktu
String formatDateTimeWithMonthName(DateTime date) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  final hari = date.day.toString().padLeft(2, '0');
  final jam = date.hour.toString().padLeft(2, '0');
  final menit = date.minute.toString().padLeft(2, '0');
  final formattedDateTime = '$hari ${bulan[date.month - 1]} ${date.year}, $jam:$menit';
  log(
    '[Format Tanggal] ✅ Memformat tanggal dan waktu $date menjadi $formattedDateTime dengan nama bulan',
    name: 'format_tanggal.dart',
  );
  return formattedDateTime;
}

// FUNGSI BARU: Fungsi untuk format tanggal singkat dengan hari dan waktu
String formatShortDateTime(DateTime date) {
  const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];

  final namaHari = hari[date.weekday - 1];
  final tanggal = date.day.toString().padLeft(2, '0');
  final namaBulan = bulan[date.month - 1];
  final tahunSingkat = date.year.toString().substring(2);
  final jam = date.hour.toString().padLeft(2, '0');
  final menit = date.minute.toString().padLeft(2, '0');

  final formattedDateTime =
      '$namaHari, $tanggal $namaBulan $tahunSingkat $jam:$menit';
  log(
    '[Format Tanggal] ✅ Memformat tanggal dan waktu $date menjadi format singkat $formattedDateTime',
    name: 'format_tanggal.dart',
  );
  return formattedDateTime;
}

// Fungsi untuk mendapatkan selisih hari dari sekarang
String getRemainingDays(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;
  String remaining;

  if (difference > 0) {
    remaining = 'Hari tersisa: $difference';
  } else if (difference == 0) {
    remaining = 'Berakhir hari ini';
  } else {
    remaining = 'Berakhir ${-difference} hari yang lalu';
  }

  log(
    '[Kalkulasi Tanggal] ✅ Menghitung selisih hari untuk $date. Hasil: $remaining',
    name: 'format_tanggal.dart',
  );
  return remaining;
}

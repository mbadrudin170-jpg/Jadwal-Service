// path: test/shared/utils/format_util_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wifi/shared/utils/format_util.dart';

void main() {
  // Inisialisasi data lokalisasi sebelum menjalankan tes apa pun.
  // Ini penting untuk memastikan semua format tanggal dan waktu
  // yang bergantung pada lokal 'id_ID' berfungsi dengan benar.
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  // Data tanggal dan waktu yang akan digunakan sebagai dasar untuk semua tes.
  // Ini adalah hari Sabtu, 17 Agustus 2024, pukul 10:30:55
  final testDateTime = DateTime(2024, 8, 17, 10, 30, 55);

  group('FormatDateTime', () {
    test('formatDateAndTime harus memformat tanggal dan waktu dengan benar', () {
      final formatted = FormatDateTime.formatDateAndTime(testDateTime);
      // Ekspektasi: "17 Agu 2024, 10:30"
      expect(formatted, '17 Agu 2024, 10:30');
    });

    test(
        'formatDateAndTimeCompact harus memformat tanggal dan waktu ringkas dengan benar',
        () {
      final formatted = FormatDateTime.formatDateAndTimeCompact(testDateTime);
      // Ekspektasi: "Sab, 17 Agu 24, 10:30"
      expect(formatted, 'Sab, 17 Agu 24, 10:30');
    });
  });

  group('FormatDate', () {
    test('formatDateBasic harus memformat tanggal dasar dengan benar', () {
      final formatted = FormatDate.formatDateBasic(testDateTime);
      // Ekspektasi: "17 Agu 2024"
      expect(formatted, '17 Agu 2024');
    });

    test('formatDateCompact harus memformat tanggal ringkas dengan benar', () {
      final formatted = FormatDate.formatDateCompact(testDateTime);
      // Ekspektasi: "Sab, 17 Agu 24"
      expect(formatted, 'Sab, 17 Agu 24');
    });

    test('formatMonthYear harus memformat bulan dan tahun dengan benar', () {
      final formatted = FormatDate.formatMonthYear(testDateTime);
      // Ekspektasi: "Agustus 2024"
      expect(formatted, 'Agustus 2024');
    });
  });

  group('TimeFormat', () {
    test('formatHourMinute harus memformat jam dan menit dengan benar', () {
      final formatted = TimeFormat.formatHourMinute(testDateTime);
      // Ekspektasi: "10:30"
      expect(formatted, '10:30');
    });

    test('formatFullTime harus memformat jam, menit, dan detik dengan benar',
        () {
      final formatted = TimeFormat.formatFullTime(testDateTime);
      // Ekspektasi: "10:30:55"
      expect(formatted, '10:30:55');
    });

    test(
        'formatTextToHour harus mengonversi string waktu valid ke format jam yang benar',
        () {
      const timeString = '2024-08-17T14:45:00';
      final formatted = TimeFormat.formatTextToHour(timeString);
      // Ekspektasi: "14:45"
      expect(formatted, '14:45');
    });

    test(
        'formatTextToHour harus mengembalikan fallback untuk string waktu yang tidak valid',
        () {
      const invalidTimeString = 'bukan-waktu';
      final formatted = TimeFormat.formatTextToHour(invalidTimeString);
      // Ekspektasi: "--:--"
      expect(formatted, '--:--');
    });
  });

  group('CurrencyFormat', () {
    test('formatCurrency harus memformat angka double ke mata uang Rupiah',
        () {
      const amount = 125000.0;
      final formatted = CurrencyFormat.formatCurrency(amount);
      // Ekspektasi: "Rp 125.000". Spasi bisa jadi non-breaking space,
      // jadi kita ganti untuk memastikan konsistensi.
      expect(formatted.replaceAll('\u00A0', ' '), 'Rp 125.000');
    });

    test('formatCurrency harus menangani angka nol dengan benar', () {
      const amount = 0.0;
      final formatted = CurrencyFormat.formatCurrency(amount);
      expect(formatted.replaceAll('\u00A0', ' '), 'Rp 0');
    });

    test('formatCurrency harus menangani angka negatif dengan benar', () {
      const amount = -50000.0;
      final formatted = CurrencyFormat.formatCurrency(amount);
      // Ekspektasi untuk angka negatif adalah "-Rp 50.000"
      expect(formatted.replaceAll('\u00A0', ' '), '-Rp 50.000');
    });
  });

  group('NumberFormatter', () {
    test(
        'formatWithSeparator harus memformat angka integer dengan separator ribuan',
        () {
      const value = 1500000;
      final formatted = NumberFormatter.formatWithSeparator(value);
      // Ekspektasi: "1.500.000"
      expect(formatted, '1.500.000');
    });

    test('formatWithSeparator harus menangani angka di bawah seribu', () {
      const value = 999;
      final formatted = NumberFormatter.formatWithSeparator(value);
      expect(formatted, '999');
    });
  });
}

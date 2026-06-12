// path: test/shared/utils/calculation_util_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/utils/calculation_util.dart';

void main() {
  // Tanggal referensi yang akan digunakan di seluruh pengujian
  // untuk memastikan hasil yang konsisten.
  final startDate = DateTime(2024, 8, 1, 10); // 1 Agustus 2024, 10:00

  group('CalculationUtil.hitungTanggalBerakhir', () {
    test('harus menghitung tanggal berakhir dengan benar untuk durasi jam', () {
      final paket = PaketModel(
        name: 'Paket Jam',
        price: 1000,
        duration: 3,
        type: DurationType.hours,
      );
      final expectedEndDate = DateTime(2024, 8, 1, 13); // 3 jam kemudian
      final result = CalculationUtil.hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedEndDate);
    });

    test('harus menghitung tanggal berakhir dengan benar untuk durasi hari',
        () {
      final paket = PaketModel(
        name: 'Paket Harian',
        price: 5000,
        duration: 7,
        type: DurationType.days,
      );
      final expectedEndDate = DateTime(2024, 8, 8, 10); // 7 hari kemudian
      final result = CalculationUtil.hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedEndDate);
    });

    test('harus menghitung tanggal berakhir dengan benar untuk durasi bulan',
        () {
      final paket = PaketModel(
        name: 'Paket Bulanan',
        price: 50000,
        duration: 2,
        type: DurationType.months,
      );
      // 1 Agustus + 2 bulan = 1 Oktober
      final expectedEndDate = DateTime(2024, 10, 1, 10);
      final result = CalculationUtil.hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedEndDate);
    });

    test('harus menghitung tanggal berakhir dengan benar untuk durasi menit',
        () {
      final paket = PaketModel(
        name: 'Paket Menitan',
        price: 500,
        duration: 90,
        type: DurationType.minutes,
      );
      // 10:00 + 90 menit = 11:30
      final expectedEndDate = DateTime(2024, 8, 1, 11, 30);
      final result = CalculationUtil.hitungTanggalBerakhir(startDate, paket);
      expect(result, expectedEndDate);
    });
  });

  group('CalculationUtil.getExpiredPoints', () {
    test(
        'harus mengembalikan string kosong jika poin belum hangus (<= 30 hari)',
        () {
      // Selisih 30 hari dari startDate
      final now = DateTime(2024, 8, 31, 10);
      final result =
          CalculationUtil.getExpiredPoints(startDate: startDate, now: now);
      expect(result, '');
    });

    test('harus mengembalikan "Hangus" jika poin sudah hangus (> 30 hari)', () {
      // Selisih 31 hari dari startDate
      final now = DateTime(2024, 9, 1, 10);
      final result =
          CalculationUtil.getExpiredPoints(startDate: startDate, now: now);
      expect(result, 'Hangus');
    });
  });

  group('CalculationUtil.remainingDays', () {
    test('harus mengembalikan jumlah sisa hari yang benar (kasus positif)', () {
      final endDate = DateTime(2024, 8, 11); // 10 hari dari startDate
      final now = DateTime(2024, 8);
      final result = CalculationUtil.remainingDays(endDate, now: now);
      expect(result, 10);
    });

    test('harus mengembalikan 0 jika tanggal berakhir adalah hari ini', () {
      final endDate = DateTime(2024, 8);
      final now = DateTime(2024, 8);
      final result = CalculationUtil.remainingDays(endDate, now: now);
      expect(result, 0);
    });

    test('harus mengembalikan jumlah hari negatif jika sudah lewat', () {
      final endDate = DateTime(2024, 7, 27); // 5 hari sebelum `now`
      final now = DateTime(2024, 8);
      final result = CalculationUtil.remainingDays(endDate, now: now);
      expect(result, -5);
    });
  });

  group('CalculationUtil.getRemainingActivePeriodText', () {
    final now = DateTime(2024, 8, 1, 10);

    test('harus menampilkan "Sisa X hari" jika sisa lebih dari 1 hari', () {
      final endDate = now.add(const Duration(days: 5, hours: 2));
      final result =
          CalculationUtil.getRemainingActivePeriodText(endDate, now: now);
      expect(result, 'Sisa 5 hari');
    });

    test('harus menampilkan "Sisa X jam" jika sisa kurang dari 1 hari', () {
      final endDate = now.add(const Duration(hours: 15));
      final result =
          CalculationUtil.getRemainingActivePeriodText(endDate, now: now);
      expect(result, 'Sisa 15 jam');
    });

    test('harus menampilkan "Sisa X menit" jika sisa kurang dari 1 jam', () {
      final endDate = now.add(const Duration(minutes: 45));
      final result =
          CalculationUtil.getRemainingActivePeriodText(endDate, now: now);
      expect(result, 'Sisa 45 menit');
    });

    test('harus menampilkan "Berakhir" jika sudah lewat', () {
      final endDate = now.subtract(const Duration(seconds: 1));
      final result =
          CalculationUtil.getRemainingActivePeriodText(endDate, now: now);
      expect(result, 'Berakhir');
    });

    test(
        'harus menampilkan "Berakhir dalam beberapa saat" jika sisa waktu sangat sedikit',
        () {
      final endDate = now.add(const Duration(seconds: 30));
      final result =
          CalculationUtil.getRemainingActivePeriodText(endDate, now: now);
      expect(result, 'Berakhir dalam beberapa saat');
    });
  });

  group('CalculationUtil.getRemainingActivePeriodColor', () {
    final now = DateTime(2024, 8);

    test('harus mengembalikan Colors.green jika sisa lebih dari 7 hari', () {
      final endDate = now.add(const Duration(days: 8));
      final result =
          CalculationUtil.getRemainingActivePeriodColor(endDate, now: now);
      expect(result, Colors.green);
    });

    test('harus mengembalikan Colors.orange jika sisa antara 1 sampai 7 hari',
        () {
      final endDate = now.add(const Duration(days: 7));
      final result =
          CalculationUtil.getRemainingActivePeriodColor(endDate, now: now);
      expect(result, Colors.orange);
    });

    test('harus mengembalikan Colors.orange jika sisa 1 hari', () {
      final endDate = now.add(const Duration(days: 1));
      final result =
          CalculationUtil.getRemainingActivePeriodColor(endDate, now: now);
      expect(result, Colors.orange);
    });

    test('harus mengembalikan Colors.red jika sisa 0 hari (berakhir hari ini)',
        () {
      final endDate = now;
      final result =
          CalculationUtil.getRemainingActivePeriodColor(endDate, now: now);
      expect(result, Colors.red);
    });

    test('harus mengembalikan Colors.red jika sudah berakhir', () {
      final endDate = now.subtract(const Duration(days: 1));
      final result =
          CalculationUtil.getRemainingActivePeriodColor(endDate, now: now);
      expect(result, Colors.red);
    });
  });
}

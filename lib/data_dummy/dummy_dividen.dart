// path: lib/data_dummy/dummy_dividen.dart

import 'package:wifi/data_dummy/dummy_investasi.dart';
import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';

/// Data dummy untuk dividen

// ============================================================
// ID DIVIDEN
// ============================================================
const String idDividen1 = 'dividen-001';
const String idDividen2 = 'dividen-002';
const String idDividen3 = 'dividen-003';
const String idDividen4 = 'dividen-004';
const String idDividen5 = 'dividen-005';
const String idDividen6 = 'dividen-006';
const String idDividen7 = 'dividen-007';
const String idDividen8 = 'dividen-008';
const String idDividen9 = 'dividen-009';
const String idDividen10 = 'dividen-010';
const String idDividen11 = 'dividen-011';
const String idDividen12 = 'dividen-012';
const String idDividen13 = 'dividen-013';
const String idDividen14 = 'dividen-014';
const String idDividen15 = 'dividen-015';

// ============================================================
// DATA DIVIDEN DUMMY
// ============================================================

/// Daftar semua dividen dummy
List<DividenModel> get daftarDividen {
  final now = DateTime.now();
  final satuBulanLalu = now.subtract(const Duration(days: 30));
  final duaBulanLalu = now.subtract(const Duration(days: 60));
  final tigaBulanLalu = now.subtract(const Duration(days: 90));
  final empatBulanLalu = now.subtract(const Duration(days: 120));
  final limaBulanLalu = now.subtract(const Duration(days: 150));

  return [
    // ============================================================
    // DIVIDEN INVESTOR 1 (Budi Santoso)
    // ============================================================
    DividenModel(
      id: idDividen1,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: limaBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen2,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: empatBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen3,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: tigaBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen4,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: duaBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen5,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: satuBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen6,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: now,
      sudahDibayar: false, // Belum dibayar
    ),
    DividenModel(
      id: idDividen7,
      idInvestasi: idInvestasi2,
      idInvestor: idInvestor1,
      jumlahDividen: 240000,
      tanggalPembagian: tigaBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen8,
      idInvestasi: idInvestasi2,
      idInvestor: idInvestor1,
      jumlahDividen: 240000,
      tanggalPembagian: satuBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen9,
      idInvestasi: idInvestasi2,
      idInvestor: idInvestor1,
      jumlahDividen: 240000,
      tanggalPembagian: now,
      sudahDibayar: false, // Belum dibayar
    ),
    DividenModel(
      id: idDividen10,
      idInvestasi: idInvestasi3,
      idInvestor: idInvestor1,
      jumlahDividen: 180000,
      tanggalPembagian: duaBulanLalu,
      sudahDibayar: true,
    ),

    // ============================================================
    // DIVIDEN INVESTOR 2
    // ============================================================
    DividenModel(
      id: idDividen11,
      idInvestasi: idInvestasi4,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: tigaBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen12,
      idInvestasi: idInvestasi4,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: duaBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen13,
      idInvestasi: idInvestasi4,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: satuBulanLalu,
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen14,
      idInvestasi: idInvestasi4,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: now,
      sudahDibayar: false, // Belum dibayar
    ),
    DividenModel(
      id: idDividen15,
      idInvestasi: idInvestasi5,
      idInvestor: idInvestor2,
      jumlahDividen: 360000,
      tanggalPembagian: duaBulanLalu,
      sudahDibayar: true,
    ),
  ];
}

// ============================================================
// FUNGSI PEMBANTU
// ============================================================

/// Mendapatkan dividen berdasarkan ID investor
List<DividenModel> getDividenByIdInvestor(String idInvestor) {
  return daftarDividen.where((d) => d.idInvestor == idInvestor).toList();
}

/// Mendapatkan dividen berdasarkan ID investasi
List<DividenModel> getDividenByIdInvestasi(String idInvestasi) {
  return daftarDividen.where((d) => d.idInvestasi == idInvestasi).toList();
}

/// Mendapatkan dividen berdasarkan ID
DividenModel? getDividenById(String id) {
  try {
    return daftarDividen.firstWhere((d) => d.id == id);
  } catch (e) {
    return null;
  }
}

/// Mendapatkan dividen yang sudah dibayar
List<DividenModel> getDividenSudahDibayar() {
  return daftarDividen.where((d) => d.sudahDibayar).toList();
}

/// Mendapatkan dividen yang belum dibayar
List<DividenModel> getDividenBelumDibayar() {
  return daftarDividen.where((d) => !d.sudahDibayar).toList();
}

/// Mendapatkan dividen berdasarkan rentang tanggal
List<DividenModel> getDividenByDateRange(DateTime mulai, DateTime sampai) {
  return daftarDividen.where((d) {
    return d.tanggalPembagian.isAfter(mulai) &&
        d.tanggalPembagian.isBefore(sampai);
  }).toList();
}

/// Menghitung total dividen yang sudah diterima investor
double getTotalDividenDiterima(String idInvestor) {
  return daftarDividen
      .where((d) => d.idInvestor == idInvestor && d.sudahDibayar)
      .fold(0.0, (sum, d) => sum + d.jumlahDividen);
}

/// Menghitung total dividen yang belum dibayar investor
double getTotalDividenBelumDibayar(String idInvestor) {
  return daftarDividen
      .where((d) => d.idInvestor == idInvestor && !d.sudahDibayar)
      .fold(0.0, (sum, d) => sum + d.jumlahDividen);
}

/// Menghitung total semua dividen investor (sudah + belum)
double getTotalDividen(String idInvestor) {
  return daftarDividen
      .where((d) => d.idInvestor == idInvestor)
      .fold(0.0, (sum, d) => sum + d.jumlahDividen);
}

/// Menghitung total dividen keseluruhan (semua investor)
double getTotalDividenKeseluruhan() {
  return daftarDividen.fold(0.0, (sum, d) => sum + d.jumlahDividen);
}

/// Menghitung total dividen yang sudah dibayar keseluruhan
double getTotalDividenSudahDibayarKeseluruhan() {
  return daftarDividen
      .where((d) => d.sudahDibayar)
      .fold(0.0, (sum, d) => sum + d.jumlahDividen);
}

/// Menghitung total dividen yang belum dibayar keseluruhan
double getTotalDividenBelumDibayarKeseluruhan() {
  return daftarDividen
      .where((d) => !d.sudahDibayar)
      .fold(0.0, (sum, d) => sum + d.jumlahDividen);
}

/// Mendapatkan statistik dividen per investor
Map<String, Map<String, dynamic>> getStatistikDividenPerInvestor() {
  final statistik = <String, Map<String, dynamic>>{};

  // Ambil semua ID investor unik dari data dividen
  final idInvestorUnik = daftarDividen.map((d) => d.idInvestor).toSet();

  for (final id in idInvestorUnik) {
    final dividenInvestor = getDividenByIdInvestor(id);
    final totalDiterima = dividenInvestor
        .where((d) => d.sudahDibayar)
        .fold(0.0, (sum, d) => sum + d.jumlahDividen);
    final totalBelumDibayar = dividenInvestor
        .where((d) => !d.sudahDibayar)
        .fold(0.0, (sum, d) => sum + d.jumlahDividen);
    final total = totalDiterima + totalBelumDibayar;

    statistik[id] = {
      'total_diterima': totalDiterima,
      'total_belum_dibayar': totalBelumDibayar,
      'total': total,
      'jumlah_transaksi': dividenInvestor.length,
    };
  }

  return statistik;
}

/// Mendapatkan dividen terbaru (berdasarkan tanggal)
List<DividenModel> getDividenTerbaru({int limit = 5}) {
  final sorted = List<DividenModel>.from(daftarDividen)
    ..sort((a, b) => b.tanggalPembagian.compareTo(a.tanggalPembagian));
  return sorted.take(limit).toList();
}

/// Mendapatkan dividen tertua (berdasarkan tanggal)
List<DividenModel> getDividenTertua({int limit = 5}) {
  final sorted = List<DividenModel>.from(daftarDividen)
    ..sort((a, b) => a.tanggalPembagian.compareTo(b.tanggalPembagian));
  return sorted.take(limit).toList();
}
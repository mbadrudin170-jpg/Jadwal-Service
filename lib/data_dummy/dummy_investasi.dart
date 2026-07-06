// path: lib/data_dummy/dummy_investasi.dart

import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/data_dummy/dummy_transaksi.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';

/// Data dummy untuk investasi dan dividen

// ============================================================
// ID INVESTASI
// ============================================================
const String idInvestasi1 = 'investasi-001';
const String idInvestasi2 = 'investasi-002';
const String idInvestasi3 = 'investasi-003';
const String idInvestasi4 = 'investasi-004';
const String idInvestasi5 = 'investasi-005';

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

// ============================================================
// DATA INVESTASI DUMMY
// ============================================================

/// Daftar investasi untuk semua investor
List<InvestasiModel> get daftarInvestasi {
  final now = DateTime.now();
  final satuBulanLalu = now.subtract(const Duration(days: 30));
  const duaBulanLalu = Duration(days: 60);
  const tigaBulanLalu = Duration(days: 90);
  const empatBulanLalu = Duration(days: 120);

  return [
    // ============================================================
    // INVESTASI INVESTOR 1 (Budi Santoso)
    // ============================================================
    InvestasiModel(
      id: idInvestasi1,
      idInvestor: idInvestor1,
      idTransaksi: idTransaksi1, // Transaksi Gaji Budi
      jumlahModal: 5000000,
      jumlahLembar: 50,
      persentaseKepemilikan: 0.4, // 40%
      tanggalInvestasi: now.subtract(duaBulanLalu),
    ),
    InvestasiModel(
      id: idInvestasi2,
      idInvestor: idInvestor1,
      idTransaksi: idTransaksi2, // Transaksi Bonus Budi
      jumlahModal: 2000000,
      jumlahLembar: 20,
      persentaseKepemilikan: 0.15, // 15%
      tanggalInvestasi: satuBulanLalu,
    ),

    // ============================================================
    // INVESTASI INVESTOR 2
    // ============================================================
    InvestasiModel(
      id: idInvestasi3,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi5, // Transaksi Aktivasi Paket Bisnis Siti
      jumlahModal: 7500000,
      jumlahLembar: 75,
      persentaseKepemilikan: 0.6, // 60%
      tanggalInvestasi: now.subtract(tigaBulanLalu),
    ),
    InvestasiModel(
      id: idInvestasi4,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi7, // Transaksi Aktivasi Paket Gamer Dewi
      jumlahModal: 3000000,
      jumlahLembar: 30,
      persentaseKepemilikan: 0.25, // 25%
      tanggalInvestasi: now.subtract(empatBulanLalu),
    ),
    InvestasiModel(
      id: idInvestasi5,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi9, // Transaksi Aktivasi Paket Ultimate Joko
      jumlahModal: 1000000,
      jumlahLembar: 10,
      persentaseKepemilikan: 0.1, // 10%
      tanggalInvestasi: now.subtract(duaBulanLalu),
    ),
  ];
}

// ============================================================
// DATA DIVIDEN DUMMY
// ============================================================

/// Daftar dividen untuk semua investor
List<DividenModel> get daftarDividen {
  final now = DateTime.now();
  const satuBulanLalu = Duration(days: 30);
  const duaBulanLalu = Duration(days: 60);

  return [
    // ============================================================
    // DIVIDEN INVESTOR 1 (Budi Santoso)
    // ============================================================
    DividenModel(
      id: idDividen1,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: now.subtract(satuBulanLalu),
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen2,
      idInvestasi: idInvestasi1,
      idInvestor: idInvestor1,
      jumlahDividen: 600000,
      tanggalPembagian: now,
      sudahDibayar: false, // Belum dibayar
    ),
    DividenModel(
      id: idDividen3,
      idInvestasi: idInvestasi2,
      idInvestor: idInvestor1,
      jumlahDividen: 240000,
      tanggalPembagian: now.subtract(satuBulanLalu),
      sudahDibayar: true,
    ),

    // ============================================================
    // DIVIDEN INVESTOR 2
    // ============================================================
    DividenModel(
      id: idDividen4,
      idInvestasi: idInvestasi3,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: now.subtract(duaBulanLalu),
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen5,
      idInvestasi: idInvestasi3,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: now.subtract(satuBulanLalu),
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen6,
      idInvestasi: idInvestasi3,
      idInvestor: idInvestor2,
      jumlahDividen: 900000,
      tanggalPembagian: now,
      sudahDibayar: false,
    ),
    DividenModel(
      id: idDividen7,
      idInvestasi: idInvestasi4,
      idInvestor: idInvestor2,
      jumlahDividen: 360000,
      tanggalPembagian: now.subtract(duaBulanLalu),
      sudahDibayar: true,
    ),
    DividenModel(
      id: idDividen8,
      idInvestasi: idInvestasi5,
      idInvestor: idInvestor2,
      jumlahDividen: 120000,
      tanggalPembagian: now.subtract(satuBulanLalu),
      sudahDibayar: true,
    ),
  ];
}

// ============================================================
// FUNGSI PEMBANTU
// ============================================================

/// Mendapatkan investasi berdasarkan ID investor
List<InvestasiModel> getInvestasiByIdInvestor(String idInvestor) {
  return daftarInvestasi.where((i) => i.idInvestor == idInvestor).toList();
}

/// Mendapatkan dividen berdasarkan ID investor
List<DividenModel> getDividenByIdInvestor(String idInvestor) {
  return daftarDividen.where((d) => d.idInvestor == idInvestor).toList();
}

/// Mendapatkan investasi berdasarkan ID
InvestasiModel? getInvestasiById(String id) {
  try {
    return daftarInvestasi.firstWhere((i) => i.id == id);
  } catch (e) {
    return null;
  }
}

/// Mendapatkan dividen berdasarkan ID
DividenModel? getDividenById(String id) {
  try {
    return daftarDividen.firstWhere((d) => d.id == id);
  } catch (e) {
    return null;
  }
}

/// Menghitung total modal investor berdasarkan ID investor
double getTotalModalInvestor(String idInvestor) {
  return daftarInvestasi
      .where((i) => i.idInvestor == idInvestor)
      .fold(0.0, (sum, i) => sum + i.jumlahModal);
}

/// Menghitung total lembar investor berdasarkan ID investor
int getTotalLembarInvestor(String idInvestor) {
  return daftarInvestasi
      .where((i) => i.idInvestor == idInvestor)
      .fold(0, (sum, i) => sum + i.jumlahLembar);
}

/// Menghitung total persentase kepemilikan investor
double getTotalPersentaseInvestor(String idInvestor) {
  return daftarInvestasi
      .where((i) => i.idInvestor == idInvestor)
      .fold(0.0, (sum, i) => sum + i.persentaseKepemilikan);
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

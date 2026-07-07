// path: lib/data_dummy/dummy_investasi.dart

import 'package:wifi/data_dummy/dummy_pelanggan.dart';
import 'package:wifi/data_dummy/dummy_transaksi.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';

/// Data dummy untuk investasi

// ============================================================
// ID INVESTASI
// ============================================================
const String idInvestasi1 = 'investasi-001';
const String idInvestasi2 = 'investasi-002';
const String idInvestasi3 = 'investasi-003';
const String idInvestasi4 = 'investasi-004';
const String idInvestasi5 = 'investasi-005';
const String idInvestasi6 = 'investasi-006';
const String idInvestasi7 = 'investasi-007';

// ============================================================
// DATA INVESTASI DUMMY
// ============================================================

/// Daftar investasi untuk semua investor
List<InvestasiModel> get daftarInvestasi {
  final now = DateTime.now();
  final satuBulanLalu = now.subtract(const Duration(days: 30));
  final duaBulanLalu = now.subtract(const Duration(days: 60));
  final tigaBulanLalu = now.subtract(const Duration(days: 90));
  final empatBulanLalu = now.subtract(const Duration(days: 120));
  final limaBulanLalu = now.subtract(
    const Duration(days: 150),
  ); // ✅ Perbaikan: gunakan final, bukan const

  return [
    // ============================================================
    // INVESTASI INVESTOR 1 (Budi Santoso)
    // ============================================================
    InvestasiModel(
      id: idInvestasi1,
      idInvestor: idInvestor1,
      idTransaksi: idTransaksi1,
      jumlahModal: 5000000,
      jumlahLembar: 50,
      tanggalInvestasi: duaBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),
    InvestasiModel(
      id: idInvestasi2,
      idInvestor: idInvestor1,
      idTransaksi: idTransaksi2,
      jumlahModal: 2000000,
      jumlahLembar: 20,
      tanggalInvestasi: satuBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),
    InvestasiModel(
      id: idInvestasi3,
      idInvestor: idInvestor1,
      idTransaksi: idTransaksi4,
      jumlahModal: 1500000,
      jumlahLembar: 15,
      tanggalInvestasi: limaBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),

    // ============================================================
    // INVESTASI INVESTOR 2
    // ============================================================
    InvestasiModel(
      id: idInvestasi4,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi5,
      jumlahModal: 7500000,
      jumlahLembar: 75,
      tanggalInvestasi: tigaBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),
    InvestasiModel(
      id: idInvestasi5,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi7,
      jumlahModal: 3000000,
      jumlahLembar: 30,
      tanggalInvestasi:
          empatBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),
    InvestasiModel(
      id: idInvestasi6,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi9,
      jumlahModal: 1000000,
      jumlahLembar: 10,
      tanggalInvestasi: duaBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),
    InvestasiModel(
      id: idInvestasi7,
      idInvestor: idInvestor2,
      idTransaksi: idTransaksi4,
      jumlahModal: 2000000,
      jumlahLembar: 20,
      tanggalInvestasi: satuBulanLalu, // ✅ Perbaikan: gunakan variabel langsung
    ),
  ];
}

// ============================================================
// FUNGSI PEMBANTU INVESTASI
// ============================================================

/// Mendapatkan investasi berdasarkan ID investor
List<InvestasiModel> getInvestasiByIdInvestor(String idInvestor) {
  return daftarInvestasi.where((i) => i.idInvestor == idInvestor).toList();
}

/// Mendapatkan investasi berdasarkan ID
InvestasiModel? getInvestasiById(String id) {
  try {
    return daftarInvestasi.firstWhere((i) => i.id == id);
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

/// Menghitung total modal semua investasi
double getTotalModalSemuaInvestasi() {
  return daftarInvestasi.fold(0.0, (sum, i) => sum + i.jumlahModal);
}

/// Menghitung total lembar semua investasi
int getTotalLembarSemuaInvestasi() {
  return daftarInvestasi.fold(0, (sum, i) => sum + i.jumlahLembar);
}

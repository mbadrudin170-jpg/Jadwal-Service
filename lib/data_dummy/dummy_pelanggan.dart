// path: lib/data_dummy/dummy_pelanggan.dart

import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';

/// Data dummy untuk pelanggan

// ID tetap untuk memudahkan testing
const String idBudi = 'Budi-Santoso-id';
const String idSiti = 'Siti-Aminah-id';
const String idAgus = 'Agus-Setiawan-id';
const String idDewi = 'Dewi-Purnama-id';
const String idAndi = 'Andi-Pratama-id';
const String idRina = 'Rina-Wahyuni-id';
const String idJoko = 'Joko-Widodo-id';
const String idMaya = 'Maya-Sari-id';
const String idRudi = 'Rudi-Hartono-id';
const String idLisa = 'Lisa-Anggraini-id';

// ✅ ID INVESTOR (5 Investor)
const String idInvestor1 = 'Investor-Satu-id';
const String idInvestor2 = 'Investor-Dua-id';
const String idInvestor3 = 'Investor-Tiga-id';
const String idInvestor4 = 'Investor-Empat-id';
const String idInvestor5 = 'Investor-Lima-id';

/// Daftar pelanggan dummy (SEMUA DATA TETAP ADA)
List<PelangganModel> get daftarPelanggan => [
  // ============================================================
  // DATA USER BIASA (TETAP ADA)
  // ============================================================
  const PelangganModel(
    id: idBudi,
    nama: 'Budi Santoso',
    telepon: '08568050170',
    kataSandi: '100',
    alamat: 'Jl. Merdeka No. 10, Jakarta',
    macAddress: '00:1B:44:11:3A:B7',
    role: AppRole.investor,
  ),
  const PelangganModel(
    id: idSiti,
    nama: 'Siti Aminah',
    telepon: '081298765432',
    kataSandi: 'siti123',
    alamat: 'Jl. Pahlawan No. 25, Surabaya',
    macAddress: '00:1B:44:11:3A:B8',
  ),
  const PelangganModel(
    id: idAgus,
    nama: 'Agus Setiawan',
    telepon: '081355577788',
    kataSandi: 'agus123',
    alamat: 'Jl. Kemerdekaan No. 5, Bandung',
    macAddress: '00:1B:44:11:3A:B9',
  ),
  const PelangganModel(
    id: idDewi,
    nama: 'Dewi Purnama',
    telepon: '081278901234',
    kataSandi: 'dewi123',
    alamat: 'Jl. Diponegoro No. 12, Yogyakarta',
    macAddress: '00:1B:44:11:3A:C0',
  ),
  const PelangganModel(
    id: idAndi,
    nama: 'Andi Pratama',
    telepon: '081289012345',
    kataSandi: 'andi123',
    alamat: 'Jl. Sudirman No. 8, Makassar',
    macAddress: '00:1B:44:11:3A:C1',
  ),
  const PelangganModel(
    id: idRina,
    nama: 'Rina Wahyuni',
    telepon: '081390123456',
    kataSandi: 'rina123',
    alamat: 'Jl. Gatot Subroto No. 15, Medan',
    macAddress: '00:1B:44:11:3A:C2',
  ),
  const PelangganModel(
    id: idJoko,
    nama: 'Joko Widodo',
    telepon: '081401234567',
    kataSandi: 'joko123',
    alamat: 'Jl. MH Thamrin No. 20, Jakarta',
    macAddress: '00:1B:44:11:3A:C3',
  ),
  const PelangganModel(
    id: idMaya,
    nama: 'Maya Sari',
    telepon: '081412345678',
    kataSandi: 'maya123',
    alamat: 'Jl. Asia Afrika No. 30, Bandung',
    macAddress: '00:1B:44:11:3A:C4',
  ),
  const PelangganModel(
    id: idRudi,
    nama: 'Rudi Hartono',
    telepon: '081423456789',
    kataSandi: 'rudi123',
    alamat: 'Jl. Pemuda No. 7, Semarang',
    macAddress: '00:1B:44:11:3A:C5',
  ),
  const PelangganModel(
    id: idLisa,
    nama: 'Lisa Anggraini',
    telepon: '081434567890',
    kataSandi: 'lisa123',
    alamat: 'Jl. Kartini No. 3, Bali',
    macAddress: '00:1B:44:11:3A:C6',
  ),

  // ============================================================
  // ✅ DATA INVESTOR (5 INVESTOR)
  // ============================================================
  const PelangganModel(
    id: idInvestor1,
    nama: 'Investor Satu',
    telepon: '08568050170',
    kataSandi: 'investor1',
    alamat: 'Jl. Investasi No. 1, Jakarta',
    macAddress: '00:1B:44:11:3A:D1',
    role: AppRole.investor,
  ),
  const PelangganModel(
    id: idInvestor2,
    nama: 'Investor Dua',
    telepon: '081234567892',
    kataSandi: 'investor2',
    alamat: 'Jl. Investasi No. 2, Surabaya',
    macAddress: '00:1B:44:11:3A:D2',
    role: AppRole.investor,
  ),
  const PelangganModel(
    id: idInvestor3,
    nama: 'Investor Tiga',
    telepon: '081234567893',
    kataSandi: 'investor3',
    alamat: 'Jl. Investasi No. 3, Bandung',
    macAddress: '00:1B:44:11:3A:D3',
    role: AppRole.investor,
  ),
  const PelangganModel(
    id: idInvestor4,
    nama: 'Investor Empat',
    telepon: '081234567894',
    kataSandi: 'investor4',
    alamat: 'Jl. Investasi No. 4, Yogyakarta',
    macAddress: '00:1B:44:11:3A:D4',
    role: AppRole.investor,
  ),
  const PelangganModel(
    id: idInvestor5,
    nama: 'Investor Lima',
    telepon: '081234567895',
    kataSandi: 'investor5',
    alamat: 'Jl. Investasi No. 5, Makassar',
    macAddress: '00:1B:44:11:3A:D5',
    role: AppRole.investor,
  ),
];

/// Mendapatkan pelanggan berdasarkan ID
PelangganModel? getPelangganById(String id) {
  try {
    return daftarPelanggan.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
}

/// Mendapatkan pelanggan berdasarkan nama
PelangganModel? getPelangganByName(String nama) {
  try {
    return daftarPelanggan.firstWhere(
      (p) => p.nama.toLowerCase() == nama.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
}

/// Mendapatkan pelanggan berdasarkan role
List<PelangganModel> getPelangganByRole(AppRole role) {
  return daftarPelanggan.where((p) => p.role == role).toList();
}

/// Mendapatkan daftar investor saja
List<PelangganModel> getDaftarInvestor() {
  return daftarPelanggan.where((p) => p.role == AppRole.investor).toList();
}

/// Mendapatkan pelanggan dengan total poin (simulasi)
Map<String, int> get totalPoin {
  return {
    idBudi: 150,
    idSiti: 200,
    idAgus: 75,
    idDewi: 300,
    idAndi: 50,
    idRina: 120,
    idJoko: 500,
    idMaya: 80,
    idRudi: 250,
    idLisa: 100,
    // ✅ Poin untuk 5 investor
    idInvestor1: 1000,
    idInvestor2: 750,
    idInvestor3: 600,
    idInvestor4: 400,
    idInvestor5: 200,
  };
}

/// Mendapatkan poin pelanggan berdasarkan ID
int getPoinById(String id) {
  return totalPoin[id] ?? 0;
}

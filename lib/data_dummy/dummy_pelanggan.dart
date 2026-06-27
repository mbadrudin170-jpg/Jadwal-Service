// path lib/data_dummy/dummy_pelanggan.dart

import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';

/// Data dummy untuk pelanggan
class DummyPelanggan {
  // ID tetap untuk memudahkan testing
  static const String idBudi = 'Budi-Santoso-id';
  static const String idSiti = 'Siti-Aminah-id';
  static const String idAgus = 'Agus-Setiawan-id';
  static const String idDewi = 'Dewi-Purnama-id';
  static const String idAndi = 'Andi-Pratama-id';
  static const String idRina = 'Rina-Wahyuni-id';
  static const String idJoko = 'Joko-Widodo-id';
  static const String idMaya = 'Maya-Sari-id';
  static const String idRudi = 'Rudi-Hartono-id';
  static const String idLisa = 'Lisa-Anggraini-id';

  /// Daftar pelanggan dummy
  static List<PelangganModel> get daftarPelanggan => [
    const PelangganModel(
      id: idBudi,
      nama: 'Budi Santoso',
      telepon: '081234567890',
      kataSandi: 'budi123',
      alamat: 'Jl. Merdeka No. 10, Jakarta',
      macAddress: '00:1B:44:11:3A:B7',
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
  ];

  /// Mendapatkan pelanggan berdasarkan ID
  static PelangganModel? getById(String id) {
    try {
      return daftarPelanggan.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan pelanggan berdasarkan nama
  static PelangganModel? getByName(String nama) {
    try {
      return daftarPelanggan.firstWhere(
        (p) => p.nama.toLowerCase() == nama.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan pelanggan dengan total poin (simulasi)
  static Map<String, int> get totalPoin {
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
    };
  }

  /// Mendapatkan poin pelanggan berdasarkan ID
  static int getPoinById(String id) {
    return totalPoin[id] ?? 0;
  }
}

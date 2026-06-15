// path: lib/data_dummy/data_dummy.dart

import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';

/// Kelas penyedia data dummy untuk keperluan testing UI dan pengembangan.
class DataDummy {
  // --- ID yang Dapat Digunakan Kembali ---
  static const String customerBudiId = 'Budi-Santoso-id';
  static const String customerSitiId = 'Siti-Aminah-id';
  static const String agusSetiawanId = 'Agus-Setiawan-id';
  static const String paketHematId = 'Paket-Hemat-10-id';
  static const String paketPremiumId = 'Paket-Premium-50-id';
  static const String paketGamerId = 'Paket-Gamer-100-id';
  static const String walletBudiId = 'wallet-Budi-id';
  static const String walletSitiId = 'wallet-Siti-id';
  static const String kategoriPembayaranId = 'kategori-pembayaran-id';
  static const String kategoriLainnyaId = 'kategori-lainnya-id';
  static const String subKategoriInternetId = 'sub-kategori-internet-id';
  static const String subKategoriTransportId = 'sub-kategori-transport-id';
  static const String transactionBudiId = 'trans-budi-id';
  static const String transactionSitiId = 'trans-siti-id';
  static const String activeCustomerBudiId = 'active-budi-id';
  static const String activeCustomerSitiId = 'active-siti-id';
  static const String feedbackBudiId = 'feedback-budi-id';
  static const String feedbackSitiId = 'feedback-siti-id';
  static const String apkAdminV1Id = 'admin-v1';
  static const String apkUserV1Id = 'user-v1';

  /// Daftar dummy untuk [OrderModel]
  static List<OrderModel> get orders => [
        OrderModel(
          id: 'ORD-001',
          customerId: customerBudiId,
          packageId: paketHematId,
          date: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        OrderModel(
          id: 'ORD-002',
          customerId: customerSitiId,
          packageId: paketPremiumId,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: StatusOrderEnum.diproses,
        ),
        OrderModel(
          id: 'ORD-003',
          customerId: agusSetiawanId,
          packageId: paketGamerId,
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: StatusOrderEnum.selesai,
        ),
      ];

  /// Daftar dummy untuk [PelangganModel]
  static List<PelangganModel> get customers => [
        PelangganModel(
            id: customerBudiId,
            name: 'Budi Santoso',
            phone: '081234567890',
            password: 'password123',
            address: 'Jl. Merdeka No. 10, Jakarta'),
        PelangganModel(
            id: customerSitiId,
            name: 'Siti Aminah',
            phone: '087654321098',
            password: 'password456',
            address: 'Jl. Pahlawan No. 25, Surabaya'),
        PelangganModel(
            id: agusSetiawanId,
            name: 'Agus Setiawan',
            phone: '089987654321',
            password: 'password789',
            address: 'Jl. Kemerdekaan No. 5, Bandung'),
      ];

  /// Daftar dummy untuk [PaketModel]
  static List<PaketModel> get packages => [
        const PaketModel(
          id: paketHematId,
          nama: 'Paket Hemat 10 Mbps',
          harga: 150000,
          durasi: 30,
          tipe: TipeDurasiPaket.days,
        ),
        const PaketModel(
          id: paketPremiumId,
          nama: 'Paket Premium 50 Mbps',
          harga: 350000,
          durasi: 30,
          tipe: TipeDurasiPaket.days,
        ),
        const PaketModel(
          id: paketGamerId,
          nama: 'Paket Gamer 100 Mbps',
          harga: 500000,
          durasi: 30,
          tipe: TipeDurasiPaket.days,
        ),
      ];

  /// Daftar dummy untuk [KategoriModel]
  static List<KategoriModel> get categories => [
        const KategoriModel(
            id: kategoriPembayaranId,
            nama: 'Pembayaran',
            tipe: TipeKategori.income),
        const KategoriModel(
            id: kategoriLainnyaId, nama: 'Lainnya', tipe: TipeKategori.expense),
      ];

  /// Daftar dummy untuk [SubCategoryModel]
  static List<SubCategoryModel> get subCategories => [
        SubCategoryModel(
          id: subKategoriInternetId,
          categoryId: kategoriPembayaranId,
          name: 'Internet',
        ),
        SubCategoryModel(
          id: subKategoriTransportId,
          categoryId: kategoriLainnyaId,
          name: 'Transportasi',
        ),
      ];

  /// Daftar dummy untuk [DompetModel]
  static List<DompetModel> get wallets => [
        const DompetModel(id: walletBudiId, nama: 'Dompet Budi', saldo: 500000),
        const DompetModel(id: walletSitiId, nama: 'Dompet Siti', saldo: 1000000),
      ];

  /// Daftar dummy untuk [TransaksiModel]
  static List<TransaksiModel> get transactions => [
        TransaksiModel(
          id: transactionBudiId,
          idDompet: walletBudiId,
          idKategori: kategoriPembayaranId,
          idSubKategori: subKategoriInternetId,
          tipe: TipeTransaksi.expense,
          jumlah: 150000,
          deskripsi: 'Pembayaran paket hemat',
          tanggal: DateTime.now(),
        ),
        TransaksiModel(
          id: transactionSitiId,
          idDompet: walletSitiId,
          idKategori: kategoriPembayaranId,
          idSubKategori: subKategoriInternetId,
          tipe: TipeTransaksi.expense,
          jumlah: 350000,
          deskripsi: 'Pembayaran paket premium',
          tanggal: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  /// Daftar dummy untuk [PelangganAktifModel]
  static List<PelangganAktifModel> get activeCustomers => [
        PelangganAktifModel(
          id: activeCustomerBudiId,
          idPelanggan: customerBudiId,
          idPaket: paketHematId,
          tanggalMulai: DateTime.now().subtract(const Duration(days: 10)),
          tanggalBerakhir: DateTime.now().add(const Duration(days: 20)),
          status: StatusPembayaran.paid,
        ),
        PelangganAktifModel(
          id: activeCustomerSitiId,
          idPelanggan: customerSitiId,
          idPaket: paketPremiumId,
          tanggalMulai: DateTime.now().subtract(const Duration(days: 5)),
          tanggalBerakhir: DateTime.now().add(const Duration(days: 25)),
          status: StatusPembayaran.paid,
        ),
      ];

  /// Daftar dummy untuk [FeedbackModel]
  static List<FeedbackModel> get feedbacks => [
        FeedbackModel(
          id: feedbackBudiId,
          userId: customerBudiId,
          content: 'Koneksi internet sangat stabil, terima kasih!',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        FeedbackModel(
          id: feedbackSitiId,
          userId: customerSitiId,
          content: 'Kecepatan download kadang melambat di malam hari.',
          date: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];

  /// Daftar dummy untuk [VersiApkModel]
  static List<VersiApkModel> get apkVersions => [
        const VersiApkModel(
          id: apkAdminV1Id,
          versiTerkahir: '1.0.0',
          catatanRilis: 'Versi pertama aplikasi admin.',
          nomorBuildTerakhir: {ArsitekturApk.arm64: 1},
          linkDownload: {
            ArsitekturApk.arm64: '/path/to/admin-v1.0.0.apk'
          },
          wajibUpdate: true,
        ),
        const VersiApkModel(
          id: apkUserV1Id,
          versiTerkahir: '1.0.1',
          catatanRilis: 'Perbaikan bug dan peningkatan performa.',
          nomorBuildTerakhir: {ArsitekturApk.arm64: 2},
          linkDownload: {ArsitekturApk.arm64: '/path/to/user-v1.0.1.apk'},
        ),
      ];

  /// Data dummy untuk [SettingsModel]
  static SettingsModel get settings => const SettingsModel(
        waktuOtomatisSinkroniasi: 12,
        waktuOtomatisHapusDataArsip: 90,
      );
}

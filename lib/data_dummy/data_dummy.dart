// path: lib/data_dummy/data_dummy.dart

import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/kategori/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/enum/status_order_enum.dart';
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
        const PelangganModel(
          id: customerBudiId,
          nama: 'Budi Santoso',
          telepon: '081234567890',
          kataSandi: 'password123',
          alamat: 'Jl. Merdeka No. 10, Jakarta',
          macAddress: '00:1B:44:11:3A:B7',
        ),
        const PelangganModel(
          id: customerSitiId,
          nama: 'Siti Aminah',
          telepon: '087654321098',
          kataSandi: 'password456',
          alamat: 'Jl. Pahlawan No. 25, Surabaya',
          macAddress: '00:1B:44:11:3A:B8',
        ),
        const PelangganModel(
          id: agusSetiawanId,
          nama: 'Agus Setiawan',
          telepon: '089987654321',
          kataSandi: 'password789',
          alamat: 'Jl. Kemerdekaan No. 5, Bandung',
          macAddress: '00:1B:44:11:3A:B9',
        ),
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
            tipe: TipeKategori.income,
            idSubKategori: []),
        const KategoriModel(
            id: kategoriLainnyaId,
            nama: 'Lainnya',
            tipe: TipeKategori.expense,
            idSubKategori: []),
      ];

  /// Daftar dummy untuk [SubCategoryModel]
  static List<SubKategoriModel> get subCategories => [
        const SubKategoriModel(
          id: subKategoriInternetId,
          idKategori: kategoriPembayaranId,
          nama: 'Internet',
        ),
        const SubKategoriModel(
          id: subKategoriTransportId,
          idKategori: kategoriLainnyaId,
          nama: 'Transportasi',
        ),
      ];

  /// Daftar dummy untuk [DompetModel]
  static List<DompetModel> get wallets => [
        const DompetModel(id: walletBudiId, nama: 'Dompet Budi', saldo: 500000),
        const DompetModel(
            id: walletSitiId, nama: 'Dompet Siti', saldo: 1000000),
      ];

  /// Daftar dummy untuk [TransaksiModel]
  static List<TransaksiModel> get transactions => [
        TransaksiModel(
            id: transactionBudiId,
            idDompet: walletBudiId,
            idKategori: kategoriPembayaranId,
            tipe: TipeTransaksi.expense,
            jumlah: 150000,
            deskripsi: 'Pembayaran paket hemat',
            tanggal: DateTime.now(),
            statusPembayaran: StatusPembayaran.paid,
            idPelanggan: customerBudiId,
            idPaket: paketHematId),
        TransaksiModel(
          id: transactionSitiId,
          idDompet: walletSitiId,
          idKategori: kategoriPembayaranId,
          tipe: TipeTransaksi.expense,
          jumlah: 350000,
          deskripsi: 'Pembayaran paket premium',
          tanggal: DateTime.now().subtract(const Duration(days: 1)),
          statusPembayaran: StatusPembayaran.paid,
          idPelanggan: customerSitiId,
          idPaket: paketPremiumId,
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
          idTransaksi: transactionBudiId,
        ),
        PelangganAktifModel(
          id: activeCustomerSitiId,
          idPelanggan: customerSitiId,
          idPaket: paketPremiumId,
          tanggalMulai: DateTime.now().subtract(const Duration(days: 5)),
          tanggalBerakhir: DateTime.now().add(const Duration(days: 25)),
          status: StatusPembayaran.paid,
          idTransaksi: transactionSitiId,
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
            linkDownload: {ArsitekturApk.arm64: '/path/to/admin-v1.0.0.apk'},
            wajibUpdate: true,
            linkYoutubeTutorial: 'https://youtu.be/dQw4w9WgXcQ'),
      ];

  /// Data dummy untuk [SettingsModel]
  static SettingsModel get settings => const SettingsModel(
        waktuOtomatisSinkroniasi: 12,
        waktuOtomatisHapusDataArsip: 90,
      );
}

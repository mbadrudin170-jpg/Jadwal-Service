// path: lib/data_dummy/data_dummy.dart

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
          status: StatusOrderEnum.baru,
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

  /// Daftar dummy untuk [CustomerModel]
  static List<CustomerModel> get customers => [
        CustomerModel(
            id: customerBudiId,
            name: 'Budi Santoso',
            phone: '081234567890',
            password: 'password123',
            address: 'Jl. Merdeka No. 10, Jakarta'),
        CustomerModel(
            id: customerSitiId,
            name: 'Siti Aminah',
            phone: '087654321098',
            password: 'password456',
            address: 'Jl. Pahlawan No. 25, Surabaya'),
        CustomerModel(
            id: agusSetiawanId,
            name: 'Agus Setiawan',
            phone: '089987654321',
            password: 'password789',
            address: 'Jl. Kemerdekaan No. 5, Bandung'),
      ];

  /// Daftar dummy untuk [PackageModel]
  static List<PackageModel> get packages => [
        PackageModel(
          id: paketHematId,
          name: 'Paket Hemat 10 Mbps',
          price: 150000,
          duration: 30,
          type: DurationType.days,
        ),
        PackageModel(
          id: paketPremiumId,
          name: 'Paket Premium 50 Mbps',
          price: 350000,
          duration: 30,
          type: DurationType.days,
        ),
        PackageModel(
          id: paketGamerId,
          name: 'Paket Gamer 100 Mbps',
          price: 500000,
          duration: 30,
          type: DurationType.days,
        ),
      ];

  /// Daftar dummy untuk [CategoryModel]
  static List<CategoryModel> get categories => [
        CategoryModel(
            id: kategoriPembayaranId,
            name: 'Pembayaran',
            type: CategoryType.income),
        CategoryModel(
            id: kategoriLainnyaId, name: 'Lainnya', type: CategoryType.expense),
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

  /// Daftar dummy untuk [WalletModel]
  static List<WalletModel> get wallets => [
        WalletModel(id: walletBudiId, name: 'Dompet Budi', balance: 500000),
        WalletModel(id: walletSitiId, name: 'Dompet Siti', balance: 1000000),
      ];

  /// Daftar dummy untuk [TransactionModel]
  static List<TransactionModel> get transactions => [
        TransactionModel(
          id: transactionBudiId,
          walletId: walletBudiId,
          categoryId: kategoriPembayaranId,
          subCategoryId: subKategoriInternetId,
          type: TransactionType.expense,
          amount: 150000,
          description: 'Pembayaran paket hemat',
          date: DateTime.now(),
        ),
        TransactionModel(
          id: transactionSitiId,
          walletId: walletSitiId,
          categoryId: kategoriPembayaranId,
          subCategoryId: subKategoriInternetId,
          type: TransactionType.expense,
          amount: 350000,
          description: 'Pembayaran paket premium',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  /// Daftar dummy untuk [ActiveCustomerModel]
  static List<ActiveCustomerModel> get activeCustomers => [
        ActiveCustomerModel(
          id: activeCustomerBudiId,
          customerId: customerBudiId,
          packageId: paketHematId,
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 20)),
          status: PaymentStatus.paid,
        ),
        ActiveCustomerModel(
          id: activeCustomerSitiId,
          customerId: customerSitiId,
          packageId: paketPremiumId,
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          status: PaymentStatus.paid,
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

  /// Daftar dummy untuk [ApkVersionModel]
  static List<ApkVersionModel> get apkVersions => [
        ApkVersionModel(
          id: apkAdminV1Id,
          latestVersion: '1.0.0',
          releaseNotes: 'Versi pertama aplikasi admin.',
          latestBuildNumber: const {ApkArchitectureEnum.arm64: 1},
          downloadLinks: const {
            ApkArchitectureEnum.arm64: '/path/to/admin-v1.0.0.apk'
          },
          isUpdateRequired: true,
        ),
        ApkVersionModel(
          id: apkUserV1Id,
          latestVersion: '1.0.1',
          releaseNotes: 'Perbaikan bug dan peningkatan performa.',
          latestBuildNumber: const {ApkArchitectureEnum.arm64: 2},
          downloadLinks: const {
            ApkArchitectureEnum.arm64: '/path/to/user-v1.0.1.apk'
          },
        ),
      ];

  /// Data dummy untuk [SettingsModel]
  static SettingsModel get settings => SettingsModel(
        autoSyncInterval: 12,
        autoDeleteArchiveDays: 90,
      );
}

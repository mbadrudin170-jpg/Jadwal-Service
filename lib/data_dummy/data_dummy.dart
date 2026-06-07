// path: lib/data_dummy/data_dummy.dart

import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/order_model.dart';

/// Kelas penyedia data dummy untuk keperluan testing UI dan pengembangan.
class DataDummy {
  /// Daftar dummy untuk [OrderModel]
  static List<OrderModel> get orders => [
        OrderModel(
          id: 'ORD-001',
          customerId: 'Budi Santoso',
          packageId: 'Paket Hemat 10 Mbps',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          status: StatusOrderEnum.baru,
        ),
        OrderModel(
          id: 'ORD-002',
          customerId: 'Siti Aminah',
          packageId: 'Paket Premium 50 Mbps',
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: StatusOrderEnum.diproses,
        ),
        OrderModel(
          id: 'ORD-003',
          customerId: 'Agus Setiawan',
          packageId: 'Paket Gamer 100 Mbps',
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: StatusOrderEnum.selesai,
        ),
        OrderModel(
          id: 'ORD-004',
          customerId: 'Rina Permata',
          packageId: 'Paket Hemat 10 Mbps',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          status: StatusOrderEnum.ditolak,
        ),
        OrderModel(
          id: 'ORD-005',
          customerId: 'Eko Prasetyo',
          packageId: 'Paket Bisnis 200 Mbps',
          date: DateTime.now().subtract(const Duration(minutes: 30)),
          status: StatusOrderEnum.baru,
        ),
      ];
}

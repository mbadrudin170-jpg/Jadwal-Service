// path: lib/fitur/order/ui/user/order_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/widget/package_name.dart';

abstract class IOrderOperation {
  Stream<List<OrderModel>> getAllOrdersStream();
  Future<int> countOrdersByStatus(StatusOrderEnum status);
}

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _UserOrderPageState();
}

class _UserOrderPageState extends ConsumerState<OrderPage> {
  String _filterAktif = StatusOrderEnum.selesai.name;

  @override
  Widget build(BuildContext context) {
    final appRole = ref.watch(appRoleProvider);
    final IOrderOperation orderOperation = appRole == AppRole.admin
        ? ref.watch(orderOperationProvider)
        : ref.watch(orderOpFirebaseProvider);

    final dataStream = orderOperation.getAllOrdersStream();

    Log.info(
        '[Pembangunan UI] ✅ Membangun UI untuk UserOrderPage, menampilkan daftar pesanan realtime.');
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _listTombolFilter(),
            Expanded(child: _listPesanan(dataStream)),
          ],
        ),
      ),
    );
  }

  // 2. Memperbarui _listTombolFilter untuk memanggil count dan meneruskannya ke tombol
  Widget _listTombolFilter() {
    final appRole = ref.watch(appRoleProvider);
    final IOrderOperation orderOperation = appRole == AppRole.admin
        ? ref.watch(orderOperationProvider)
        : ref.watch(orderOpFirebaseProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 12.0, // Memberi spasi antar tombol
          children: [
            _tombolTipe(
                orderOperation.countOrdersByStatus(StatusOrderEnum.baru),
                StatusOrderEnum.baru,
                isActive: _filterAktif == StatusOrderEnum.baru.name),
            _tombolTipe(
                orderOperation.countOrdersByStatus(StatusOrderEnum.diproses),
                StatusOrderEnum.diproses,
                isActive: _filterAktif == StatusOrderEnum.diproses.name),
            _tombolTipe(
                orderOperation.countOrdersByStatus(StatusOrderEnum.selesai),
                StatusOrderEnum.selesai,
                isActive: _filterAktif == StatusOrderEnum.selesai.name),
            _tombolTipe(
                orderOperation.countOrdersByStatus(StatusOrderEnum.ditolak),
                StatusOrderEnum.ditolak,
                isActive: _filterAktif == StatusOrderEnum.ditolak.name),
          ],
        ),
      ),
    );
  }

  // 3. Memperbarui _tombolTipe untuk menerima Future<int> dan menggunakan FutureBuilder
  Widget _tombolTipe(Future<int> futureCount, StatusOrderEnum status,
      {required bool isActive}) {
    final label = status.displayName;
    return InkWell(
      // 4. Logika onTap tetap sama
      onTap: () {
        if (!isActive) {
          setState(() {
            _filterAktif = status.name;
            Log.info('Filter pesanan diubah menjadi: $_filterAktif');
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
        child: Wrap(
          spacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FutureBuilder<int>(
              future: futureCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == 0) {
                  return const SizedBox
                      .shrink(); // Tidak menampilkan badge jika 0 atau error
                }
                final count = snapshot.data!;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.blue : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listPesanan(Stream<List<OrderModel>> dataStream) {
    return StreamBuilder<List<OrderModel>>(
      stream: dataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          Log.error('Error memuat pesanan', e: snapshot.error);
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        final allOrders = snapshot.data ?? [];

        final filteredOrders = allOrders.where((order) {
          if (_filterAktif == StatusOrderEnum.selesai.name) {
            return order.status == StatusOrderEnum.selesai;
          }
          if (_filterAktif == StatusOrderEnum.diproses.name) {
            return order.status == StatusOrderEnum.diproses;
          }
          if (_filterAktif == StatusOrderEnum.baru.name) {
            return order.status == StatusOrderEnum.baru;
          }
          if (_filterAktif == StatusOrderEnum.ditolak.name) {
            return order.status == StatusOrderEnum.ditolak;
          }
          return true;
        }).toList();

        if (filteredOrders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan ditemukan.'));
        }
        final paketOpFirebase = ref.watch(packageOpFirebaseProvider);
        return ListView.builder(
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return ListTile(
              title: Row(
                children: [
                  const Text('Paket: '),
                  PackageNameWidget(
                    packageFuture:
                        paketOpFirebase.getPackageById(order.packageId),
                  ),
                ],
              ),
              subtitle: Text('Status: ${order.status.name}'),
            );
          },
        );
      },
    );
  }
}

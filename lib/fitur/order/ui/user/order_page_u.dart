// path: lib/fitur/order/ui/user/order_page_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/widget/package_name.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class UserOrderPage extends ConsumerStatefulWidget {
  const UserOrderPage({super.key});

  @override
  ConsumerState<UserOrderPage> createState() => _UserOrderPageState();
}

class _UserOrderPageState extends ConsumerState<UserOrderPage> {
  // 1. Mengubah state dari boolean menjadi String untuk menampung filter yang aktif
  String _filterAktif =
      StatusOrderEnum.selesai.name; // Filter default saat halaman dibuka

  @override
  Widget build(BuildContext context) {
    final orderOpFirebase = ref.watch(orderOpFirebaseProvider);
    final dataStream = orderOpFirebase.getAll();
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

  // 2. Memperbarui _listTombolFilter untuk mengontrol status aktif setiap tombol
  Widget _listTombolFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Menggunakan Wrap karena Row tidak punya properti 'spacing'
        child: Wrap(
          spacing: 12.0, // Memberi spasi antar tombol
          children: [
            _tombolTipe('99+', StatusOrderEnum.selesai.displayName,
                isActive: _filterAktif == StatusOrderEnum.baru.name),
            _tombolTipe('', StatusOrderEnum.diproses.displayName,
                isActive: _filterAktif == StatusOrderEnum.diproses.name),
            _tombolTipe('10', StatusOrderEnum.baru.displayName,
                isActive: _filterAktif == StatusOrderEnum.selesai.name),
            _tombolTipe('10', StatusOrderEnum.ditolak.displayName,
                isActive: _filterAktif == StatusOrderEnum.ditolak.name),
          ],
        ),
      ),
    );
  }

  // 3. Memperbarui _tombolTipe untuk menangani state, onTap, dan tampilan
  Widget _tombolTipe(String info, String label, {required bool isActive}) {
    return InkWell(
      // 4. Memperbarui logika onTap untuk mengubah filter yang aktif
      onTap: () {
        // Hanya update state jika tombol yang ditekan belum aktif
        if (!isActive) {
          setState(() {
            _filterAktif = label;
            Log.info('Filter pesanan diubah menjadi: $_filterAktif');
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // 5. Warna latar belakang dan border berubah berdasarkan status 'isActive'
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
        // Menggunakan Wrap karena Row tidak punya properti 'spacing'
        child: Wrap(
          spacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (info.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  info,
                  style: TextStyle(
                    color: isActive ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
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
final data =paketOpFirebase.getPackageStreamById(allOrders.pack)
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

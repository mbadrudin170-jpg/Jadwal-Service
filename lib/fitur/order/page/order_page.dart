// path: lib/fitur/order/page/order_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/provider/order_provider_gabungan.dart';
import 'package:wifi/shared/common/text.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/package_name.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  String _filterAktif = StatusOrderEnum.baru.name;

  Future<bool?> _konfirmasiOpsi(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin melanjutkan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ubahStatus(
    BuildContext context,
    OrderModel order,
    WidgetRef ref,
  ) {
    Log.info('Dialog $_ubahStatus muncul');
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tombolOpsiUbahStatus(
                  pageContext: context,
                  dialogContext: dialogContext,
                  label: StatusOrderEnum.selesai.displayName,
                  order: order,
                  status: StatusOrderEnum.selesai,
                ),
                _tombolOpsiUbahStatus(
                  pageContext: context,
                  dialogContext: dialogContext,
                  label: StatusOrderEnum.baru.displayName,
                  order: order,
                  status: StatusOrderEnum.baru,
                ),
                _tombolOpsiUbahStatus(
                  pageContext: context,
                  dialogContext: dialogContext,
                  label: StatusOrderEnum.diproses.displayName,
                  order: order,
                  status: StatusOrderEnum.diproses,
                ),
                _tombolOpsiUbahStatus(
                  pageContext: context,
                  dialogContext: dialogContext,
                  label: StatusOrderEnum.ditolak.displayName,
                  order: order,
                  status: StatusOrderEnum.ditolak,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDialog(BuildContext context, OrderModel order) {
    final appRole = ref.watch(appRoleProvider);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appRole == AppRole.admin)
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      unawaited(_ubahStatus(context, order, ref));
                    },
                    child: const Text('Ubah Status'),
                  ),
                TextButton(
                  child: const Text('Hapus'),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    final bool? dikonfirmasi = await _konfirmasiOpsi(context);
                    if (dikonfirmasi ?? false) {
                      try {
                        if (appRole == AppRole.admin) {
                          await ref
                              .read(orderOpSqliteProvider)
                              .softDeleteorder(order.id);
                        } else {
                          await ref
                              .read(orderOpFirebaseProvider)
                              .softDeleteOrder(order.id);
                        }
                        if (context.mounted) {
                          ToastUtil.success(context, 'Data berhasil dihapus');
                        }
                      } catch (e, st) {
                        Log.error('Gagal menghapus pesanan', e: e, s: st);
                        if (context.mounted) {
                          ToastUtil.error(context, 'Gagal menghapus pesanan');
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
        '[Pembangunan UI] ✅ Membangun UI untuk UserOrderPage, menampilkan daftar pesanan realtime.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _listTombolFilter(),
              _listPesanan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listTombolFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 12.0, // Memberi spasi antar tombol
          children: [
            _tombolTipe(StatusOrderEnum.baru,
                sedangAktif: _filterAktif == StatusOrderEnum.baru.name),
            _tombolTipe(StatusOrderEnum.diproses,
                sedangAktif: _filterAktif == StatusOrderEnum.diproses.name),
            _tombolTipe(StatusOrderEnum.selesai,
                sedangAktif: _filterAktif == StatusOrderEnum.selesai.name),
            _tombolTipe(StatusOrderEnum.ditolak,
                sedangAktif: _filterAktif == StatusOrderEnum.ditolak.name),
          ],
        ),
      ),
    );
  }

  Widget _tombolTipe(StatusOrderEnum status, {required bool sedangAktif}) {
    final orderAsync = ref.watch(orderProvider);
    final label = status.displayName;

    return InkWell(
      onTap: () {
        if (!sedangAktif) {
          setState(() {
            _filterAktif = status.name;
            Log.info('Filter pesanan diubah menjadi: $_filterAktif');
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              sedangAktif ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sedangAktif
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
        ),
        child: Wrap(
          spacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            orderAsync.when(
              skipLoadingOnReload: true,
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e $s'),
              data: (orderState) {
                final jumlah =
                    orderState.orders.where((o) => o.status == status).length;
                if (jumlah == 0) return const SizedBox.shrink();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sedangAktif
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TeksIsiKecil(
                    jumlah > 99 ? '99+' : jumlah.toString(),
                    warna: sedangAktif
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                );
              },
            ),
            TeksIsiBesar(
              label,
              warna: sedangAktif
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
              tebalFont: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _listPesanan() {
    final orderAsync = ref.watch(orderProvider);

    return orderAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err')),
      data: (orderState) {
        final allOrders = orderState.orders;

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

        final paketOpFirebase = ref.watch(paketOpFirebaseProvider);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return ListTile(
              onLongPress: () => _showDialog(context, order),
              title: Row(
                children: [
                  const Text('Paket: '),
                  PackageNameWidget(
                    paketFuture:
                        paketOpFirebase.ambilBerdasarkanId(order.idPaket),
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

  Widget _tombolOpsiUbahStatus(
      {required String label,
      required OrderModel order,
      required StatusOrderEnum status,
      required BuildContext dialogContext,
      required BuildContext pageContext}) {
    return TextButton(
      onPressed: () async {
        Navigator.of(dialogContext).pop();
        final bool? dikonfirmasi = await _konfirmasiOpsi(pageContext);
        if (dikonfirmasi ?? false) {
          try {
            await ref
                .read(orderOpSqliteProvider)
                .updateStatusOrder(order.id, status);
            ref.invalidate(orderProvider);

            if (pageContext.mounted) {
              ToastUtil.success(pageContext, 'Data berhasil diperbarui');
            }
          } on Exception catch (e, st) {
            // 1. Catat log error secara detail untuk developer.
            Log.error('Gagal memperbarui status pesanan', e: e, s: st, data: {
              'orderId': order.id,
              'newStatus': status,
            });

            // 2. Tampilkan pesan error yang ramah kepada pengguna.
            if (pageContext.mounted) {
              ToastUtil.error(
                pageContext,
                'Terjadi kesalahan saat memperbarui status pesanan.',
              );
            }
          }
        }
      },
      child: TeksIsiSedang(label),
    );
  }
}

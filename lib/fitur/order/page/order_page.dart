// path: lib/fitur/order/page/order_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_global.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/package_name.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  String _filterAktif = StatusOrderEnum.baru.name;

  @override
  void initState() {
    super.initState();
    Log.info('OrderPage initState dipanggil');
  }

  @override
  void dispose() {
    Log.info('OrderPage dispose dipanggil');
    super.dispose();
  }

  /// ✅ PERBAIKAN 1: Fungsi konfirmasi sekarang pakai await dengan benar
  Future<bool?> _konfirmasiOpsi(BuildContext context) async {
    Log.info('_konfirmasiOpsi dipanggil');
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin melanjutkan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Log.info('_konfirmasiOpsi: pengguna memilih Batal');
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info('_konfirmasiOpsi: pengguna memilih Iya');
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  /// ✅ PERBAIKAN 2: Fungsi ubah status sekarang pakai await dengan benar
  Future<void> _ubahStatus(
    BuildContext context,
    OrderModel order,
    WidgetRef ref,
  ) async {
    Log.info('_ubahStatus dipanggil untuk orderId: ${order.id}');
    try {
      await showDialog<void>(
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
    } on Exception catch (e, st) {
      Log.error('Gagal menampilkan dialog ubah status', e: e, s: st);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal membuka dialog ubah status');
      }
    }
  }

  Future<bool?> _showDialog(BuildContext context, OrderModel order) async {
    try {
      return await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ref.isAdmin)
                    TextButton(
                      onPressed: () {
                        Log.info(
                          '_showDialog: admin memilih Ubah Status untuk orderId: ${order.id}',
                        );
                        Navigator.of(dialogContext).pop();
                        try {
                          _ubahStatus(context, order, ref);
                        } on Exception catch (e, st) {
                          Log.error('Gagal memanggil _ubahStatus', e: e, s: st);
                        }
                      },
                      child: const Text('Ubah Status'),
                    ),
                  TextButton(
                    child: const Text('Hapus'),
                    onPressed: () async {
                      Log.info(
                        '_showDialog: pengguna memilih Hapus untuk orderId: ${order.id}',
                      );
                      Navigator.of(dialogContext).pop();
                      final bool? dikonfirmasi = await _konfirmasiOpsi(context);
                      if (dikonfirmasi == true) {
                        Log.info(
                          '_showDialog: konfirmasi hapus disetujui untuk orderId: ${order.id}',
                        );
                        try {
                          await ref
                              .read(orderOpGlobalProvider)
                              .softDelete(order.id);
                          Log.info(
                            '_showDialog: order berhasil dihapus orderId: ${order.id}',
                          );
                          ref.invalidate(daftarPesananProvider);
                          ref.invalidate(orderProvider);

                          if (context.mounted) {
                            ToastUtil.success(context, 'Data berhasil dihapus');
                          }
                        } on Exception catch (e, st) {
                          Log.error(
                            '_showDialog: gagal menghapus order',
                            e: e,
                            s: st,
                          );
                          if (context.mounted) {
                            ToastUtil.error(context, 'Gagal menghapus pesanan');
                          }
                        }
                      } else {
                        Log.info(
                          '_showDialog: konfirmasi hapus dibatalkan untuk orderId: ${order.id}',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } on Exception catch (e, st) {
      Log.error('Gagal menampilkan dialog opsi', e: e, s: st);
      if (context.mounted) {
        ToastUtil.error(context, 'Gagal membuka opsi');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('OrderPage build dipanggil, filterAktif: $_filterAktif');

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _daftarTombolFilter(),
            Expanded(child: _daftarPesanan()),
          ],
        ),
      ),
    );
  }

  Widget _daftarTombolFilter() {
    Log.info('_listTombolFilter dipanggil');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 12.0,
          children: [
            _tombolTipe(
              StatusOrderEnum.baru,
              sedangAktif: _filterAktif == StatusOrderEnum.baru.name,
            ),
            _tombolTipe(
              StatusOrderEnum.diproses,
              sedangAktif: _filterAktif == StatusOrderEnum.diproses.name,
            ),
            _tombolTipe(
              StatusOrderEnum.selesai,
              sedangAktif: _filterAktif == StatusOrderEnum.selesai.name,
            ),
            _tombolTipe(
              StatusOrderEnum.ditolak,
              sedangAktif: _filterAktif == StatusOrderEnum.ditolak.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolTipe(StatusOrderEnum status, {required bool sedangAktif}) {
    final orderAsync = ref.watch(orderProvider);
    final label = status.displayName;

    Log.info(
      '_tombolTipe dipanggil untuk status: ${status.name}, sedangAktif: $sedangAktif',
    );

    return InkWell(
      onTap: () {
        if (!sedangAktif) {
          Log.info(
            '_tombolTipe: mengubah filter dari $_filterAktif menjadi ${status.name}',
          );
          setState(() {
            _filterAktif = status.name;
            Log.info(
              '_tombolTipe: filter berhasil diubah menjadi $_filterAktif',
            );
          });
        } else {
          Log.info('_tombolTipe: filter ${status.name} sudah aktif');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sedangAktif
              ? Theme.of(context).primaryColor
              : Colors.transparent,
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
              error: (e, s) {
                Log.error(
                  '_tombolTipe: error loading data untuk status ${status.name}',
                  e: e,
                  s: s,
                );
                return Text('Error: $e $s');
              },
              data: (orderState) {
                final jumlah = orderState.daftarOrder
                    .where((o) => o.status == status)
                    .length;
                Log.info(
                  '_tombolTipe: jumlah order untuk status ${status.name}: $jumlah',
                );
                if (jumlah == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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

  Widget _daftarPesanan() {
    final orderAsync = ref.watch(orderProvider);

    Log.info('_daftarPesanan dipanggil, filterAktif: $_filterAktif');

    return orderAsync.when(
      loading: () {
        Log.info('_daftarPesanan: loading data');
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        Log.error('_daftarPesanan: error loading data', e: err, s: stack);
        return Center(child: Text('Terjadi kesalahan: $err'));
      },
      data: (orderState) {
        final semuaOrder = orderState.daftarOrder;
        Log.info('_daftarPesanan: total semua order: ${semuaOrder.length}');

        final orderDifilter = semuaOrder.where((order) {
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

        Log.info(
          '_daftarPesanan: total order setelah filter: ${orderDifilter.length}',
        );

        if (orderDifilter.isEmpty) {
          Log.info(
            '_daftarPesanan: tidak ada order dengan filter $_filterAktif',
          );
          return const Center(child: Text('Belum ada pesanan ditemukan.'));
        }

        return ListView.builder(
          itemCount: orderDifilter.length,
          itemBuilder: (context, index) {
            final order = orderDifilter[index];
            final paketOpFirebase = ref.watch(paketOpFirebaseProvider);

            Log.info(
              '_daftarPesanan: membangun item ke-$index dengan orderId: ${order.id}',
            );
            return ListTile(
              key: ValueKey(order.id),
              onLongPress: () {
                Log.info(
                  '_daftarPesanan: long press pada orderId: ${order.id}',
                );
                try {
                  _showDialog(context, order);
                } on Exception catch (e, st) {
                  Log.error('Gagal memanggil _showDialog', e: e, s: st);
                  if (context.mounted) {
                    ToastUtil.error(context, 'Gagal membuka opsi');
                  }
                }
              },
              title: Row(
                children: [
                  const Text('Paket: '),
                  PackageNameWidget(
                    paketFuture: paketOpFirebase.ambilBerdasarkanId(
                      order.idPaket,
                    ),
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

  Widget _tombolOpsiUbahStatus({
    required String label,
    required OrderModel order,
    required BuildContext dialogContext,
    required BuildContext pageContext,
    required StatusOrderEnum status,
  }) {
    return TextButton(
      onPressed: () async {
        Log.info(
          '_tombolOpsiUbahStatus: tombol $label ditekan untuk orderId: ${order.id}',
        );
        Navigator.of(dialogContext).pop();
        final bool? dikonfirmasi = await _konfirmasiOpsi(pageContext);
        if (dikonfirmasi == true) {
          try {
            final updatedOrder = order.copyWith(status: status);
            await ref.read(orderOpGlobalProvider).perbarui(updatedOrder);
            Log.info(
              '_tombolOpsiUbahStatus: status berhasil diubah untuk orderId: ${order.id}',
            );
            ref.invalidate(daftarPesananProvider);
            ref.invalidate(orderProvider);
            Log.info('_tombolOpsiUbahStatus: orderProvider di-invalidate');

            if (pageContext.mounted) {
              ToastUtil.success(pageContext, 'Data berhasil diperbarui');
            }
          } on Exception catch (e, st) {
            Log.error(
              '_tombolOpsiUbahStatus: gagal mengubah status orderId: ${order.id}',
              e: e,
              s: st,
            );
            if (pageContext.mounted) {
              ToastUtil.error(
                pageContext,
                'Terjadi kesalahan saat memperbarui status pesanan.',
              );
            }
          }
        } else {
          Log.info(
            '_tombolOpsiUbahStatus: konfirmasi dibatalkan untuk orderId: ${order.id}',
          );
        }
      },
      child: TeksIsiSedang(label),
    );
  }
}

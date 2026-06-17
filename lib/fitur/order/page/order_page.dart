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

  @override
  void initState() {
    super.initState();
    Log.info('OrderPage diinisialisasi', {
      'filterAktif': _filterAktif,
      'widget': 'OrderPage',
    });
  }

  @override
  void dispose() {
    Log.info('OrderPage dibersihkan', {'widget': 'OrderPage'});
    super.dispose();
  }

  Future<bool?> _konfirmasiOpsi(BuildContext context) {
    Log.info('Menampilkan dialog konfirmasi', {
      'context': context.runtimeType.toString(),
    });

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin melanjutkan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Log.info('Pengguna membatalkan konfirmasi');
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Log.info('Pengguna mengkonfirmasi tindakan');
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
    Log.info('Membuka dialog ubah status', {
      'orderId': order.id,
      'statusSaatIni': order.status.name,
      'orderData': order.toSqlite(),
    });

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

    Log.info('Membuka dialog opsi untuk pesanan', {
      'orderId': order.id,
      'appRole': appRole.name,
      'status': order.status.name,
    });

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
                      Log.info('Admin memilih opsi "Ubah Status"', {
                        'orderId': order.id,
                      });
                      Navigator.of(dialogContext).pop();
                      unawaited(_ubahStatus(context, order, ref));
                    },
                    child: const Text('Ubah Status'),
                  ),
                TextButton(
                  child: const Text('Hapus'),
                  onPressed: () async {
                    Log.info('Pengguna memilih opsi "Hapus"', {
                      'orderId': order.id,
                      'appRole': appRole.name,
                    });

                    Navigator.of(dialogContext).pop();
                    final bool? dikonfirmasi = await _konfirmasiOpsi(context);

                    if (dikonfirmasi ?? false) {
                      Log.info('Memproses penghapusan pesanan', {
                        'orderId': order.id,
                        'appRole': appRole.name,
                      });

                      try {
                        if (appRole == AppRole.admin) {
                          Log.info(
                            'Menghapus pesanan sebagai admin (soft delete)',
                          );
                          await ref
                              .read(orderOpSqliteProvider)
                              .softDeleteorder(order.id);
                        } else {
                          Log.info(
                            'Menghapus pesanan sebagai user (soft delete via Firebase)',
                          );
                          await ref
                              .read(orderOpFirebaseProvider)
                              .softDeleteOrder(order.id);
                        }

                        Log.info('Pesanan berhasil dihapus', {
                          'orderId': order.id,
                          'appRole': appRole.name,
                        });

                        if (context.mounted) {
                          ToastUtil.success(context, 'Data berhasil dihapus');
                        }
                      } catch (e, st) {
                        Log.error(
                          'Gagal menghapus pesanan',
                          e: e,
                          s: st,
                          data: {'orderId': order.id, 'appRole': appRole.name},
                        );
                        if (context.mounted) {
                          ToastUtil.error(context, 'Gagal menghapus pesanan');
                        }
                      }
                    } else {
                      Log.info('Penghapusan pesanan dibatalkan', {
                        'orderId': order.id,
                      });
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
    Log.info('Membangun UI OrderPage', {
      'filterAktif': _filterAktif,
      'widget': 'OrderPage',
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_listTombolFilter(), _daftarPesanan()],
          ),
        ),
      ),
    );
  }

  Widget _listTombolFilter() {
    Log.info('Membangun tombol filter', {'filterAktif': _filterAktif});

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

    Log.info('Membangun tombol filter: $label', {
      'status': status.name,
      'sedangAktif': sedangAktif,
    });

    return InkWell(
      onTap: () {
        if (!sedangAktif) {
          Log.info('Mengubah filter pesanan', {
            'dari': _filterAktif,
            'ke': status.name,
            'label': label,
          });

          setState(() {
            _filterAktif = status.name;
          });
        } else {
          Log.info('Filter sudah aktif: $label');
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
              loading: () {
                Log.info('Loading data untuk tombol $label');
                return const CircularProgressIndicator();
              },
              error: (e, s) {
                Log.error('Error pada tombol $label', e: e, s: s);
                return Text('Error: $e $s');
              },
              data: (orderState) {
                final jumlah = orderState.orders
                    .where((o) => o.status == status)
                    .length;

                Log.info('Data untuk $label: $jumlah pesanan');

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

    Log.info('Membangun daftar pesanan', {'filterAktif': _filterAktif});

    return orderAsync.when(
      loading: () {
        Log.info('Memuat daftar pesanan...');
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        Log.error(
          'Gagal memuat daftar pesanan',
          e: err,
          s: stack,
          data: {'filterAktif': _filterAktif},
        );
        return Center(child: Text('Terjadi kesalahan: $err'));
      },
      data: (orderState) {
        final semuaOrder = orderState.orders;

        Log.info('Total pesanan: ${semuaOrder.length}', {
          'semuaStatus': semuaOrder.map((o) => o.status.name).toList(),
        });

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

        Log.info('Pesanan setelah difilter: ${orderDifilter.length}', {
          'filter': _filterAktif,
          'orderIds': orderDifilter.map((o) => o.id).toList(),
        });

        if (orderDifilter.isEmpty) {
          Log.info('Tidak ada pesanan dengan filter: $_filterAktif');
          return const Center(child: Text('Belum ada pesanan ditemukan.'));
        }

        final paketOpFirebase = ref.watch(paketOpFirebaseProvider);

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderDifilter.length,
          itemBuilder: (context, index) {
            final order = orderDifilter[index];

            Log.info('Membangun item pesanan ke-$index', {
              'orderId': order.id,
              'status': order.status.name,
              'idPaket': order.idPaket,
            });

            return ListTile(
              onLongPress: () {
                Log.info('Long press pada pesanan', {
                  'orderId': order.id,
                  'status': order.status.name,
                });
                _showDialog(context, order);
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
    required StatusOrderEnum status,
    required BuildContext dialogContext,
    required BuildContext pageContext,
  }) {
    Log.info('Membangun tombol ubah status: $label', {
      'orderId': order.id,
      'targetStatus': status.name,
    });

    return TextButton(
      onPressed: () async {
        Log.info('Pengguna memilih opsi ubah status', {
          'orderId': order.id,
          'targetStatus': status.name,
          'label': label,
        });

        Navigator.of(dialogContext).pop();
        final bool? dikonfirmasi = await _konfirmasiOpsi(pageContext);

        if (dikonfirmasi ?? false) {
          Log.info('Memproses perubahan status pesanan', {
            'orderId': order.id,
            'statusLama': order.status.name,
            'statusBaru': status.name,
          });

          try {
            await ref
                .read(orderOpSqliteProvider)
                .updateStatusOrder(order.id, status);

            Log.info('Status pesanan berhasil diubah', {
              'orderId': order.id,
              'statusBaru': status.name,
            });

            ref.invalidate(orderProvider);
            Log.info('Provider orderProvider di-invalidate');

            if (pageContext.mounted) {
              ToastUtil.success(pageContext, 'Data berhasil diperbarui');
            }
          } on Exception catch (e, st) {
            Log.error(
              'Gagal memperbarui status pesanan',
              e: e,
              s: st,
              data: {
                'orderId': order.id,
                'newStatus': status.name,
                'label': label,
              },
            );

            if (pageContext.mounted) {
              ToastUtil.error(
                pageContext,
                'Terjadi kesalahan saat memperbarui status pesanan.',
              );
            }
          }
        } else {
          Log.info('Perubahan status pesanan dibatalkan', {
            'orderId': order.id,
            'targetStatus': status.name,
          });
        }
      },
      child: TeksIsiSedang(label),
    );
  }
}

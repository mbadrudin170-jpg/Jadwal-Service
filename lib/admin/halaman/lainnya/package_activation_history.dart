// path: lib/admin/halaman/lainnya/package_activation_history.dart
// diubah: Memperbaiki nama class DetailLanggananTransaksiPage menjadi SubscriptionHistoryDetailPage.
// diubah: Memperbaiki parameter yang dikirimkan ke SubscriptionHistoryDetailPage.
// diubah: Menambahkan dokumentasi untuk mengatasi error public_member_api_docs.
// diubah: Menambahkan opsi urutkan berdasarkan tanggal berakhir dan menjadikannya default.
// diubah: Menambahkan opsi urutkan berdasarkan nama pelanggan (A-Z dan Z-A).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/widget/customer_name.dart';
import 'package:wifi/shared/widget/package_name.dart';

enum SortOption {
  endDate,
  nameAZ,
  nameZA,
  endingToday,
  newest,
  oldest,
  paid,
  unpaid,
}

class PackageActivationHistoryPage extends ConsumerStatefulWidget {
  const PackageActivationHistoryPage({super.key});

  @override
  ConsumerState<PackageActivationHistoryPage> createState() =>
      _PackageActivationHistoryPageState();
}

class _PackageActivationHistoryPageState
    extends ConsumerState<PackageActivationHistoryPage> {
  late final TransactionOperation _transactionOperation;
  late final PackageOperation _packageOperation;
  late final CustomerOperation _customerOperation;

  late Future<List<TransactionModel>> _transactionListFuture;
  Map<String, CustomerModel> _customerMap = {};
  SortOption _activeSort = SortOption.endDate;

  @override
  void initState() {
    super.initState();
    _transactionOperation = ref.read(transactionOperationProvider);
    _packageOperation = ref.read(packageOperationProvider);
    _customerOperation = ref.read(customerOperationProvider);
    Log.info('Menginisialisasi halaman Riwayat Aktivasi Paket');
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    Log.info('Memuat data transaksi aktivasi paket dari database');
    setState(() {
      _transactionListFuture = _transactionOperation
          .getTransactionsByPackageActivation()
          .then((final list) async {
        Log.info(
          'Berhasil memuat ${list.length} data transaksi aktivasi paket',
        );

        await _loadCustomerData(list);

        // Log ringkasan setiap transaksi
        int paidCount = 0;
        int unpaidCount = 0;
        int endingTodayCount = 0;
        final now = DateTime.now();

        for (final transaction in list) {
          if (transaction.paymentStatus == PaymentStatus.paid) {
            paidCount++;
          } else {
            unpaidCount++;
          }

          if (transaction.endDate != null &&
              transaction.endDate!.year == now.year &&
              transaction.endDate!.month == now.month &&
              transaction.endDate!.day == now.day) {
            endingTodayCount++;
          }

          Log.info(
            'Transaksi ID: ${transaction.id} - Pelanggan ID: ${transaction.customerId ?? "N/A"}, Paket ID: ${transaction.packageId ?? "N/A"}, Status: ${transaction.paymentStatus.name}, Mulai: ${transaction.startDate != null ? FormatDate.formatDateBasic(transaction.startDate!) : "N/A"}, Berakhir: ${transaction.endDate != null ? FormatDate.formatDateBasic(transaction.endDate!) : "N/A"}',
          );
        }

        Log.info(
          'Ringkasan transaksi - Total: ${list.length}, Lunas: $paidCount, Belum Lunas: $unpaidCount, Berakhir Hari Ini: $endingTodayCount',
        );

        _sortList(list, _activeSort);
        return list;
      }).catchError((final Object error, final StackTrace st) {
        Log.error(
          'Gagal memuat data transaksi aktivasi paket dari database',
          e: error,
          st: st,
        );
        throw Exception('Gagal memuat data transaksi: $error');
      });
    });
  }

  Future<void> _loadCustomerData(
      final List<TransactionModel> transactions) async {
    final customerIds = transactions
        .map((final t) => t.customerId)
        .whereType<String>()
        .toSet()
        .toList();
    if (customerIds.isNotEmpty) {
      final customers = await _customerOperation.getCustomersByIds(customerIds);
      _customerMap = {for (final c in customers) c.id: c};
      Log.info('Berhasil memuat ${_customerMap.length} data pelanggan');
    }
  }

  void _sortList(final List<TransactionModel> list, final SortOption option) {
    Log.info(
      'Mengurutkan ${list.length} data transaksi berdasarkan: ${option.name}',
    );
    int Function(TransactionModel, TransactionModel) comparator;

    switch (option) {
      case SortOption.endDate:
        comparator = (final a, final b) {
          final dateA = a.endDate;
          final dateB = b.endDate;
          // Anggap null sebagai tanggal yang sangat jauh di masa depan
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        };
        Log.info('Pengurutan: Tanggal Berakhir (terdekat di atas)');
        break;
      case SortOption.nameAZ:
        comparator = (final a, final b) {
          final nameA = _customerMap[a.customerId]?.name.toLowerCase() ?? '';
          final nameB = _customerMap[b.customerId]?.name.toLowerCase() ?? '';
          return nameA.compareTo(nameB);
        };
        Log.info('Pengurutan: Nama Pelanggan (A-Z)');
        break;
      case SortOption.nameZA:
        comparator = (final a, final b) {
          final nameA = _customerMap[a.customerId]?.name.toLowerCase() ?? '';
          final nameB = _customerMap[b.customerId]?.name.toLowerCase() ?? '';
          return nameB.compareTo(nameA);
        };
        Log.info('Pengurutan: Nama Pelanggan (Z-A)');
        break;
      case SortOption.newest:
        comparator = (final a, final b) =>
            (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date);
        Log.info('Pengurutan: Terbaru (berdasarkan waktu update/tanggal)');
        break;
      case SortOption.oldest:
        comparator = (final a, final b) =>
            (a.updatedAt ?? a.date).compareTo(b.updatedAt ?? b.date);
        Log.info('Pengurutan: Terlama (berdasarkan waktu update/tanggal)');
        break;
      case SortOption.paid:
        comparator = (final a, final b) {
          final isPaidA = a.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.paymentStatus == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            Log.info(
              'Status sama (${isPaidA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isPaidA ? -1 : 1;
          Log.info(
            'Memindahkan transaksi ${isPaidA ? "lunas" : "belum lunas"} ke ${isPaidA ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info('Pengurutan: Lunas di atas, Belum Lunas di bawah');
        break;
      case SortOption.unpaid:
        comparator = (final a, final b) {
          final isPaidA = a.paymentStatus == PaymentStatus.paid;
          final isPaidB = b.paymentStatus == PaymentStatus.paid;
          if (isPaidA == isPaidB) {
            Log.info(
              'Status sama (${isPaidA ? "lunas" : "belum lunas"}), posisi tidak berubah',
            );
            return 0;
          }
          final result = isPaidA ? 1 : -1;
          Log.info(
            'Memindahkan transaksi ${isPaidA ? "lunas" : "belum lunas"} ke ${isPaidA ? "bawah" : "atas"}',
          );
          return result;
        };
        Log.info('Pengurutan: Belum Lunas di atas, Lunas di bawah');
        break;
      case SortOption.endingToday:
        comparator = (final a, final b) {
          final now = DateTime.now();
          final todayStr = FormatDate.formatDateBasic(now);

          bool isToday(final DateTime? date) {
            if (date == null) return false;
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }

          final aIsToday = isToday(a.endDate);
          final bIsToday = isToday(b.endDate);

          if (aIsToday == bIsToday) {
            Log.info(
              'Status berakhir hari ini sama ($aIsToday), posisi tidak berubah',
            );
            return 0;
          }

          final result = aIsToday ? -1 : 1;
          Log.info(
            'Transaksi ${aIsToday ? "berakhir $todayStr" : "tidak berakhir hari ini"} dipindahkan ke ${aIsToday ? "atas" : "bawah"}',
          );
          return result;
        };
        Log.info(
          'Pengurutan: Berakhir Hari Ini (${FormatDate.formatDateBasic(DateTime.now())}) di atas',
        );
        break;
    }

    list.sort(comparator);

    // Log 5 data teratas setelah pengurutan
    Log.info('5 data teratas setelah pengurutan ${option.name}:');
    for (int i = 0; i < (list.length < 5 ? list.length : 5); i++) {
      final t = list[i];
      Log.info(
        '  ${i + 1}. ID: ${t.id} - Nama: ${_customerMap[t.customerId]?.name ?? 'N/A'} - Status: ${t.paymentStatus.name} - Berakhir: ${t.endDate != null ? FormatDate.formatDateBasic(t.endDate!) : "N/A"}',
      );
    }

    Log.info('Proses pengurutan selesai, ${list.length} data telah diurutkan');
  }

  Future<void> _showSortDialog() async {
    Log.info(
      'Menampilkan dialog opsi pengurutan, urutan saat ini: ${_activeSort.name}',
    );
    final SortOption? selected = await showDialog<SortOption>(
      context: context,
      builder: (final BuildContext context) {
        Widget buildOption(final String text, final SortOption value) {
          final bool isSelected = _activeSort == value;
          return SimpleDialogOption(
            onPressed: () {
              Log.info(
                'User memilih opsi urutkan: ${value.name} (${isSelected ? "sudah aktif" : "berubah"} dari ${_activeSort.name})',
              );
              Navigator.pop(context, value);
            },
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }

        return SimpleDialog(
          title: const Text('Urutkan Berdasarkan'),
          children: <Widget>[
            buildOption('Tanggal Berakhir', SortOption.endDate),
            buildOption('Nama Pelanggan (A-Z)', SortOption.nameAZ),
            buildOption('Nama Pelanggan (Z-A)', SortOption.nameZA),
            buildOption('Berakhir Hari Ini', SortOption.endingToday),
            buildOption('Terbaru', SortOption.newest),
            buildOption('Terlama', SortOption.oldest),
            buildOption('Status (Lunas di Atas)', SortOption.paid),
            buildOption('Status (Belum Lunas di Atas)', SortOption.unpaid),
          ],
        );
      },
    );

    if (selected != null && selected != _activeSort) {
      Log.info(
        'Menerapkan perubahan urutan dari ${_activeSort.name} ke ${selected.name}',
      );
      final list = await _transactionListFuture;
      setState(() {
        _activeSort = selected;
        _sortList(list, selected);
        _transactionListFuture = Future.value(list);
      });
      Log.info('Urutan berhasil diubah ke ${selected.name}');
    } else if (selected == _activeSort) {
      Log.info(
        'User memilih urutan yang sama (${_activeSort.name}), tidak ada perubahan',
      );
    } else {
      Log.info('Dialog urutkan ditutup tanpa memilih opsi');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman Riwayat Aktivasi Paket, urutan aktif: ${_activeSort.name}',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.filter),
            onPressed: _showSortDialog,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionListFuture,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data transaksi masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat menampilkan data transaksi',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            Log.info(
              'Data riwayat aktivasi kosong, menampilkan pesan tidak ada data',
            );
            return const Center(
              child: Text('Tidak ada riwayat langganan ditemukan.'),
            );
          } else {
            final dataLength = snapshot.data!.length;
            Log.info('Menampilkan $dataLength data transaksi dalam ListView');

            return ListView.builder(
              itemCount: dataLength,
              itemBuilder: (final context, final index) {
                final transaction = snapshot.data![index];
                final paymentStatusColor =
                    transaction.paymentStatus == PaymentStatus.paid
                        ? Colors.green
                        : Colors.red;

                Log.info(
                  'Membangun item ke-${index + 1} dari $dataLength - ID: ${transaction.id}, Pelanggan: ${transaction.customerId ?? "N/A"}, Status: ${transaction.paymentStatus.name}',
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: ListTile(
                    onTap: () async {
                      Log.info(
                        'Navigasi ke halaman Detail Transaksi ID: ${transaction.id}, Pelanggan ID: ${transaction.customerId ?? "N/A"}',
                      );
                      // PERBAIKAN: Menggunakan nama class yang benar dan parameter yang benar
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (final context) =>
                              SubscriptionHistoryDetailPage(
                            transactionId: transaction.id,
                          ),
                        ),
                      );
                      if (result ?? false) {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaction.id} dengan perubahan data, menyegarkan daftar',
                        );
                        await _loadHistory();
                      } else {
                        Log.info(
                          'Kembali dari Detail Transaksi ID: ${transaction.id} tanpa perubahan data',
                        );
                      }
                    },
                    title: CustomerNameWidget(
                      customerId: transaction.customerId ?? ' ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PackageNameWidget(
                          packageFuture: _packageOperation
                              .getById(transaction.packageId ?? ''),
                          style: TextStyle(color: paymentStatusColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${transaction.paymentStatus.displayName}',
                          style: TextStyle(
                            color: paymentStatusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (transaction.startDate != null &&
                            transaction.endDate != null)
                          Text(
                            'Aktif: ${FormatDate.formatDateBasic(transaction.startDate!)} - ${FormatDate.formatDateBasic(transaction.endDate!)}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

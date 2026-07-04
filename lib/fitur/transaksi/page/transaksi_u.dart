// path lib/fitur/transaksi/page/transaksi_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/widget/nama_paket_widget.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_provider.dart';

enum SortMode {
  tanggalTerbaru,
  tanggalTerlama,
  tanggalBerakhirTerbaru,
  tanggalBerakhirTerlama,
  lunas,
  belumLunas,
}

class TransaksiU extends ConsumerStatefulWidget {
  const TransaksiU({super.key});

  @override
  ConsumerState<TransaksiU> createState() => _TransaksiUState();
}

class _TransaksiUState extends ConsumerState<TransaksiU> {
  final ScrollController _pengendaliScroll = ScrollController();

  SortMode _modeUrutan = SortMode.tanggalTerbaru;
  int _jumlahTampil = 20;
  bool _sedangMemuatLebih = false;

  @override
  void initState() {
    super.initState();
    _pengendaliScroll.addListener(_deteksiScroll);
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    super.dispose();
  }

  List<TransaksiModel> _sortHistory(List<TransaksiModel> history) {
    switch (_modeUrutan) {
      case SortMode.tanggalTerbaru:
        history.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
      case SortMode.tanggalTerlama:
        history.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case SortMode.tanggalBerakhirTerbaru:
        history.sort((a, b) {
          if (a.tanggalBerakhir == null && b.tanggalBerakhir == null) return 0;
          if (a.tanggalBerakhir == null) return 1;
          if (b.tanggalBerakhir == null) return -1;
          return b.tanggalBerakhir!.compareTo(a.tanggalBerakhir!);
        });
        break;
      case SortMode.tanggalBerakhirTerlama:
        history.sort((a, b) {
          if (a.tanggalBerakhir == null && b.tanggalBerakhir == null) return 0;
          if (a.tanggalBerakhir == null) return 1;
          if (b.tanggalBerakhir == null) return -1;
          return a.tanggalBerakhir!.compareTo(b.tanggalBerakhir!);
        });
        break;
      case SortMode.lunas:
        history.sort((a, b) {
          final statusA = a.statusPembayaran == StatusPembayaran.paid ? 0 : 1;
          final statusB = b.statusPembayaran == StatusPembayaran.paid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
      case SortMode.belumLunas:
        history.sort((a, b) {
          final statusA = a.statusPembayaran == StatusPembayaran.unpaid ? 0 : 1;
          final statusB = b.statusPembayaran == StatusPembayaran.unpaid ? 0 : 1;
          return statusA.compareTo(statusB);
        });
        break;
    }
    return history;
  }

  void _deteksiScroll() {
    final state = ref.read(transaksiOpProvider).value;
    if (state == null) return;

    final userId = ref.read(userIdProvider).value;
    if (userId == null) return;

    final semua = state.transaksi
        .where((e) => e.idPelanggan == userId)
        .toList();
    final total = semua.length;

    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      if (!_sedangMemuatLebih && _jumlahTampil < total) {
        _muatLebihBanyak();
      }
    }
  }

  Future<void> _muatLebihBanyak() async {
    setState(() {
      _sedangMemuatLebih = true;
      _jumlahTampil += 20;
      _sedangMemuatLebih = false;
    });
  }

  Future<void> _refreshRiwayat() async {
    setState(() {
      _jumlahTampil = 20; // Reset pagination
    });
  }

  Future<void> _navigasiKeDetailTransaksi(
    TransaksiModel tx,
    Future<PaketModel?> paketfuture,
  ) async {
    final paket = await paketfuture;
    await ref.read(interstitialAdServiceProvider).show();
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiU(transaksi: tx, paket: paket),
      ),
    );
    await ref.read(interstitialAdServiceProvider).show();
  }

  @override
  Widget build(BuildContext context) {
    final transaksi = ref.watch(transaksiOpProvider);
    final paketOpFirebase = ref.read(paketOpFirebaseProvider);
    final userId = ref.watch(userIdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (hasil) {
              setState(() {
                _modeUrutan = hasil;
                _jumlahTampil = 20;
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: SortMode.tanggalTerbaru,
                checked: _modeUrutan == SortMode.tanggalTerbaru,
                child: const TeksIsiSedang('Tanggal (Terbaru)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.tanggalTerlama,
                checked: _modeUrutan == SortMode.tanggalTerlama,
                child: const TeksIsiSedang('Tanggal (Terlama)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.tanggalBerakhirTerbaru,
                checked: _modeUrutan == SortMode.tanggalBerakhirTerbaru,
                child: const TeksIsiSedang('Tanggal Berakhir (Terbaru)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.tanggalBerakhirTerlama,
                checked: _modeUrutan == SortMode.tanggalBerakhirTerlama,
                child: const TeksIsiSedang('Tanggal Berakhir (Terlama)'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.lunas,
                checked: _modeUrutan == SortMode.lunas,
                child: const TeksIsiSedang('Status: Lunas'),
              ),
              CheckedPopupMenuItem(
                value: SortMode.belumLunas,
                checked: _modeUrutan == SortMode.belumLunas,
                child: const TeksIsiSedang('Status: Belum Lunas'),
              ),
            ],
            icon: const Icon(TIcons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: transaksi.when(
              data: (data) {
                if (userId == null || userId.isEmpty) {
                  return const Center(
                    child: Text('Silakan login terlebih dahulu'),
                  );
                }

                final semuaTransaksi = data.transaksi
                    .where((e) => e.idPelanggan == userId)
                    .toList();
                final riwayatUrut = _sortHistory(List.from(semuaTransaksi));
                final transaksiTampil = riwayatUrut
                    .take(_jumlahTampil)
                    .toList();
                final showLoadMore = _jumlahTampil < riwayatUrut.length;

                return RefreshIndicator(
                  onRefresh: _refreshRiwayat,
                  child: ListView.builder(
                    controller: _pengendaliScroll,
                    itemCount: transaksiTampil.length + (showLoadMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transaksiTampil.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final tx = transaksiTampil[index];
                      final paketFuture = tx.idPaket != null
                          ? paketOpFirebase.ambilBerdasarkanId(tx.idPaket!)
                          : Future<PaketModel?>.value();
                      final teksAktif = tx.tanggalBerakhir != null
                          ? PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
                              tx.tanggalBerakhir!,
                            )
                          : '--';
                      final warnaAktif = tx.tanggalBerakhir != null
                          ? PerhitunganUtil.ambilWarnaSisaMasaAktif(
                              tx.tanggalBerakhir!,
                            )
                          : Colors.grey;

                      return Card(
                        key: ValueKey(tx.id),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(TIcons.receiptLong),
                          title: NamaPaketWidget(idPaket: tx.idPaket ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tx.tanggalBerakhir != null)
                                TeksIsiSedang(
                                  'Berakhir - ${FormatWaktuLengkap.formatSingkat(tx.tanggalBerakhir!)}',
                                ),
                              TeksIsiSedang(
                                'Status: ${tx.statusPembayaran.displayName}',
                                warna:
                                    tx.statusPembayaran == StatusPembayaran.paid
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              TeksIsiSedang(
                                'Masa Aktif: $teksAktif',
                                warna: warnaAktif,
                              ),
                            ],
                          ),
                          trailing: const Icon(TIcons.chevronRight),
                          onTap: () =>
                              _navigasiKeDetailTransaksi(tx, paketFuture),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) => Text('$error $stackTrace'),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

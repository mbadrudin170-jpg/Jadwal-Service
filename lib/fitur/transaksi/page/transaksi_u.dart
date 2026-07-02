// path lib/fitur/transaksi/page/transaksi_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';
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
  final TransaksiOpFirebase _transaksiOpFirebase = TransaksiOpFirebase();
  final ScrollController _pengendaliScroll = ScrollController();

  SortMode _modeUrutan = SortMode.tanggalTerbaru;

  List<TransaksiModel> _semuaTransaksi = [];
  List<TransaksiModel> _transaksiTampil = [];
  int _jumlahTampil = 20;
  bool _sedangMemuatLebih = false;

  @override
  void initState() {
    super.initState();
    _pengendaliScroll.addListener(_deteksiScroll);
    // Jalankan pemuatan awal setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatDataAwal();
    });
  }

  @override
  void dispose() {
    _pengendaliScroll.removeListener(_deteksiScroll);
    _pengendaliScroll.dispose();
    super.dispose();
  }

  Future<void> _muatDataAwal() async {
    try {
      final userId = await ref.read(userIdProvider.future);

      if (userId == null) {
        setState(() {
          _semuaTransaksi = [];
          _transaksiTampil = [];
        });
        return;
      }

      final pelangganOp = ref.read(pelangganOpGlobalProvider);
      final pelanggan = await pelangganOp.ambilBerdasarkanId(userId);
      if (pelanggan == null) {
        setState(() {
          _semuaTransaksi = [];
          _transaksiTampil = [];
        });
        return;
      }

      final hasil = await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        pelanggan.id,
      );

      setState(() {
        _semuaTransaksi = hasil;
        _perbaruiTransaksiTampil(aturUlang: true);
      });
    } on Object catch (e, st) {
      Log.error('Gagal memuat riwayat transaksi', e: e, s: st);
    }
  }

  List<TransaksiModel> _sortHistory(List<TransaksiModel> history) {
    switch (_modeUrutan) {
      case SortMode.tanggalTerbaru:
        history.sort((a, b) {
          return b.tanggal.compareTo(a.tanggal);
        });
        break;
      case SortMode.tanggalTerlama:
        history.sort((a, b) {
          return b.tanggal.compareTo(a.tanggal);
        });
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
    if (_pengendaliScroll.position.pixels >=
        _pengendaliScroll.position.maxScrollExtent - 200) {
      if (!_sedangMemuatLebih &&
          _transaksiTampil.length < _semuaTransaksi.length) {
        _muatLebihBanyak();
      }
    }
  }

  Future<void> _muatLebihBanyak() async {
    Log.info('Memulai memuat lebih banyak riwayat transaksi');
    setState(() {
      _sedangMemuatLebih = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));

    setState(() {
      _jumlahTampil += 20;
      _perbaruiTransaksiTampil();
      _sedangMemuatLebih = false;
    });

    Log.info(
      'Berhasil memuat lebih banyak transaksi, total tampil: $_jumlahTampil',
    );
  }

  void _perbaruiTransaksiTampil({bool aturUlang = false}) {
    if (aturUlang) {
      _jumlahTampil = 20;
    }

    final riwayatUrut = _sortHistory(List.from(_semuaTransaksi));

    setState(() {
      _transaksiTampil = riwayatUrut.take(_jumlahTampil).toList();
    });
  }

  Future<void> _refreshRiwayat() async {
    await _muatDataAwal();
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
    final transaksi = ref.watch(transaksiProvider);
    final paketOpFirebase = ref.read(paketOpFirebaseProvider);
    final pelangganOp = ref.read(pelangganOpGlobalProvider);
    final userId = ref.watch(userIdProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Langganan'),
        actions: [
          PopupMenuButton<SortMode>(
            onSelected: (SortMode hasil) {
              setState(() {
                _modeUrutan = hasil;
                _perbaruiTransaksiTampil(aturUlang: true);
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: SortMode.tanggalTerbaru,
                textStyle: TextStyle(
                  color: _modeUrutan == SortMode.tanggalTerlama
                      ? Theme.of(context).colorScheme.primary.withAlpha(30)
                      : null,
                ),
                child: const TeksIsiSedang('Tanggal (Terbaru)'),
              ),
              PopupMenuItem(
                textStyle: TextStyle(
                  color: _modeUrutan == SortMode.tanggalTerlama
                      ? Theme.of(context).colorScheme.primary.withAlpha(30)
                      : null,
                ),
                value: SortMode.tanggalTerlama,
                child: const TeksIsiSedang('Tanggal (Terlama)'),
              ),
              PopupMenuItem(
                textStyle: TextStyle(
                  color: _modeUrutan == SortMode.tanggalBerakhirTerbaru
                      ? Theme.of(context).colorScheme.primary.withAlpha(30)
                      : null,
                ),
                value: SortMode.tanggalBerakhirTerbaru,
                child: const TeksIsiSedang('Tanggal Berakhir (Terbaru)'),
              ),
              PopupMenuItem(
                value: SortMode.tanggalBerakhirTerlama,
                textStyle: TextStyle(
                  color: _modeUrutan == SortMode.tanggalBerakhirTerlama
                      ? Theme.of(context).colorScheme.primary.withAlpha(30)
                      : null,
                ),
                child: const TeksIsiSedang('Tanggal Berakhir (Terlama)'),
              ),
              PopupMenuItem(
                value: SortMode.lunas,
                textStyle: TextStyle(
                  color: _modeUrutan == SortMode.lunas
                      ? Theme.of(context).colorScheme.primary.withAlpha(30)
                      : null,
                ),
                child: const TeksIsiSedang('Status: Lunas'),
              ),
              PopupMenuItem(
                value: SortMode.belumLunas,
                textStyle: TextStyle(
                  color: _modeUrutan == SortMode.belumLunas
                      ? Theme.of(context).colorScheme.primary.withAlpha(30)
                      : null,
                ),
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
              data: (TransaksiState data) {
                return RefreshIndicator(
                  onRefresh: _refreshRiwayat,
                  child: ListView.builder(
                    controller: _pengendaliScroll,
                    itemCount:
                        _transaksiTampil.length + (_sedangMemuatLebih ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _transaksiTampil.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final tx = _transaksiTampil[index];
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
              error: (Object error, StackTrace stackTrace) =>
                  Text('$error $stackTrace'),
              loading: () => const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

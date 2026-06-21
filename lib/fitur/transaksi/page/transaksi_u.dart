// path: lib/user/page/subscription_history_user.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/shared/common/teks.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/widget/package_name.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_provider.dart';

enum SortMode {
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

  SortMode _modeUrutan = SortMode.tanggalBerakhirTerbaru;

  List<TransaksiModel> _semuaTransaksi = [];
  List<TransaksiModel> _transaksiTampil = [];
  int _jumlahTampil = 20;
  bool _sedangMemuatAwal = true;
  bool _sedangMemuatLebih = false;
  Object? _errorAwal;

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
    setState(() {
      _sedangMemuatAwal = true;
      _errorAwal = null;
    });

    try {
      final userId = await ref.read(userIdProvider.future);

      if (userId == null) {
        setState(() {
          _semuaTransaksi = [];
          _transaksiTampil = [];
          _sedangMemuatAwal = false;
        });
        return;
      }

      final pelangganOpFirebase = ref.read(pelangganOpFirebaseProvider);
      final pelanggan = await pelangganOpFirebase.ambilBerdasarkanId(userId);
      if (pelanggan == null) {
        setState(() {
          _semuaTransaksi = [];
          _transaksiTampil = [];
          _sedangMemuatAwal = false;
        });
        return;
      }

      final hasil = await _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(
        pelanggan.id,
      );

      setState(() {
        _semuaTransaksi = hasil;
        _perbaruiTransaksiTampil(aturUlang: true);
        _sedangMemuatAwal = false;
      });
    } on Object catch (e, st) {
      Log.error('Gagal memuat riwayat transaksi', e: e, s: st);
      setState(() {
        _errorAwal = e;
        _sedangMemuatAwal = false;
      });
    }
  }

  List<TransaksiModel> _sortHistory(List<TransaksiModel> history) {
    switch (_modeUrutan) {
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
    final paketOpFirebase = ref.read(paketOpFirebaseProvider);
    final pelangganOpFirebase = ref.read(pelangganOpFirebaseProvider);
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
              const PopupMenuItem(
                value: SortMode.tanggalBerakhirTerbaru,
                child: TeksIsiSedang('Tanggal Berakhir (Terbaru)'),
              ),
              const PopupMenuItem(
                value: SortMode.tanggalBerakhirTerlama,
                child: TeksIsiSedang('Tanggal Berakhir (Terlama)'),
              ),
              const PopupMenuItem(
                value: SortMode.lunas,
                child: TeksIsiSedang('Status: Lunas'),
              ),
              const PopupMenuItem(
                value: SortMode.belumLunas,
                child: TeksIsiSedang('Status: Belum Lunas'),
              ),
            ],
            icon: const Icon(TIcons.sort),
          ),
        ],
      ),
      body: StreamBuilder<PelangganModel?>(
        stream: userId.when(
          data: (id) => id != null
              ? pelangganOpFirebase.ambilStreamBerdasarkanId(id)
              : const Stream.empty(),
          loading: () => const Stream.empty(),
          error: (_, _) => const Stream.empty(),
        ),
        builder: (context, customerSnapshot) {
          if (customerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (customerSnapshot.hasError) {
            return Center(
              child: TeksIsiSedang('Error: ${customerSnapshot.error}'),
            );
          }
          if (!customerSnapshot.hasData || customerSnapshot.data == null) {
            return const Center(
              child: TeksIsiSedang('Data pelanggan tidak ditemukan.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: _sedangMemuatAwal
                    ? const Center(child: CircularProgressIndicator())
                    : _errorAwal != null
                    ? Center(child: TeksIsiSedang('Gagal memuat: $_errorAwal'))
                    : _transaksiTampil.isEmpty
                    ? const Center(child: TeksIsiSedang('Tidak ada riwayat.'))
                    : RefreshIndicator(
                        onRefresh: _refreshRiwayat,
                        child: ListView.builder(
                          controller: _pengendaliScroll,
                          itemCount:
                              _transaksiTampil.length +
                              (_sedangMemuatLebih ? 1 : 0),
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
                                ? paketOpFirebase.ambilBerdasarkanId(
                                    tx.idPaket!,
                                  )
                                : Future<PaketModel?>.value();
                            final teksAktif = tx.tanggalBerakhir != null
                                ? PerhitunganUtil.ambilTeksSisaMasaAktif(
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
                                title: PackageNameWidget(
                                  paketFuture: paketFuture,
                                ),
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
                                          tx.statusPembayaran ==
                                              StatusPembayaran.paid
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

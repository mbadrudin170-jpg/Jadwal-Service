
// File: lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart

// path: lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

enum OpsiLanjutan { softDeleteAll, arsipkanKadaluarsa, batal }

class PelangganAktifPage extends ConsumerStatefulWidget {
  const PelangganAktifPage({super.key});

  @override
  ConsumerState<PelangganAktifPage> createState() => _PelangganAktifPageState();
}

class _PelangganAktifPageState extends ConsumerState<PelangganAktifPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _mencari = false;

  @override
  void initState() {
    super.initState();
    Log.info('ActiveCustomerPage initState');
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_inisialisasiAwal());
      }
    });
  }

  Future<void> _inisialisasiAwal() async {
    try {
      await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
    } catch (e) {
      Log.error('Gagal menjalankan arsip otomatis saat aplikasi dibuka', e: e);
    }
    if (mounted) {
      await ref.read(pelangganAktifProvider.notifier).perbaruiData();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  PelangganAktifOpSqlite get _pelangganAktifOpSqlite =>
      ref.read(pelangganAktifOpSqliteProvider);
  TransaksiOpSqlite get _transaksiOpsqlite =>
      ref.read(transaksiOpSqliteProvider);

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> refreshData() async {
    try {
      await _pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
    } catch (e) {
      Log.error('Gagal arsip otomatis saat refresh', e: e);
    }
  }

  Future<void> _softDeletePelangganAktif(
    final DetailPelangganAktifModel pelanggan,
  ) async {
    final idPelangganAktif = pelanggan.pelangganAktif.id;
    final namaPelanggan = pelanggan.namaPelanggan;
    final idTransaksi = pelanggan.pelangganAktif.idTransaksi;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Arsipkan'),
        content: Text('Yakin ingin mengarsipkan pelanggan "$namaPelanggan"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        await _pelangganAktifOpSqlite.softDeletePelangganAktifDanTransaksi(
          idPelangganAktif,
          idTransaksi,
        );
        Log.info('Berhasil soft delete pelanggan ID: $idPelangganAktif');
        if (mounted) {
          ToastUtil.success(
            context,
            'Pelanggan "$namaPelanggan" berhasil diarsipkan.',
          );
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal soft delete pelanggan ID: $idPelangganAktif',
          e: e,
          s: s,
        );
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengarsipkan pelanggan: $e');
        }
      }
    } else {
      Log.info(
        'Soft delete pelanggan ID: $idPelangganAktif dibatalkan oleh user',
      );
    }
  }

  Future<void> _tampilkanDialogUrutan() async {
    final currentSort = ref.read(urutanPelangganAktifStateProvider);
    await showDialog<UrutanPelangganAktifEnum>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Urutkan Berdasarkan'),
        contentPadding: const EdgeInsets.only(
          top: TSizes.p12,
          bottom: TSizes.p12,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: UrutanPelangganAktifEnum.values.map((o) {
                    final diPilih = currentSort == o;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TSizes.p24,
                      ),
                      title: Text(
                        ambilTeksUrutanPelangganAktif(o),
                        style: TextStyle(
                          fontSize: TSizes.p16,
                          fontWeight: diPilih
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: diPilih
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      trailing: diPilih
                          ? Icon(
                              TIcons.check,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx); // tutup dialog
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // tunda perubahan state
                          if (mounted) {
                            // pastikan widget masih hidup
                            ref
                                .read(
                                  urutanPelangganAktifStateProvider.notifier,
                                )
                                .ubahUrutan(o);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Future<void> _opsiLanjutan() async {
    Log.info('Membuka opsi lanjutan');
    final selected = await showDialog<OpsiLanjutan>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Opsi Lanjutan'),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(ctx, OpsiLanjutan.arsipkanKadaluarsa),
            child: const Text('Arsipkan pelanggan kadaluarsa'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, OpsiLanjutan.softDeleteAll),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, OpsiLanjutan.batal),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    switch (selected) {
      case OpsiLanjutan.softDeleteAll:
        Log.warning('Opsi arsipkan semua dipilih');
        final konfirmasi = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Arsipkan Semua'),
            content: const Text(
              'Yakin ingin mengarsipkan SEMUA pelanggan aktif?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Arsipkan Semua'),
              ),
            ],
          ),
        );
        if (konfirmasi == true) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            await _pelangganAktifOpSqlite.softDeleteAll();
            await _transaksiOpsqlite.softDeleteAll();
            if (mounted) {
              ToastUtil.success(context, 'Berhasil mengarsipkan  pelanggan.');
            }
            unawaited(
              ref
                  .read(layananCekSinkronisasiProvider)
                  .jalankanCekSinkronisasi(),
            );
            await ref.read(pelangganAktifProvider.notifier).perbaruiData();
          } catch (e, s) {
            Log.error('Gagal mengarsipkan semua pelanggan aktif', e: e, s: s);
            if (mounted) {
              ToastUtil.error(
                context,
                'Gagal mengarsipkan semua pelanggan: $e',
              );
            }
          }
        }
        break;
      case OpsiLanjutan.arsipkanKadaluarsa:
        try {
          Log.info('Mulai arsipkan pelanggan kadaluarsa');
          final count = await _pelangganAktifOpSqlite
              .arsipkanLanggananKadaluarsa();
          Log.info('Selesai arsipkan kadaluarsa, jumlah=$count');
          if (mounted) {
            ToastUtil.success(
              context,
              '$count pelanggan kadaluarsa diarsipkan.',
            );
          }
          await ref.read(pelangganAktifProvider.notifier).perbaruiData();
        } catch (e, s) {
          Log.error('Gagal mengarsipkan pelanggan kadaluarsa', e: e, s: s);
          if (mounted) {
            ToastUtil.error(
              context,
              'Gagal mengarsipkan pelanggan kadaluarsa: $e',
            );
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pelangganAktifAsync = ref.watch(pelangganAktifProvider);
    return Scaffold(
      appBar: AppBar(
        title: _mencari
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari data...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Pelanggan Aktif'),
        actions: _mencari
            ? [
                IconButton(
                  icon: const Icon(TIcons.close),
                  onPressed: () {
                    setState(() => _mencari = false);
                    _searchController.clear();
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(TIcons.search),
                  onPressed: () => setState(() => _mencari = true),
                ),
                IconButton(
                  icon: const Icon(TIcons.filter),
                  onPressed: _tampilkanDialogUrutan,
                ),
                IconButton(
                  icon: const Icon(TIcons.delete),
                  onPressed: _opsiLanjutan,
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: pelangganAktifAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            Log.error('Error UI Pelanggan Aktif', e: error, s: stack);
            return Center(child: Text('Terjadi kesalahan: $error'));
          },
          data: (state) {
            final sortBy = ref.watch(urutanPelangganAktifStateProvider);
            final urutkan = urutkanPelangganAktif(
              state.daftarPelangganAktif,
              sortBy,
            );
            final query = _searchController.text.toLowerCase();
            final displayedCustomers = urutkan
                .where((c) => c.namaPelanggan.toLowerCase().contains(query))
                .toList();
            if (displayedCustomers.isEmpty) {
              return Center(
                child: Text(
                  query.isNotEmpty
                      ? 'Pelanggan tidak ditemukan.'
                      : 'Tidak ada pelanggan aktif.',
                ),
              );
            }

            return ListView.builder(
              itemCount: displayedCustomers.length,
              itemBuilder: (_, i) {
                final detail = displayedCustomers[i];
                final c = detail.pelangganAktif;
                return Card(
                  margin: const EdgeInsets.only(
                    left: TSizes.p16,
                    right: TSizes.p16,
                    bottom: TSizes.p12,
                  ),
                  child: InkWell(
                    onLongPress: () => _softDeletePelangganAktif(detail),
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              DetailPelangganAktif(pelangganAktif: c),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        detail.namaPelanggan,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail.namaPaket),
                          Text(
                            'Pembayaran: ${c.status.displayName}',
                            style: TextStyle(
                              color: c.status == StatusPembayaran.paid
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(c.tanggalBerakhir)}',
                            style: TextStyle(
                              color: PerhitunganUtil.ambilWarnaSisaMasaAktif(
                                c.tanggalBerakhir,
                              ),
                            ),
                          ),
                          Text(
                            'Berakhir: ${FormatTanggal.formatDasar(c.tanggalBerakhir)} ${FormatJam.formatJamMenit(c.tanggalBerakhir)}',
                          ),
                        ],
                      ),
                      trailing: const Icon(TIcons.chevronRight),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_active_customer',
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const FormPelangganAktif()),
        ),
        child: const Icon(TIcons.add),
      ),
    );
  }
}

// File: lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart

// path lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/future_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

final detailPleangganAktifProvider =
    FutureProvider.family<
      ({
        PelangganModel? pelanggan,
        PaketModel? paket,
        TransaksiModel? transaksi,
        PelangganAktifModel pelangganAktif,
      }),
      String
    >((ref, id) async {
      final pelangganAktifState = await ref.watch(
        pelangganAktifProvider.future,
      );
      final daftarPelangganAktif = pelangganAktifState.daftarPelangganAktif;
      final detailPelangganAktif = daftarPelangganAktif.firstWhereOrNull(
        (detail) => detail.pelangganAktif.id == id,
      );
      if (detailPelangganAktif == null) {
        throw Exception('Data pelanggan aktif tidak ditemukan dalam daftar.');
      }
      final pelangganAktif = detailPelangganAktif.pelangganAktif;
      final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
      final paketOpSqlite = ref.watch(paketOpSqliteProvider);
      final transaksiOpsqlite = ref.watch(transaksiOpGlobalProvider);
      final hasil = await futureWait([
        pelangganOpSqlite.ambilBerdasarkanId(pelangganAktif.idPelanggan),
        pelangganAktif.idPaket.isNotEmpty
            ? paketOpSqlite.ambilBerdasarkanId(pelangganAktif.idPaket)
            : Future<PaketModel?>.value(),
        pelangganAktif.idTransaksi.isNotEmpty
            ? transaksiOpsqlite.ambilBerdasarkanId(pelangganAktif.idTransaksi)
            : Future<TransaksiModel?>.value(),
      ]);
      return (
        pelanggan: hasil[0] as PelangganModel?,
        paket: hasil[1] as PaketModel?,
        transaksi: hasil[2] as TransaksiModel?,
        pelangganAktif: pelangganAktif,
      );
    });

class DetailPelangganAktif extends ConsumerStatefulWidget {
  final PelangganAktifModel pelangganAktif;
  const DetailPelangganAktif({super.key, required this.pelangganAktif});
  @override
  ConsumerState<DetailPelangganAktif> createState() =>
      _DetailPelangganAktifState();
}

class _DetailPelangganAktifState extends ConsumerState<DetailPelangganAktif> {
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman Detail Pelanggan Aktif');
    Log.info('  - ID Pelanggan Aktif: ${widget.pelangganAktif.id}');
  }

  Future<void> _bukaWhatsApp(String phone) async {
    var formatNomor = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (formatNomor.startsWith('0')) {
      formatNomor = '62${formatNomor.substring(1)}';
    } else if (!formatNomor.startsWith('62')) {
      formatNomor = '62$formatNomor';
    }
    final whatsappUri = Uri.parse('https://wa.me/$formatNomor');
    try {
      Log.info('Mencoba membuka WhatsApp: $formatNomor');
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        Log.info('Berhasil membuka WhatsApp.');
      } else {
        throw Exception('Could not launch $whatsappUri');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal membuka WhatsApp', e: e, s: s);
      if (!mounted) return;
      ToastUtil.error(
        context,
        'Tidak dapat membuka WhatsApp. Pastikan sudah terinstal.',
      );
    }
  }

  void _bukaFormEdit(PelangganAktifModel pelangganaktif) {
    Log.info('Navigasi ke form edit pelanggan aktif ID: ${pelangganaktif.id}');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FormPelangganAktif(pelangganAktif: pelangganaktif),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI detail pelanggan aktif untuk ID: ${widget.pelangganAktif.id}.',
    );
    final detailAsync = ref.watch(
      detailPleangganAktifProvider(widget.pelangganAktif.id),
    );
    return detailAsync.when(
      skipLoadingOnReload: true,
      data: (data) => _buildScaffold(context, data),
      loading: () => const Scaffold(body: Center(child: Text(''))),
      error: (e, s) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ({
      PelangganModel? pelanggan,
      PaketModel? paket,
      TransaksiModel? transaksi,
      PelangganAktifModel pelangganAktif,
    })
    data,
  ) {
    final pelangganAktif = data.pelangganAktif;
    final pelanggan = data.pelanggan;
    final paket = data.paket;
    final transaksi = data.transaksi;
    return Scaffold(
      appBar: AppBar(
        title: Text(pelanggan?.nama ?? 'Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.edit),
            onPressed: () => _bukaFormEdit(pelangganAktif),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (pelanggan != null) {
                              Log.info(
                                'Navigasi ke detail pelanggan: ${pelanggan.nama}',
                              );
                              unawaited(
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPelanggan(
                                      idPelanggan: pelanggan.id,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            pelanggan?.nama ?? pelangganAktif.idPelanggan,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                      ),
                      gapH16,
                      const Divider(),
                      _buildWhatsAppInfoRow(
                        context,
                        'No HP',
                        pelanggan?.telepon ?? 'Tidak ditemukan',
                      ),
                      InkWell(
                        onTap: () {
                          if (paket != null) {
                            Log.info('Navigasi ke detail paket: ${paket.nama}');
                            unawaited(
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      DetailPaketPage(paket: paket),
                                ),
                              ),
                            );
                          }
                        },
                        child: _buildInfoRow(
                          context,
                          'Paket',
                          paket?.nama ?? ' (ID: ${pelangganAktif.idPaket})',
                        ),
                      ),
                      _buildInfoRow(
                        context,
                        'Status',
                        pelangganAktif.status.displayName,
                      ),
                      if (transaksi != null) ...[
                        if (transaksi.poinDidapat > 0)
                          _buildInfoRow(
                            context,
                            'Poin Hadiah',
                            '${transaksi.poinDidapat} Poin',
                          ),
                        if (transaksi.poinDigunakan > 0)
                          _buildInfoRow(
                            context,
                            'Poin Penukaran',
                            '${transaksi.poinDigunakan} Poin',
                          ),
                      ],
                      if (transaksi != null && (transaksi.durasiBonus) > 0)
                        _buildInfoRow(
                          context,
                          'Bonus',
                          '${transaksi.durasiBonus} ${transaksi.tipeDurasiBonus?.displayName ?? ""}',
                        ),
                      _buildInfoRow(
                        context,
                        'Mulai',
                        FormatWaktuLengkap.formatSingkat(
                          pelangganAktif.tanggalMulai,
                        ),
                      ),
                      _buildInfoRow(
                        context,
                        'Berakhir',
                        FormatWaktuLengkap.formatSingkat(
                          pelangganAktif.tanggalBerakhir,
                        ),
                      ),
                      const Divider(),
                      gapH16,
                      Text(
                        PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
                          pelangganAktif.tanggalBerakhir,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: PerhitunganUtil.ambilWarnaSisaMasaAktif(
                            pelangganAktif.tanggalBerakhir,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      gapH24,
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send_to_mobile),
                        label: const Text('Kirim Info via WhatsApp'),
                        onPressed: () {
                          Log.info('Tombol kirim info WhatsApp ditekan.');
                          unawaited(
                            ref
                                .read(pesanInfoPaketProvider)
                                .kirimRincianPaket(pelangganAktif),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Di dalam AppBar actions atau di body Card
                      ElevatedButton.icon(
                        icon: const Icon(Icons.update),
                        label: const Text('Perpanjang Masa Aktif'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => FormPelangganAktif(
                                pelangganAktif: data.pelangganAktif,
                                modePerpanjang:
                                    true, // kirim flag mode perpanjang
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    final String label,
    final String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          gapH8,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppInfoRow(
    BuildContext context,
    final String label,
    final String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          InkWell(
            onTap: () => _bukaWhatsApp(value),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  gapH8,
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green.shade700,
                    size: TSizes.p20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// File: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';

part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const factory PelangganAktifState({
    @Default([]) List<PelangganAktifModel> daftarPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;
}

@Riverpod(keepAlive: true)
class PelangganAktif extends _$PelangganAktif {
  PelangganAktifOpSqlite get pelangganAktifOpSqlite =>
      ref.read(pelangganAktifOpSqliteProvider);

  @override
  FutureOr<PelangganAktifState> build() {
    return _ambilData();
  }

  Future<PelangganAktifState> _ambilData() async {
    final operasi = ref.read(pelangganAktifOpSqliteProvider);
    final hasil = await operasi.ambilSemua();
    return PelangganAktifState(
      daftarPelangganAktif: hasil,
      jumlahPelangganAktif: hasil.length,
    );
  }

  Future<void> tambah(PelangganAktifModel pelangganAktif) async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.tambahPelangganAktif(pelangganAktif);
      final currentData = state.requireValue;
      state = AsyncData(
        currentData.copyWith(
          daftarPelangganAktif: [
            ...currentData.daftarPelangganAktif,
            pelangganAktif,
          ],
        ),
      );
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(PelangganAktifModel pelangganAktif) async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.updatePelangganAktif(pelangganAktif);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarPelangganAktif.map((t) {
        return t.id == pelangganAktif.id ? pelangganAktif : t;
      }).toList();
      state = AsyncData(
        currentData.copyWith(daftarPelangganAktif: updatedList),
      );
    } on Exception catch (e, s) {
      Log.error('Error perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> hapus(String idPelangganAktif) async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.softDelete(idPelangganAktif);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarPelangganAktif
          .where((t) => t.id != idPelangganAktif)
          .toList();
      state = AsyncData(
        currentData.copyWith(daftarPelangganAktif: updatedList),
      );
    } on Exception catch (e, s) {
      Log.error('Error hapus: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteAll() async {
    try {
      if (!state.hasValue) return;
      await pelangganAktifOpSqlite.softDeleteAll();
      final currentData = state.requireValue;
      state = AsyncData(currentData.copyWith(daftarPelangganAktif: []));
    } on Exception catch (e, s) {
      Log.error('Error hapus semua: $e', e: e, s: s);
      rethrow;
    }
  }
}

@freezed
abstract class DetailPelangganAktifState with _$DetailPelangganAktifState {
  const factory DetailPelangganAktifState({
    required PelangganAktifModel pelangganAktif,
    required PelangganModel pelanggan,
    required TransaksiModel transaksi,
    required PaketModel paket,
  }) = _DetailPelangganAktifState;
}

@riverpod
Future<void> detailPelangganAktif(Ref ref) async {
  final pelangganAktifOpSqlite = ref.read(pelangganAktifOpSqliteProvider);
  await pelangganAktifOpSqlite.ambilSemuaPelangganAktifDenganDetail();
  return;
}

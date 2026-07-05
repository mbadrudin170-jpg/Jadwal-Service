
// File: lib/fitur/paket/provider/paket_provider.dart

```dart
// path: lib/fitur/paket/provider/paket_provider.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_global.dart';
import 'package:wifi/fitur/paket/page/paket.dart';
import 'package:wifi/shared/debug/log.dart';

part 'paket_provider.g.dart';
part 'paket_provider.freezed.dart';

@freezed
abstract class PaketState with _$PaketState {
   const PaketState._();
  const factory PaketState({
    @Default([]) List<PaketModel?> daftarPaket,
    @Default([]) List<PaketModel?> daftarPaketPublik,
    @Default(0) int jumlahPaket,
  }) = _PaketState;
   PaketModel? ambilBerdasarkanId(String idPaket) {
    return daftarPaket.firstWhereOrNull((p) => p?.id == idPaket);
  }
}

@Riverpod(keepAlive: true)
class Paket extends _$Paket {
  PaketOpGlobal get _paketOp => ref.read(paketOpGlobalProvider);

  @override
  FutureOr<PaketState> build() async {
    return _ambilData();
  }

  Future<PaketState> _ambilData() async {
    final daftarpaket = await _paketOp.ambilSemua();
    final daftarPaketPublik = await _paketOp.ambilPaketPublik();

    return PaketState(
      daftarPaket: daftarpaket,
      jumlahPaket: daftarpaket.length,
      daftarPaketPublik: daftarPaketPublik,
    );
  }

  Future<void> tambah(PaketModel paket) async {
    try {
      await _paketOp.tambahPaket(paket);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error di tambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(PaketModel paket) async {
    try {
      await _paketOp.perbaruiPaket(paket);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error diupdate: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await _paketOp.softDelete(id);
      unawaited(invalidateProviderPaket());
    } on Exception catch (e, s) {
      Log.error('Error disoftDelete: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> refresh() async {
    Log.info('PaketProvider: Menyegarkan data paket');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
    Log.info('PaketProvider: Penyegaran data paket selesai');
  }

  Future<void> invalidateProviderPaket() async {
    ref.invalidateSelf();
    ref.invalidate(detailPaketProvider);
    ref.invalidate(urutanPaketStateProvider);
  }
}

@riverpod
class UrutanPaketState extends _$UrutanPaketState {
  @override
  UrutanPaket build() {
    return UrutanPaket.durasiTerpendek;
  }

  void ubahUrutan(UrutanPaket urutanBaru) {
    state = urutanBaru;
  }
}

@riverpod
Future<PaketModel> detailPaket(Ref ref, String id) async {
  Log.info('Mendapatkan detail paket dari SQLite via paketProvider...');
  final paketOp = ref.watch(paketOpGlobalProvider);
  final paket = await paketOp.ambilBerdasarkanId(id);
  if (paket == null) {
    throw Exception('Paket dengan id $id tidak ditemukan');
  }
  return paket;
}

@riverpod
Future<String?> namaPaket(Ref ref, String idPaket) async {
  if (idPaket.isEmpty) return null;
  final paketState = await ref.watch(paketProvider.future);
  final paket = paketState.daftarPaket.firstWhereOrNull(
    (p) => p!.id == idPaket,
  );
  if (paket == null) return null;
  return paket.nama;
}
```

// File: lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart

```dart
// path lib/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';

part 'pengurut_pelanggan_aktif.g.dart';

enum UrutanPelangganAktifEnum {
  berakhirHariIni('Berakhir Hari Ini'),
  terbaru('Terbaru'),
  terlama('Terlama'),
  tanggalMulai('Tanggal Mulai'),
  tanggalBerakhir('Tanggal Berakhir'),
  lunas('Lunas'),
  belumLunas('Belum Lunas'),
  namaAZ('Nama A-Z'),
  namaZA('Nama Z-A');

  const UrutanPelangganAktifEnum(this.teks);
  final String teks;
}

@riverpod
class UrutanPelangganAktifState extends _$UrutanPelangganAktifState {
  @override
  UrutanPelangganAktifEnum build() {
    return UrutanPelangganAktifEnum.berakhirHariIni;
  }

  void ubahUrutan(UrutanPelangganAktifEnum urutanBaru) {
    state = urutanBaru;
  }
}

int _compareNullableDates(DateTime? a, DateTime? b, {bool ascending = true}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // null dianggap paling besar/lama
  if (b == null) return -1; // non-null dianggap lebih kecil/baru
  return ascending ? a.compareTo(b) : b.compareTo(a);
}

List<DetailPelangganAktifModel> urutkanPelangganAktif(
  List<DetailPelangganAktifModel> data,
  UrutanPelangganAktifEnum sortBy,
) {
  final sorted = List<DetailPelangganAktifModel>.from(data);
  final sekarang = DateTime.now();

  sorted.sort((a, b) {
    switch (sortBy) {
      case UrutanPelangganAktifEnum.berakhirHariIni:
        final sisaHariA = a.pelangganAktif.tanggalBerakhir
            .difference(sekarang)
            .inMilliseconds;
        final sisaHariB = b.pelangganAktif.tanggalBerakhir
            .difference(sekarang)
            .inMilliseconds;

        final lewatA = sisaHariA < 0;
        final lewatB = sisaHariB < 0;

        if (!lewatA && lewatB) return -1;
        if (lewatA && !lewatB) return 1;
        if (!lewatA) {
          return sisaHariA.compareTo(sisaHariB);
        }
        return sisaHariB.compareTo(sisaHariA);

      case UrutanPelangganAktifEnum.terbaru:
        return _compareNullableDates(
          a.pelangganAktif.diperbaruiPada,
          b.pelangganAktif.diperbaruiPada,
          ascending: false,
        );

      case UrutanPelangganAktifEnum.terlama:
        return _compareNullableDates(
          a.pelangganAktif.diperbaruiPada,
          b.pelangganAktif.diperbaruiPada,
        );

      case UrutanPelangganAktifEnum.tanggalMulai:
        return a.pelangganAktif.tanggalMulai.compareTo(
          b.pelangganAktif.tanggalMulai,
        );

      case UrutanPelangganAktifEnum.tanggalBerakhir:
        return b.pelangganAktif.tanggalBerakhir.compareTo(
          a.pelangganAktif.tanggalBerakhir,
        );

      case UrutanPelangganAktifEnum.lunas:
        return a.pelangganAktif.status.index.compareTo(
          b.pelangganAktif.status.index,
        );

      case UrutanPelangganAktifEnum.belumLunas:
        return b.pelangganAktif.status.index.compareTo(
          a.pelangganAktif.status.index,
        );

      case UrutanPelangganAktifEnum.namaAZ:
        return a.namaPelanggan.toLowerCase().compareTo(
          b.namaPelanggan.toLowerCase(),
        );

      case UrutanPelangganAktifEnum.namaZA:
        return b.namaPelanggan.toLowerCase().compareTo(
          a.namaPelanggan.toLowerCase(),
        );
    }
  });
  return sorted;
}

String ambilTeksUrutanPelangganAktif(UrutanPelangganAktifEnum option) =>
    option.teks;
```

// File: lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart

```dart
// path lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailPelangganAktif extends ConsumerStatefulWidget {
  final String idPelangganAktif;
  const DetailPelangganAktif({super.key, required this.idPelangganAktif});
  @override
  ConsumerState<DetailPelangganAktif> createState() =>
      _DetailPelangganAktifState();
}

class _DetailPelangganAktifState extends ConsumerState<DetailPelangganAktif> {
  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman Detail Pelanggan Aktif');
    Log.info('  - ID Pelanggan Aktif: ${widget.idPelangganAktif}');
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

  void _bukaFormEdit(String idPelangganaktif) {
    Log.info('Navigasi ke form edit pelanggan aktif ID: $idPelangganaktif');
    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FormPelangganAktif(idPelangganAktif: idPelangganaktif),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI detail pelanggan aktif untuk ID: ${widget.idPelangganAktif}.',
    );
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final pelangganAktifState = ref.watch(pelangganAktifProvider);
    final pelangganAktif = pelangganAktifState.whenOrNull(
      data: (state) => state.ambilBerdasarkanId(widget.idPelangganAktif),
    );
    final pelangganState = ref.watch(pelangganProvider);
    final pelanggan = pelangganState.whenOrNull(
      data: (state) => state.ambilBerdasarkanId(pelangganAktif!.idPelanggan),
    );
    final paketState = ref.watch(paketProvider);
    final paket = paketState.whenOrNull(
      data: (state) => state.ambilBerdasarkanId(pelangganAktif!.idPaket),
    );
    final transaksiState = ref.watch(transaksiOpProvider);
    final transaksi = transaksiState.whenOrNull(
      data: (state) =>
          state.ambilBerdasarkanIdTransaksi(pelangganAktif!.idTransaksi),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(pelanggan?.nama ?? 'Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.edit),
            onPressed: () => _bukaFormEdit(pelangganAktif?.id ?? ''),
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
                                      idPelanggan:
                                          pelangganAktif?.idPelanggan ?? '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            pelanggan?.nama ??
                                pelangganAktif?.idPelanggan ??
                                '',
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
                          paket?.nama ??
                              ' (ID: ${pelangganAktif?.idPaket ?? ''})',
                        ),
                      ),
                      _buildInfoRow(
                        context,
                        'Status',
                        pelangganAktif?.status.displayName ?? '',
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
                          pelangganAktif!.tanggalMulai,
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
                                idPelangganAktif: widget.idPelangganAktif,
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
```

// File: lib/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart

```dart
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
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart';
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
            title: const Text('Konfirmasi Hapus Semua'),
            content: const Text('Yakin ingin menghapus SEMUA pelanggan aktif?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
        );
        if (konfirmasi == true) {
          try {
            Log.warning('Eksekusi arsipkan semua pelanggan aktif');
            await ref.read(pelangganAktifProvider.notifier).softDeleteAll();
            await ref.read(transaksiOpProvider.notifier).softDeleteAll();
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
            final daftarTerurutAsync = ref.watch(
              daftarPelangganAktifTerurutProvider,
            );
            return daftarTerurutAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (daftarTerurut) {
                final query = _searchController.text.toLowerCase();
                final displayed = daftarTerurut
                    .where((c) => c.namaPelanggan.toLowerCase().contains(query))
                    .toList();

                if (displayed.isEmpty) {
                  return Center(
                    child: Text(
                      query.isNotEmpty
                          ? 'Tidak ditemukan'
                          : 'Tidak ada pelanggan',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displayed.length, // perbaikan: gunakan displayed
                  itemBuilder: (_, i) {
                    final detail = displayed[i];
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
                                  DetailPelangganAktif(idPelangganAktif: c.id),
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
                                  color:
                                      PerhitunganUtil.ambilWarnaSisaMasaAktif(
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
```

// File: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

```dart
// path: lib/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/pelanggan_aktif/helper/pengurut_pelanggan_aktif.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/detail_pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/debug/log.dart';

part 'pelanggan_aktif_provider.g.dart';
part 'pelanggan_aktif_provider.freezed.dart';

@freezed
abstract class PelangganAktifState with _$PelangganAktifState {
  const PelangganAktifState._();
  const factory PelangganAktifState({
    @Default([]) List<PelangganAktifModel> daftarPelangganAktif,
    @Default(0) int jumlahPelangganAktif,
  }) = _PelangganAktifState;

  PelangganAktifModel? ambilBerdasarkanId(String idPelangganAktif) {
    return daftarPelangganAktif.firstWhereOrNull(
      (p) => p.id == idPelangganAktif,
    );
  }
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

  Future<void> perbaruiData() async {
    try {
      await _ambilData();
    } on Exception catch (e, s) {
      Log.error('Error diperbaruiData: $e', e: e, s: s);
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

@riverpod
Future<List<DetailPelangganAktifModel>> daftarPelangganAktifTerurut(
  Ref ref,
) async {
  final pelangganAktifState = await ref.watch(pelangganAktifProvider.future);
  final pelangganState = await ref.watch(pelangganProvider.future);
  final paketState = await ref.watch(paketProvider.future);

  final daftarDetail = pelangganAktifState.daftarPelangganAktif.map((pa) {
    final pelanggan = pelangganState.ambilBerdasarkanId(pa.idPelanggan);
    final paket = paketState.ambilBerdasarkanId(pa.idPaket);
    return DetailPelangganAktifModel(
      pelangganAktif: pa,
      namaPelanggan: pelanggan?.nama ?? '',
      namaPaket: paket?.nama ?? '',
    );
  }).toList();

  final sortBy = ref.watch(urutanPelangganAktifStateProvider);
  return urutkanPelangganAktif(daftarDetail, sortBy);
}
```

// File: lib/fitur/pelanggan/provider/pelanggan_provider.dart

```dart
// path lib/fitur/pelanggan/provider/pelanggan_provider.dart

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'pelanggan_provider.g.dart';
part 'pelanggan_provider.freezed.dart';

@freezed
abstract class PelangganState with _$PelangganState {
  const PelangganState._();
  const factory PelangganState({
    @Default([]) List<PelangganModel> daftarPelanggan,
    @Default(0) int jumlahPelanggan,
    @Default(0) int totalPoin,
  }) = _PelangganState;
  // di dalam PelangganState (freezed)
  PelangganModel? ambilBerdasarkanId(String idPelanggan) {
    // pastikan import 'package:collection/collection.dart';
    return daftarPelanggan.firstWhereOrNull((p) => p.id == idPelanggan);
  }
}

@Riverpod(keepAlive: true)
class Pelanggan extends _$Pelanggan {
  PelangganOpGlobal get _pelangganOp => ref.read(pelangganOpGlobalProvider);
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);

  @override
  FutureOr<PelangganState> build() {
    return _ambilData();
  }

  Future<PelangganState> _ambilData() async {
    final hasil = await _pelangganOp.ambilSemua();
    final hitungPoinFutures = hasil.map(
      (pelanggan) => _transaksiOp.ambilTotalPoin(pelanggan.id),
    );
    final daftarPoin = await Future.wait(hitungPoinFutures);
    final totalPoinSistem = daftarPoin.fold<int>(0, (sum, poin) => sum + poin);
    return PelangganState(
      daftarPelanggan: hasil,
      jumlahPelanggan: hasil.length,
      totalPoin: totalPoinSistem,
    );
  }

  void invalidateDetailPelanggan(String? idPelanggan) {
    ref.invalidateSelf();
    if (idPelanggan != null) {
      ref.invalidate(pelangganDetailProvider(idPelanggan));
    } else {
      ref.invalidate(pelangganDetailProvider);
    }
    ref.invalidate(isSearchingPelangganProvider);
    ref.invalidate(searchQueryPelangganProvider);
    ref.invalidate(namaPelangganProvider);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ambilData();
    });
  }
}

@riverpod
class IsSearchingPelanggan extends _$IsSearchingPelanggan {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setFalse() => state = false;
}

/// Provider generator modern untuk menyimpan text query pencarian pelanggan
@riverpod
class SearchQueryPelanggan extends _$SearchQueryPelanggan {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

@riverpod
Future<String?> namaPelanggan(Ref ref, String idPelanggan) async {
  if (idPelanggan.isEmpty) return null;
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  return pelanggan?.nama;
}

@riverpod
Future<(PelangganModel?, int)> pelangganDetail(
  Ref ref,
  String idPelanggan,
) async {
  final pelangganOp = ref.watch(pelangganOpGlobalProvider);
  final transaksiOp = ref.watch(transaksiOpGlobalProvider);
  final pelanggan = await pelangganOp.ambilBerdasarkanId(idPelanggan);
  final poin = await transaksiOp.ambilTotalPoin(idPelanggan);
  return (pelanggan, poin);
}
```

// File: lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart

```dart
// path: lib/fitur/transaksi/operasi_provider.dart/transaksi_op_provider.dart

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'transaksi_op_provider.freezed.dart';
part 'transaksi_op_provider.g.dart';

@freezed
abstract class TransaksiNotifierState with _$TransaksiNotifierState {
  const TransaksiNotifierState._();
  const factory TransaksiNotifierState({
    @Default([]) List<TransaksiModel> transaksi,
  }) = _TransaksiNotifierState;
  ({List<TransaksiModel> transaksi, int totalPoin}) riwayatPelanggan(
    String idPelanggan,
  ) {
    final miliknya = transaksi
        .where((t) => t.idPelanggan == idPelanggan)
        .toList();
    final poin = miliknya
        .where((t) => t.statusPembayaran == StatusPembayaran.paid)
        .fold<int>(0, (sum, t) => sum + (t.poinDidapat - t.poinDigunakan));
    return (transaksi: miliknya, totalPoin: poin);
  }

  TransaksiModel? ambilBerdasarkanIdTransaksi(String idTransaksi) {
    return transaksi.firstWhereOrNull((t) => t.id == idTransaksi);
  }
}

@riverpod
class TransaksiOp extends _$TransaksiOp {
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);
  @override
  FutureOr<TransaksiNotifierState> build() async {
    final transaksi = await ref.read(transaksiOpGlobalProvider).ambilSemua();
    return TransaksiNotifierState(transaksi: transaksi);
  }

  Future<void> tambah(TransaksiModel transaksi) async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.tambahTransaksi(transaksi);
      final currentData = state.requireValue;
      state = AsyncData(
        currentData.copyWith(transaksi: [...currentData.transaksi, transaksi]),
      );
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(TransaksiModel transaksi) async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.perbaruiTransaksi(transaksi);
      final currentData = state.requireValue;
      final updatedList = currentData.transaksi.map((t) {
        return t.id == transaksi.id ? transaksi : t;
      }).toList();
      state = AsyncData(currentData.copyWith(transaksi: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> hapus(String idTransaksi) async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.softDelete(idTransaksi);
      final currentData = state.requireValue;
      final updatedList = currentData.transaksi
          .where((t) => t.id != idTransaksi)
          .toList();
      state = AsyncData(currentData.copyWith(transaksi: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error hapus: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDeleteAll() async {
    try {
      if (!state.hasValue) return;
      await _transaksiOp.softDeleteAll();
      final currentData = state.requireValue;
      state = AsyncData(currentData.copyWith(transaksi: []));
    } on Exception catch (e, s) {
      Log.error('Error hapus semua: $e', e: e, s: s);
      rethrow;
    }
  }

  void invalidate() {
    ref.invalidateSelf();
  }
}
```

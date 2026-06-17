// path: lib/fitur/pelanggan_aktif/page/detail_pelanggan_aktif.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/paket/page/detail_paket.dart';
import 'package:wifi/fitur/pelanggan/page/admin/detail_pelanggan_a.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/provider/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

final detailPleangganAktifProvider =
    FutureProvider.family<
      ({
        PelangganModel? customer,
        PaketModel? package,
        TransaksiModel? transaction,
        PelangganAktifModel activeCustomer,
      }),
      String
    >((ref, id) async {
      final pelangganAktifState = await ref.watch(
        pelangganAktifProvider.future,
      );
      final detailPelangganAktif = pelangganAktifState.daftarPelangganAktif;

      final detailModel = detailPelangganAktif.firstWhereOrNull(
        (detail) => detail.pelangganAktif.id == id,
      );

      if (detailModel == null) {
        throw Exception('Data pelanggan aktif tidak ditemukan dalam daftar.');
      }

      final pelangganAktif = detailModel.pelangganAktif;

      final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
      final paketOpSqlite = ref.watch(paketOpSqliteProvider);
      final transaksiOpsqlite = ref.watch(transaksiOpSqliteProvider);
      final hasil = await Future.wait<Object?>([
        pelangganOpSqlite.ambilBerdasarkanId(pelangganAktif.idPelanggan),
        pelangganAktif.idPaket.isNotEmpty
            ? paketOpSqlite.ambilBerdasarkanId(pelangganAktif.idPaket)
            : Future<PaketModel?>.value(),
        (pelangganAktif.idTransaksi.isNotEmpty)
            ? transaksiOpsqlite.ambilBerdasarkanId(pelangganAktif.idTransaksi)
            : Future<TransaksiModel?>.value(),
      ]);

      return (
        customer: hasil[0] as PelangganModel?,
        package: hasil[1] as PaketModel?,
        transaction: hasil[2] as TransaksiModel?,
        activeCustomer: pelangganAktif,
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
  Future<void> _launchWhatsApp(String phone) async {
    String formatNomor = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (formatNomor.startsWith('0')) {
      formatNomor = '62${formatNomor.substring(1)}';
    } else if (!formatNomor.startsWith('62')) {
      formatNomor = '62$formatNomor';
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$formatNomor');

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

  Future<void> _navigateToEdit(PelangganAktifModel pelangganaktif) async {
    Log.info('Navigasi ke form edit pelanggan aktif ID: ${pelangganaktif.id}');
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            FormPelangganAktif(pelangganAktif: pelangganaktif),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman Detail Pelanggan Aktif');
    Log.info('  - ID Pelanggan Aktif: ${widget.pelangganAktif.id}');
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
      data: (data) => _buildScaffold(context, data),
      loading: () => const Scaffold(body: Center(child: Text(''))),
      error: (e, s) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ({
      PelangganModel? customer,
      PaketModel? package,
      TransaksiModel? transaction,
      PelangganAktifModel activeCustomer,
    })
    data,
  ) {
    final pelangganAktif = data.activeCustomer;
    final pelanggan = data.customer;
    final paket = data.package;
    final transaksi = data.transaction;

    return Scaffold(
      appBar: AppBar(
        title: Text(pelanggan?.nama ?? 'Detail Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(pelangganAktif),
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
                      if (paket != null)
                        _buildInfoRow(
                          context,
                          'Poin Diperoleh',
                          '${paket.poinHadiah} Poin',
                        ),
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
                        PerhitunganUtil.ambilTeksSisaMasaAktif(
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
            onTap: () => _launchWhatsApp(value),
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

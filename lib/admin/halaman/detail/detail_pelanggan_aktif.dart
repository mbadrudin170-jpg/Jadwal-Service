// path: lib/admin/halaman/detail/detail_pelanggan_aktif.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/admin/providers/pelanggan_aktif_provider.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/fitur/whatsapp/info_paket.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Provider untuk memuat detail lengkap pelanggan aktif secara asinkron.
final activeCustomerDetailProvider = FutureProvider.family<
    ({
      PelangganModel? customer,
      PaketModel? package,
      TransaksiModel? transaction,
      PelangganAktifModel activeCustomer,
    }),
    String>((ref, id) async {
  // 1. Ambil daftar pelanggan aktif dari activeCustomerProvider
  final activeCustomerState = await ref.watch(pelangganAktifProvider.future);
  final activeCustomerDetails = activeCustomerState.daftarPelangganAktif;

  // 2. Cari ActiveCustomerDetailModel yang sesuai dengan ID
  final detailModel = activeCustomerDetails.firstWhereOrNull(
    (detail) => detail.pelangganAktif.id == id,
  );

  if (detailModel == null) {
    throw Exception('Data pelanggan aktif tidak ditemukan dalam daftar.');
  }

  final pelangganAktif = detailModel.pelangganAktif;

  // 3. Fetch detail tambahan menggunakan operasi individual
  final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
  final paketOpSqlite = ref.watch(paketOpSqliteProvider);
  final transaksiOpsqlite = ref.watch(transaksiOpSqliteProvider);
  final hasil = await Future.wait<Object?>([
    pelangganOpSqlite.ambilBerdasarkanId(pelangganAktif.customerId),
    pelangganAktif.packageId.isNotEmpty
        ? paketOpSqlite.ambilBerdasarkanId(pelangganAktif.packageId)
        : Future<PaketModel?>.value(),
    (pelangganAktif.transactionId != null &&
            pelangganAktif.transactionId!.isNotEmpty)
        ? transaksiOpsqlite.ambilBerdasarkanId(pelangganAktif.transactionId!)
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
  // 1. Meluncurkan aplikasi WhatsApp
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

  // 2. Navigasi ke halaman edit pelanggan aktif
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
        'Membangun UI detail pelanggan aktif untuk ID: ${widget.pelangganAktif.id}.');
    final detailAsync =
        ref.watch(activeCustomerDetailProvider(widget.pelangganAktif.id));
    return detailAsync.when(
      data: (data) => _buildScaffold(context, data),
      loading: () => const Scaffold(body: Center(child: Text(''))),
      error: (e, s) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
    );
  }

  // 3. Membangun Scaffold utama halaman detail
  Widget _buildScaffold(
    BuildContext context,
    ({
      PelangganModel? customer,
      PaketModel? package,
      TransaksiModel? transaction,
      PelangganAktifModel activeCustomer
    }) data,
  ) {
    final pelangganAktif = data.activeCustomer;
    final pelanggan = data.customer;
    final paket = data.package;
    final transaksi = data.transaction;

    return Scaffold(
      appBar: AppBar(
        title: Text(pelanggan?.name ?? 'Detail Pelanggan'),
        actions: [
          // 4. Tombol edit di AppBar
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
              // 5. Kartu informasi utama
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // 6. Nama pelanggan (bisa diklik)
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (pelanggan != null) {
                              Log.info(
                                  'Navigasi ke detail pelanggan: ${pelanggan.name}');
                              unawaited(Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPelanggan(
                                    idPelanggan: pelanggan.id,
                                  ),
                                ),
                              ));
                            }
                          },
                          child: Text(
                            pelanggan?.name ?? pelangganAktif.customerId,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.blue),
                          ),
                        ),
                      ),
                      gapH16, // 7. Divider
                      const Divider(), // 8. Baris info WhatsApp
                      _buildWhatsAppInfoRow(
                        // 9. Baris info paket (bisa diklik)
                        context,
                        'No HP',
                        pelanggan?.phone ??
                            'Tidak ditemukan', // 10. Baris info status
                      ),
                      InkWell(
                        onTap: () {
                          if (paket != null) {
                            Log.info('Navigasi ke detail paket: ${paket.name}');
                            unawaited(Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    DetailPaketPage(paket: paket),
                              ),
                            ));
                          }
                        },
                        child: _buildInfoRow(
                          context,
                          'Paket',
                          paket?.name ?? ' (ID: ${pelangganAktif.packageId})',
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
                          '${paket.rewardPoints} Poin',
                        ),
                      if (transaksi != null && (transaksi.durasiBonus ?? 0) > 0)
                        _buildInfoRow(
                          context,
                          'Bonus',
                          '${transaksi.durasiBonus} ${transaksi.durasiBonusType?.displayName ?? ""}',
                        ),
                      _buildInfoRow(
                        context,
                        'Mulai',
                        FormatWaktuLengkap.formatSingkat(
                            pelangganAktif.startDate),
                      ),
                      _buildInfoRow(
                        context,
                        'Berakhir',
                        FormatWaktuLengkap.formatSingkat(
                            pelangganAktif.endDate),
                      ),
                      const Divider(),
                      gapH16,
                      Text(
                        PerhitunganUtil.ambilTeksSisaMasaAktif(
                          pelangganAktif.endDate,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: PerhitunganUtil.ambilWarnaSisaMasaAktif(
                                pelangganAktif.endDate,
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
                          unawaited(ref
                              .read(pesanInfoPaketProvider)
                              .kirimRincianPaket(pelangganAktif));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
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
      BuildContext context, final String label, final String value) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppInfoRow(
      BuildContext context, final String label, final String value) {
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

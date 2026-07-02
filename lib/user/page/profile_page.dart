// path: lib/user/page/profile_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/poin/page/halaman_poin.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/nama_pelanggan_widget.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final PaketOpFirebase _paketOpFirebase;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(interstitialAdServiceProvider).preloadAd());
    _paketOpFirebase = ref.read(paketOpFirebaseProvider);
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value ?? '';
    final transaksiAsync = ref.watch(transaksiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pelanggan')),
      body: transaksiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (daftarTransaksi) {
          final transaksiUser = daftarTransaksi.transaksi.where(
            (t) => t.idPelanggan == userId,
          );
          final totalPoin = transaksiUser.fold<int>(
            0,
            (sum, t) => sum + t.poinDidapat - t.poinDigunakan,
          );
          final totalTagihan = transaksiUser
              .where((t) => t.statusPembayaran == StatusPembayaran.unpaid)
              .fold<double>(0, (sum, t) => sum + t.jumlah);
          final sekarang = DateTime.now();
          final transaksiAktif = transaksiUser
              .where(
                (t) =>
                    t.tanggalBerakhir != null &&
                    t.tanggalBerakhir!.isAfter(sekarang),
              )
              .toList();
          TransaksiModel? paketAktif;
          if (transaksiAktif.isNotEmpty) {
            paketAktif = transaksiAktif.reduce(
              (a, b) => a.tanggalBerakhir!.isAfter(b.tanggalBerakhir!) ? a : b,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transaksiProvider);
              ref.invalidate(pelangganDetailProvider(userId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Kartu Informasi Pribadi
                _buildInfoCard(
                  context,
                  title: 'Informasi Pribadi',
                  icon: TIcons.person,
                  children: [
                    // Nama (widget kustom)
                    _InfoItem(
                      icon: TIcons.personOutlined,
                      label: 'Nama Lengkap',
                      valueKustom: NamaPelangganWidget(
                        idPelanggan: userId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailingIcon: TIcons.chevronRight,
                      onTap: () => _navigasiKeDetail(userId),
                    ),
                    // Poin
                    _InfoItem(
                      icon: TIcons.points,
                      label: 'Poin',
                      value: totalPoin.toString(),
                      trailingIcon: TIcons.chevronRight,
                      onTap: () => _navigasiKePoin(userId),
                    ),
                    // Tagihan (jika ada)
                    if (totalTagihan > 0)
                      _InfoItem(
                        icon: TIcons.money,
                        label: 'Tagihan Belum Lunas',
                        value: FormatUang.formatMataUang(totalTagihan),
                        valueColor: Colors.red,
                      ),
                  ],
                ),
                gapH16,
                // Kartu Informasi Paket Aktif
                _buildInfoCard(
                  context,
                  title: 'Informasi Paket Aktif',
                  icon: TIcons.wifi,
                  children: [
                    if (paketAktif != null)
                      // Ambil detail paket jika perlu
                      FutureBuilder<PaketModel?>(
                        future: paketAktif.idPaket != null
                            ? _paketOpFirebase.ambilBerdasarkanId(
                                paketAktif.idPaket!,
                              )
                            : Future.value(),
                        builder: (context, snapshot) {
                          final paket = snapshot.data;
                          return _buildDetailPaketAktif(
                            context,
                            paketAktif!,
                            paket,
                          );
                        },
                      )
                    else
                      const _InfoItem(
                        icon: TIcons.noWifi,
                        label: 'Paket Aktif',
                        value: 'Tidak ada paket aktif.',
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailPaketAktif(
    BuildContext context,
    TransaksiModel transaksi,
    PaketModel? paket,
  ) {
    if (transaksi.tanggalBerakhir == null) {
      return const _InfoItem(
        icon: TIcons.noWifi,
        label: 'Paket Aktif',
        value: 'Data tidak lengkap.',
      );
    }
    final teksMasaAktif = PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
      transaksi.tanggalBerakhir!,
    );
    final warnaMasaAktif = PerhitunganUtil.ambilWarnaSisaMasaAktif(
      transaksi.tanggalBerakhir!,
    );
    final Color warnaStatuspembayaran =
        transaksi.statusPembayaran == StatusPembayaran.paid
        ? Colors.green
        : Colors.red;
    return Column(
      children: [
        _InfoItem(
          icon: TIcons.wifi,
          label: 'Paket',
          value: paket?.nama ?? 'Tidak tersedia',
        ),
        if (transaksi.tanggalMulai != null)
          _InfoItem(
            icon: TIcons.dateRange,
            label: 'Aktif Sejak',
            value: FormatWaktuLengkap.formatSingkat(transaksi.tanggalMulai!),
          ),
        _InfoItem(
          icon: TIcons.dateRange,
          label: 'Berakhir Pada',
          value: FormatWaktuLengkap.formatSingkat(transaksi.tanggalBerakhir!),
        ),
        _InfoItem(
          icon: TIcons.hourglass,
          label: 'Masa Aktif',
          value: teksMasaAktif,
          valueColor: warnaMasaAktif,
        ),
        _InfoItem(
          icon: TIcons.successOutlined,
          label: 'Status Pembayaran',
          value: transaksi.statusPembayaran.displayName
              .replaceAll('_', ' ')
              .toUpperCase(),
          valueColor: warnaStatuspembayaran,
        ),
        if (transaksi.durasiBonus > 0 && transaksi.tipeDurasiBonus != null)
          _InfoItem(
            icon: TIcons.bonus,
            label: 'Bonus',
            value:
                '${transaksi.durasiBonus} ${transaksi.tipeDurasiBonus!.displayName}',
          ),
      ],
    );
  }

  Future<void> _navigasiKeDetail(String userId) async {
    await ref.read(interstitialAdServiceProvider).show();
    try {
      if (!mounted) return;
      await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (context) => DetailPelanggan(idPelanggan: userId),
        ),
      );
      await ref.read(interstitialAdServiceProvider).show();
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke detail pelanggan.', e: e, s: st);
      if (mounted) ToastUtil.error(context, 'Gagal membuka halaman detail.');
    }
  }

  Future<void> _navigasiKePoin(String idPelanggan) async {
    await ref.read(interstitialAdServiceProvider).show();
    try {
      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<bool>(
          builder: (context) => HalamanPoin(idPelanggan: idPelanggan),
        ),
      );
      await ref.read(interstitialAdServiceProvider).show();
    } on Exception catch (e, st) {
      Log.error('Gagal navigasi ke halaman poin.', e: e, s: st);
      if (mounted) ToastUtil.error(context, 'Gagal membuka halaman poin.');
    }
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                gapW8,
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueKustom;
  final Color? valueColor;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.label,
    this.value,
    this.valueKustom,
    this.valueColor,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                gapH4,
                if (valueKustom != null)
                  valueKustom!
                else
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    ),
                  ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: Colors.grey.shade600, size: 20),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }
}

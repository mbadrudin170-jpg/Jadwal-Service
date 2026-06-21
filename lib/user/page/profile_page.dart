// path: lib/user/page/profile_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan_u.dart';
import 'package:wifi/fitur/poin/page/halaman_poin.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/perhitungan_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_provider.dart';

class _DaataProfil {
  final PelangganModel pelanggan;
  final int totalPoin;
  final TransaksiModel? transaksi;
  final PaketModel? paket;

  _DaataProfil({
    required this.pelanggan,
    required this.totalPoin,
    this.transaksi,
    this.paket,
  });
}

/// Halaman profil pengguna yang menampilkan informasi pribadi dan paket aktif.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final PelangganOpFirebase _pelangganOpFirebase;
  late final TransaksiOpFirebase _transaksiOpFirebase;
  late final PaketOpFirebase _paketOpFirebase;

  // DIUBAH: Hanya satu Future yang mengelola semua data untuk halaman ini.
  Future<_DaataProfil>? _futureProfileData;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(interstitialAdServiceProvider).preloadAd());
    _pelangganOpFirebase = ref.read(pelangganOpFirebaseProvider);
    _transaksiOpFirebase = ref.read(transaksiOpFirebaseProvider);
    _paketOpFirebase = ref.read(paketOpFirebaseProvider);
    _futureProfileData = _loadProfileData();
  }

  // PENJELASAN: Ini adalah inti dari perbaikan. Method ini bertanggung jawab untuk
  // mengambil semua data yang diperlukan secara efisien.
  Future<_DaataProfil> _loadProfileData() async {
    final userId = await ref.watch(userIdProvider.future);
    if (userId == null) {
      throw Exception('ID Pengguna tidak ditemukan, mohon login kembali.');
    }
    Log.info('Memulai pengambilan data profil lengkap untuk userId: $userId.');
    try {
      final pelanggan = await _pelangganOpFirebase.ambilBerdasarkanId(userId);
      if (pelanggan == null) {
        throw Exception('Pelanggan dengan ID  tidak ditemukan.');
      }
      Log.info('Data pelanggan berhasil diambil: ${pelanggan.nama}.');

      final hasil = await Future.wait([
        _transaksiOpFirebase.ambilTotalPoin(pelanggan.id),
        _transaksiOpFirebase.ambilBerdasarkanIdPelanggan(pelanggan.id),
      ]);

      final totalPoin = hasil[0] as int;
      final daftarPaketAktif = hasil[1] as List<TransaksiModel>;
      Log.info(
        'Total poin diambil: $totalPoin. Langganan aktif ditemukan: ${daftarPaketAktif.length}.',
      );
      final sekarang = DateTime.now();
      final daftarMasihAktif = daftarPaketAktif
          .where(
            (trx) =>
                trx.tanggalBerakhir != null &&
                trx.tanggalBerakhir!.isAfter(sekarang),
          )
          .toList();
      TransaksiModel? paketAktif;
      PaketModel? paket;

      if (daftarMasihAktif.isNotEmpty) {
        paketAktif = daftarPaketAktif.reduce(
          (a, b) => a.tanggalBerakhir!.isAfter(b.tanggalBerakhir!) ? a : b,
        );
        Log.info(
          'Langganan terakhir berakhir pada: ${paketAktif.tanggalBerakhir}.',
        );

        if (paketAktif.idPaket != null) {
          paket = await _paketOpFirebase.ambilBerdasarkanId(
            paketAktif.idPaket!,
          );
          Log.info('Detail paket "${paket?.nama}" berhasil diambil.');
        }
      }

      return _DaataProfil(
        pelanggan: pelanggan,
        totalPoin: totalPoin,
        transaksi: paketAktif,
        paket: paket,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal total memuat data profil.', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat data profil.');
      }
      rethrow;
    }
  }

  // Method _reloadData diubah untuk memanggil _initializeData lagi.
  Future<void> _reloadData() async {
    setState(() {
      _futureProfileData = _loadProfileData();
    });
    await _futureProfileData;
    if (mounted) {
      ToastUtil.success(context, 'Data berhasil diperbarui.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI untuk ProfilePage.');
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pelanggan')),
      body: FutureBuilder<_DaataProfil>(
        future: _futureProfileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error(
              'FutureBuilder<_ProfileData> error: ${snapshot.error}.',
              e: snapshot.error,
              s: snapshot.stackTrace,
            );
            return Center(child: Text('Terjadi Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            final userId = ref.watch(userIdProvider);
            return Center(child: Text('Profil ID: $userId tidak ditemukan.'));
          }

          final profileData = snapshot.data!;
          final pelanggan = profileData.pelanggan;

          return RefreshIndicator(
            onRefresh: _reloadData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildInfoCard(
                  context,
                  title: 'Informasi Pribadi',
                  icon: TIcons.person,
                  children: [
                    _InfoItem(
                      icon: TIcons.personOutlined,
                      label: 'Nama Lengkap',
                      value: pelanggan.nama,
                      trailingIcon: TIcons.chevronRight,
                      onTap: () => _navigasiKeDetail(pelanggan.id),
                    ),
                    _InfoItem(
                      icon: TIcons.points,
                      label: 'Poin',
                      value: profileData.totalPoin.toString(),
                      trailingIcon: TIcons.chevronRight,
                      onTap: () => _navigasiKePoin(pelanggan.id),
                    ),
                  ],
                ),
                gapH16,
                _buildInfoCard(
                  context,
                  title: 'Informasi Paket Aktif',
                  icon: TIcons.wifi,
                  children: [
                    _buildDetailPaketAktif(
                      context,
                      profileData.transaksi,
                      profileData.paket,
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
    TransaksiModel? transaksi,
    PaketModel? paket,
  ) {
    if (transaksi == null) {
      return const _InfoItem(
        icon: TIcons.noWifi,
        label: 'Paket Aktif',
        value: 'Tidak ada paket aktif.',
      );
    }

    final String teksMasaAktif = PerhitunganUtil.cobaAmbilTeksSisaMasaAktif(
      transaksi.tanggalBerakhir!,
    );
    final Color warnaMasaAktif = PerhitunganUtil.ambilWarnaSisaMasaAktif(
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
          builder: (context) => DetailPelangganU(userId: userId),
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
          builder: (context) =>
              HalamanPoin(idPelanggan: idPelanggan, tampilkanIklan: true),
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
  final String value;
  final Color? valueColor;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
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
                Text(
                  value,
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

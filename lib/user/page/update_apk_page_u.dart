// path: lib/user/page/update_apk_page_u.dart
// perbaikan: Menghapus penggunaan _isUpdateAvailable yang sudah tidak ada.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/model/package_info_model.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman yang menampilkan detail pembaruan aplikasi dan opsi untuk mengunduh.
class UpdateApkPage extends StatefulWidget {
  /// Informasi versi APK terbaru yang didapat dari proses inisialisasi.
  final ApkVersionModel apkInfo;

  /// Informasi paket aplikasi yang sedang terpasang (versi lokal).
  final PackageInfoModel packageInfo;

  /// Arsitektur perangkat yang terdeteksi (bit64, bit32, universal).
  final ApkArchitectureEnum architecture;

  /// Membuat instance [UpdateApkPage].
  const UpdateApkPage(
      {super.key,
      required this.apkInfo,
      required this.packageInfo,
      required this.architecture});

  @override
  State<UpdateApkPage> createState() => _UpdateApkPageState();
}

class _UpdateApkPageState extends State<UpdateApkPage>
    with SingleTickerProviderStateMixin {
  // Services

  final String _fileSize = 'Tersedia'; // Placeholder, bisa dikembangkan nanti
  late final List<String> _changelog;

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Data changelog dan pembaruan sudah tersedia dari widget
    _changelog = widget.apkInfo.releaseNotes.split('\n');

    // Memulai animasi karena halaman ini hanya muncul jika ada pembaruan
    unawaited(_pulseController.repeat(reverse: true));
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _downloadUpdate() async {
    // Coba ambil link sesuai arsitektur, jika tidak ada fallback ke universal
    String? downloadUrl = widget.apkInfo.downloadLinks[widget.architecture];
    if (downloadUrl == null || downloadUrl.isEmpty) {
      downloadUrl = widget.apkInfo.downloadLinks[ApkArchitectureEnum.universal];
    }

    if (downloadUrl == null || downloadUrl.isEmpty) {
      if (mounted) {
        SnackBarUtil.error(
            context, 'Link download belum tersedia untuk perangkat ini.');
      }
      return;
    }

    Log.info('Mencoba membuka URL download: $downloadUrl');
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Tidak dapat membuka $downloadUrl');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal membuka URL', e: e, st: st);
      if (mounted) {
        SnackBarUtil.error(context, 'Gagal membuka link download.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Update Aplikasi',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildHeaderAnimation(),
            const SizedBox(height: 30),
            _buildVersionCard(),
            const SizedBox(height: 20),
            _buildUpdateStatusCard(),
            const SizedBox(height: 24),
            _buildActionButton(),
            const SizedBox(height: 20),
            _buildChangelogCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (final _, final child) {
        return Transform.scale(
          scale: _pulseAnimation.value, // Langsung gunakan animasi
          child: child,
        );
      },
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withAlpha(102),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            AppIcons.systemUpdate,
            size: 65,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVersionRow(
            icon: AppIcons.phoneAndroid,
            iconColor: const Color(0xFF6C63FF),
            label: 'Versi Saat Ini',
            version: widget.packageInfo.version.split('-').first,
            isCurrent: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1),
          ),
          _buildVersionRow(
            icon: AppIcons.cloudDone,
            iconColor: Colors.orange,
            label: 'Versi Terbaru',
            version: widget.apkInfo.latestVersion.split('-').first,
            isCurrent: false,
            badge: 'BARU',
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow({
    required final IconData icon,
    required final Color iconColor,
    required final String label,
    required final String version,
    required final bool isCurrent,
    final String? badge,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'v$version',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'BARU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withAlpha(77)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.check, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUpdateStatusCard() {
    return _buildStatusContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.warningAmber,
                color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembaruan Tersedia!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  'Ukuran: $_fileSize',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContainer({required final Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _downloadUpdate,
        icon: const Icon(AppIcons.downloadRounded, size: 24),
        label: const Text(
          'Download Update',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildChangelogCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(AppIcons.listAlt,
                    color: Color(0xFFFF6B6B), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Apa yang Baru?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._changelog.map((final item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withAlpha(102),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

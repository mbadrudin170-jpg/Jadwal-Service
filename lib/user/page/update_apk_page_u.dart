// path: lib/user/page/update_apk_page_u.dart
// PERUBAHAN:
// - Menambahkan state `_isDownloading` dan `_downloadProgress` untuk melacak status unduhan.
// - Mengubah `_buildUpdateStatusCard` menjadi dinamis: menampilkan progress bar saat mengunduh.
// - Menonaktifkan tombol "Download" saat unduhan sedang berjalan.
// - Memperbarui `_downloadUpdate` untuk mengelola state dan menangani error.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/model/package_info_model.dart';
import 'package:wifi/shared/services/update_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

class UpdateApkPage extends StatefulWidget {
  final ApkVersionModel apkInfo;
  final PackageInfoModel packageInfo;
  final ApkArchitectureEnum architecture;
  final SharedPreferences prefs;
  final LocalStorageService localStorageService;

  const UpdateApkPage({
    super.key,
    required this.apkInfo,
    required this.packageInfo,
    required this.architecture,
    required this.prefs,
    required this.localStorageService,
  });

  @override
  State<UpdateApkPage> createState() => _UpdateApkPageState();
}

class _UpdateApkPageState extends State<UpdateApkPage>
    with SingleTickerProviderStateMixin {
  late final List<String> _changelog;
  final UpdateService _updateService = UpdateService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // State untuk melacak progres unduhan
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  final String _fileSize = 'Memeriksa...'; // Placeholder awal

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    FlutterNativeSplash.remove();
    _changelog = widget.apkInfo.releaseNotes
        .split('\n')
        .map((final e) => e.trim())
        .where((final e) => e.isNotEmpty)
        .toList();
    unawaited(_pulseController.repeat(reverse: true));
    // TODO: Implementasi pengambilan ukuran file jika memungkinkan
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
    final String? downloadUrl =
        widget.apkInfo.downloadLinks[widget.architecture] ??
            widget.apkInfo.downloadLinks[ApkArchitectureEnum.universal];

    if (downloadUrl == null || downloadUrl.isEmpty) {
      if (mounted) {
        ToastUtil.error(context, 'Link download belum tersedia.');
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final fileName = 'update_v${widget.apkInfo.latestVersion}.apk';

    try {
      await _updateService.downloadAndInstallApk(
        url: downloadUrl,
        fileName: fileName,
        onProgress: (final progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );
      // Jika berhasil, instalasi akan dimulai oleh service.
      // Reset state jika pengguna kembali ke halaman ini.
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengunduh atau install pembaruan', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, e.toString());
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _openTutorial() async {
    final url = widget.apkInfo.youtubeTutorial;
    if (url.isEmpty) {
      if (mounted) {
        ToastUtil.info(context, 'Link tutorial belum tersedia.');
      }
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal membuka URL Tutorial', e: e, st: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal membuka link tutorial.');
      }
    }
  }

  void _skipUpdateAndNavigate() {
    Log.info('Pengguna memilih untuk melewati pembaruan.');

    final userId = widget.prefs.getString('userId');

    if (userId != null) {
      Log.info('Pengguna sudah login. Mengalihkan ke MainPage.');
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (final context) => MainPage(
            userId: userId,
            localStorageService: widget.localStorageService,
          ),
        ),
      ));
    } else {
      Log.info('Pengguna belum login. Mengalihkan ke LoginPage.');
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (final context) => const LoginPage()),
      ));
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
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
            _buildActionButtons(),
            const SizedBox(height: 20),
            if (_changelog.isNotEmpty) _buildChangelogCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isUpdateRequired = widget.apkInfo.isUpdateRequired;
    final hasTutorial = widget.apkInfo.youtubeTutorial.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isDownloading ? null : _downloadUpdate,
            icon: _isDownloading
                ? const SizedBox.shrink()
                : const Icon(AppIcons.downloadRounded, size: 24),
            label: _isDownloading
                ? const Text(
                    'Mengunduh...',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  )
                : const Text(
                    'Download Pembaruan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  _isDownloading ? Colors.grey : const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),
        if (!isUpdateRequired || hasTutorial) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (hasTutorial)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _openTutorial,
                      icon: const Icon(AppIcons.youtube, color: Colors.red),
                      label: const Text(
                        'Tutorial',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withAlpha(100)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasTutorial && !isUpdateRequired) const SizedBox(width: 12),
              if (!isUpdateRequired)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _skipUpdateAndNavigate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderAnimation() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (final _, final child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
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
    if (_isDownloading) {
      return _buildStatusContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mengunduh pembaruan...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

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

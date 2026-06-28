// path: lib/fitur/versi_apk/page/update_apk_page_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/service/update_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_provider.dart';

class UpdateApkPage extends ConsumerStatefulWidget {
  final VersiApkModel infoApk;
  final InfoPerangkatModel infoPaket;
  final ArsitekturApk arsitektur;

  const UpdateApkPage({
    super.key,
    required this.infoApk,
    required this.infoPaket,
    required this.arsitektur,
  });

  @override
  ConsumerState<UpdateApkPage> createState() => _UpdateApkPageState();
}

class _UpdateApkPageState extends ConsumerState<UpdateApkPage>
    with SingleTickerProviderStateMixin {
  late final List<String> _changelog;
  final UpdateService _updateService = UpdateService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // State untuk melacak progres unduhan
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  final String _ukuranFile = 'Memeriksa...'; // Placeholder awal

  @override
  void initState() {
    super.initState();
    _inisialisasiAnimasi();
    FlutterNativeSplash.remove();
    _changelog = widget.infoApk.catatanRilis
        .split('\n')
        .map((final e) => e.trim())
        .where((final e) => e.isNotEmpty)
        .toList();
    _pulseController.repeat(reverse: true);
    // TODO: Implementasi pengambilan ukuran file jika memungkinkan
  }

  void _inisialisasiAnimasi() {
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

  Future<void> _unduhPembaruan() async {
    final String? urlUnduh =
        widget.infoApk.linkDownload[widget.arsitektur] ??
        widget.infoApk.linkDownload[ArsitekturApk.universal];

    if (urlUnduh == null || urlUnduh.isEmpty) {
      if (mounted) {
        ToastUtil.error(context, 'Link download belum tersedia.');
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final namaFile = 'update_v${widget.infoApk.versiTerkahir}.apk';

    try {
      await _updateService.downloadDanInstallApk(
        url: urlUnduh,
        namaFile: namaFile,
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
      Log.error('Gagal mengunduh atau install pembaruan', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, e.toString());
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _bukaTutorial() async {
    final url = widget.infoApk.linkYoutubeTutorial;
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
      Log.error('Gagal membuka URL Tutorial', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal membuka link tutorial.');
      }
    }
  }

  Future<void> _lewatiUpdateDanNavigasi() async {
    final userId = await ref.watch(userIdProvider.future);
    if (userId != null) {
      Log.info('Pengguna sudah login. Mengalihkan ke MainPage.');
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainPage()),
      );
    } else {
      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: ((_) => const LoginPage())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            gapH12,
            _buildAnimasiHeader(),
            gapH32,
            _buildKartuVersi(),
            gapH20,
            _buildKartuStatusUpdate(),
            gapH24,
            _buildTombolAksi(),
            gapH20,
            if (_changelog.isNotEmpty) _buildChangelogCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTombolAksi() {
    final perluUpdate = widget.infoApk.wajibUpdate;
    final adaTutorial = widget.infoApk.linkYoutubeTutorial.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isDownloading ? null : _unduhPembaruan,
            icon: _isDownloading
                ? const SizedBox.shrink()
                : const Icon(TIcons.downloadRounded, size: 24),
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
              backgroundColor: _isDownloading
                  ? Colors.grey
                  : const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
        if (!perluUpdate || adaTutorial) ...[
          gapH12,
          Row(
            children: [
              if (adaTutorial)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _bukaTutorial,
                      icon: const Icon(TIcons.youtube, color: Colors.red),
                      label: const Text(
                        'Tutorial',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withAlpha(77)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              if (adaTutorial && !perluUpdate) gapW12,
              if (!perluUpdate)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _lewatiUpdateDanNavigasi,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildAnimasiHeader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (final _, final child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
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
          child: Icon(TIcons.systemUpdate, size: 65, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildKartuVersi() {
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
          _buildBarisVersi(
            icon: TIcons.phoneAndroid,
            iconColor: const Color(0xFF6C63FF),
            label: 'Versi Saat Ini',
            version: widget.infoPaket.versi.split('-').first,
            apakahSaatIni: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1),
          ),
          _buildBarisVersi(
            icon: TIcons.cloudDone,
            iconColor: Colors.orange,
            label: 'Versi Terbaru',
            version: widget.infoApk.versiTerkahir.split('-').first,
            apakahSaatIni: false,
            lencana: 'BARU',
          ),
        ],
      ),
    );
  }

  Widget _buildBarisVersi({
    required final IconData icon,
    required final Color iconColor,
    required final String label,
    required final String version,
    required final bool apakahSaatIni,
    final String? lencana,
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
        gapW16,
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
              gapH4,
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
                  if (lencana != null) ...[
                    gapW12,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
        if (apakahSaatIni)
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
                Icon(TIcons.check, color: Colors.green, size: 16),
                gapW4,
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

  Widget _buildKartuStatusUpdate() {
    if (_isDownloading) {
      return _buildKontainerStatus(
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
            gapH12,
            LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6C63FF),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            gapH8,
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

    return _buildKontainerStatus(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              TIcons.warningAmber,
              color: Colors.orange,
              size: 22,
            ),
          ),
          gapW12,
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
                  'Ukuran: $_ukuranFile',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKontainerStatus({required final Widget child}) {
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
                child: const Icon(
                  TIcons.listAlt,
                  color: Color(0xFFFF6B6B),
                  size: 22,
                ),
              ),
              gapW12,
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
          gapH20,
          ..._changelog.map(
            (final item) => Padding(
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
                  gapW16,
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
            ),
          ),
        ],
      ),
    );
  }
}

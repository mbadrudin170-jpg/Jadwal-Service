// path: lib/fitur/versi_apk/page/detail_versi_apk.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/apk_version_operation.dart';
import 'package:wifi/fitur/versi_apk/page/form_versi_apk.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class DetailVersiApk extends ConsumerStatefulWidget {
  final VersiApkModel versiApk;
  final VersiApkOpSqlite? versiApkOPSqlite;

  const DetailVersiApk({
    super.key,
    required this.versiApk,
    this.versiApkOPSqlite,
  });

  @override
  ConsumerState<DetailVersiApk> createState() => _DetailVersiApkState();
}

class _DetailVersiApkState extends ConsumerState<DetailVersiApk> {
  late VersiApkModel _currentApkVersion;
  late final VersiApkOpSqlite _apkVersionOperation;

  @override
  void initState() {
    super.initState();
    _currentApkVersion = widget.versiApk;
    _apkVersionOperation =
        widget.versiApkOPSqlite ?? ref.read(versiApkOpSqliteProvider);
  }

  Future<void> _navigasiKeEdit() async {
    Log.info(
        'Tombol edit APK ditekan, versi=${_currentApkVersion.versiTerkahir}');
    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormVersiApk(
          versiApk: _currentApkVersion,
          versiApkOpSqlite: _apkVersionOperation,
        ),
      ),
    );

    if ((hasil ?? false) && mounted) {
      Log.info('Edit APK selesai dengan perubahan, memuat ulang data...');
      unawaited(_reloadData());
    } else {
      Log.info('Edit APK dibatalkan atau tanpa perubahan');
    }
  }

  Future<void> _reloadData() async {
    Log.info('Memuat ulang data untuk ID: ${_currentApkVersion.id}');
    try {
      final allData = await _apkVersionOperation.ambilSemuaVersiApkAktif();
      final freshData = allData.firstWhere(
        (final data) => data.id == _currentApkVersion.id,
        orElse: () => _currentApkVersion,
      );

      if (mounted) {
        setState(() {
          _currentApkVersion = freshData;
        });
        ToastUtil.success(context, 'Data detail telah diperbarui.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal memuat ulang data APK', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal memuat ulang data detail.');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun halaman detail versi APK: ${_currentApkVersion.versiTerkahir}.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Versi APK'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.edit),
            tooltip: 'Edit Data',
            onPressed: _navigasiKeEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(TSizes.p16),
        children: [
          _buildInfoRow('Versi Terbaru', _currentApkVersion.versiTerkahir),
          _buildInfoRow(
              'Wajib Update', _currentApkVersion.wajibUpdate ? 'Ya' : 'Tidak'),
          _buildInfoRow('Catatan Rilis', _currentApkVersion.catatanRilis),
          gapH16,
          Text(
            'Nomor Build Terbaru',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._currentApkVersion.nomorBuildTerakhir.entries.map(
            (entry) => _buildInfoRow(entry.key.name, entry.value.toString()),
          ),
          gapH16,
          Text(
            'Tautan Unduhan',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ..._currentApkVersion.linkDownload.entries.map(
            (entry) => _buildInfoRow(entry.key.name, entry.value),
          ),
          gapH16,
          _buildInfoRow(
              'Youtube Tutorial', _currentApkVersion.linkYoutubeTutorial),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            ': ',
            style: context.textTheme.bodyMedium,
          ),
          Flexible(
            child: Text(
              value,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

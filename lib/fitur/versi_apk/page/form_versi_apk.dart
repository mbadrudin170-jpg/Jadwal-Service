// path: lib/fitur/versi_apk/page/form_versi_apk.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormVersiApk extends ConsumerStatefulWidget {
  final VersiApkModel? versiApk;

  const FormVersiApk(
      {super.key, this.versiApk, final VersiApkOpSqlite? versiApkOpSqlite});
  @override
  ConsumerState<FormVersiApk> createState() => _FormVersiApkState();
}

class _FormVersiApkState extends ConsumerState<FormVersiApk> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool get _modeEdit => widget.versiApk != null;
  late TextEditingController _releaseNotesController;
  late TextEditingController _latestVersionController;
  late TextEditingController _youtubeTutorialController;
  late bool _perluUpdate;
  late TextEditingController _buildUniversalController;
  late TextEditingController _build32Controller;
  late TextEditingController _build64Controller;
  late TextEditingController _universalLinkController;
  late TextEditingController _link32Controller;
  late TextEditingController _link64Controller;
  final _latestVersionFocusNode = FocusNode();
  final _buildUniversalFocusNode = FocusNode();
  final _build32FocusNode = FocusNode();
  final _build64FocusNode = FocusNode();
  final _universalLinkFocusNode = FocusNode();
  final _link32FocusNode = FocusNode();
  final _link64FocusNode = FocusNode();
  final _releaseNotesFocusNode = FocusNode();
  final _youtubeTutorialFocusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Log.info(
      'Menginisialisasi ApkVersionForm (Mode: ${_modeEdit ? 'Edit' : 'Tambah'})',
    );
    _releaseNotesController = TextEditingController();
    _latestVersionController = TextEditingController();
    _youtubeTutorialController = TextEditingController();
    _perluUpdate = false;
    _buildUniversalController = TextEditingController();
    _build32Controller = TextEditingController();
    _build64Controller = TextEditingController();
    _universalLinkController = TextEditingController();
    _link32Controller = TextEditingController();
    _link64Controller = TextEditingController();
    if (_modeEdit) {
      _populateControllers(widget.versiApk!);
    } else {
      unawaited(_muatDataVersiTerakhir());
    }
  }

  Future<void> _muatDataVersiTerakhir() async {
    final apkVersionOperasi = ref.read(versiApkOpSqliteProvider);
    Log.info('Memuat data rilis terakhir untuk otomatisasi input.');
    setState(() => _loading = true);
    try {
      final versiTerakhir = await apkVersionOperasi.ambilVersiApkTerakhir();
      if (versiTerakhir != null && mounted) {
        _latestVersionController.text = versiTerakhir.versiTerkahir;
        _youtubeTutorialController.text = versiTerakhir.linkYoutubeTutorial;
        final buildUniversalBerikutnya =
            (versiTerakhir.nomorBuildTerakhir[ArsitekturApk.universal] ?? 0) +
                1;
        final buildBit32Berikutnya =
            (versiTerakhir.nomorBuildTerakhir[ArsitekturApk.bit32] ?? 0) + 1;
        final buildBit64Berikutnya =
            (versiTerakhir.nomorBuildTerakhir[ArsitekturApk.bit64] ?? 0) + 1;
        _buildUniversalController.text = buildUniversalBerikutnya.toString();
        _build32Controller.text = buildBit32Berikutnya.toString();
        _build64Controller.text = buildBit64Berikutnya.toString();
        Log.info(
          'Data rilis sebelumnya ditemukan. Menyarankan build: $buildUniversalBerikutnya dan menyalin link tutorial.',
        );
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memuat data versi terakhir', e: e, s: s);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _populateControllers(VersiApkModel data) {
    Log.info('Memasukkan data model ke dalam form controller (ID: ${data.id})');
    _releaseNotesController.text = data.catatanRilis;
    _latestVersionController.text = data.versiTerkahir;
    _youtubeTutorialController.text = data.linkYoutubeTutorial;
    _perluUpdate = data.wajibUpdate;
    _buildUniversalController.text =
        data.nomorBuildTerakhir[ArsitekturApk.universal]?.toString() ?? '';
    _build32Controller.text =
        data.nomorBuildTerakhir[ArsitekturApk.bit32]?.toString() ?? '';
    _build64Controller.text =
        data.nomorBuildTerakhir[ArsitekturApk.bit64]?.toString() ?? '';
    _universalLinkController.text =
        data.linkDownload[ArsitekturApk.universal] ?? '';
    _link32Controller.text = data.linkDownload[ArsitekturApk.bit32] ?? '';
    _link64Controller.text = data.linkDownload[ArsitekturApk.bit64] ?? '';
  }

  @override
  void dispose() {
    Log.info('Menghapus semua controller dan focus node (dispose)');
    _releaseNotesController.dispose();
    _latestVersionController.dispose();
    _youtubeTutorialController.dispose();
    _buildUniversalController.dispose();
    _build32Controller.dispose();
    _build64Controller.dispose();
    _universalLinkController.dispose();
    _link32Controller.dispose();
    _link64Controller.dispose();
    _latestVersionFocusNode.dispose();
    _buildUniversalFocusNode.dispose();
    _build32FocusNode.dispose();
    _build64FocusNode.dispose();
    _universalLinkFocusNode.dispose();
    _link32FocusNode.dispose();
    _link64FocusNode.dispose();
    _releaseNotesFocusNode.dispose();
    _youtubeTutorialFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final apkVersionOperasi = ref.read(versiApkOpSqliteProvider);
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Log.info('Menampilkan dialog konfirmasi kepada pengguna');
      FocusScope.of(context).unfocus();
      final konfirmasi = await showDialog<bool>(
        context: context,
        builder: (final context) => AlertDialog(
          title: Row(
            children: [
              Icon(TIcons.infoOutlined, color: context.colorScheme.primary),
              gapW12,
              const Text('Konfirmasi Simpan'),
            ],
          ),
          content: const Text(
            'Apakah data versi aplikasi yang Anda masukkan sudah benar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Periksa Kembali'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, Simpan'),
            ),
          ],
        ),
      );
      if (konfirmasi != true) {
        Log.info('Pengguna membatalkan proses penyimpanan');
        return;
      }
      if (!mounted) return;
      setState(() => _loading = true);
      Log.info('Sedang memproses penyimpanan ke database...');

      final nomorBuild = <ArsitekturApk, int>{};
      if (_buildUniversalController.text.isNotEmpty) {
        nomorBuild[ArsitekturApk.universal] = int.parse(
          _buildUniversalController.text,
        );
      }
      if (_build32Controller.text.isNotEmpty) {
        nomorBuild[ArsitekturApk.bit32] = int.parse(
          _build32Controller.text,
        );
      }
      if (_build64Controller.text.isNotEmpty) {
        nomorBuild[ArsitekturApk.bit64] = int.parse(
          _build64Controller.text,
        );
      }

      final tautanUnduhan = <ArsitekturApk, String>{};
      if (_universalLinkController.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApk.universal] = _universalLinkController.text;
      }
      if (_link32Controller.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApk.bit32] = _link32Controller.text;
      }
      if (_link64Controller.text.isNotEmpty) {
        tautanUnduhan[ArsitekturApk.bit64] = _link64Controller.text;
      }
      final dataToSave = VersiApkModel(
        id: widget.versiApk?.id ?? const Uuid().v4(),
        catatanRilis: _releaseNotesController.text,
        versiTerkahir: _latestVersionController.text,
        linkYoutubeTutorial: _youtubeTutorialController.text,
        wajibUpdate: _perluUpdate,
        nomorBuildTerakhir: nomorBuild,
        linkDownload: tautanUnduhan,
      );
      Log.info('Model Versi APK yang akan disimpan: ${dataToSave.toSqlite()}');
      try {
        if (_modeEdit) {
          Log.info('Menjalankan perintah update data...');
          await apkVersionOperasi.perbaruiVersiApk(dataToSave);
        } else {
          Log.info('Menjalankan perintah tambah data baru...');
          await apkVersionOperasi.tambahVersiApk(dataToSave);
        }

        final isonline = await KoneksiInternetService().cekKoneksiLokal();
        if (isonline) {
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();
        } else {
          Log.info('Tidak ada koneksi internet, melewati proses sinkronisasi.');
          if (mounted) {
            ToastUtil.info(context,
                'Data lokal disimpan. Sinkronisasi akan dilakukan saat online.');
          }
        }

        Log.info('Proses penyimpanan berhasil diselesaikan');
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } on Exception catch (e, s) {
        Log.error('Terjadi kesalahan saat menyimpan data', e: e, s: s);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan data: $e');
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Versi APK' : 'Tambah Versi APK'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                TSizes.p16,
                TSizes.p16,
                TSizes.p16,
                TSizes.p80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _latestVersionController,
                    focusNode: _latestVersionFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Versi Terbaru (Contoh: 1.0.0)',
                      prefixIcon: Icon(TIcons.infoOutlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (final v) => v!.isEmpty ? 'Wajib diisi' : null,
                    onFieldSubmitted: (final _) {
                      FocusScope.of(context)
                          .requestFocus(_buildUniversalFocusNode);
                    },
                  ),
                  gapH24,
                  _buildSectionTitle('Nomor Build'),
                  _buildNumberField(
                    _buildUniversalController,
                    'Build Universal',
                    _buildUniversalFocusNode,
                    _build32FocusNode,
                  ),
                  _buildNumberField(
                    _build32Controller,
                    'Build 32-bit',
                    _build32FocusNode,
                    _build64FocusNode,
                  ),
                  _buildNumberField(
                    _build64Controller,
                    'Build 64-bit',
                    _build64FocusNode,
                    _universalLinkFocusNode,
                  ),
                  gapH24,
                  _buildSectionTitle('Tautan Unduhan'),
                  _buildUrlField(
                    _universalLinkController,
                    'Tautan Universal',
                    _universalLinkFocusNode,
                    _link32FocusNode,
                  ),
                  _buildUrlField(
                    _link32Controller,
                    'Tautan 32-bit',
                    _link32FocusNode,
                    _link64FocusNode,
                  ),
                  _buildUrlField(
                    _link64Controller,
                    'Tautan 64-bit',
                    _link64FocusNode,
                    _releaseNotesFocusNode,
                  ),
                  gapH24,
                  TextFormField(
                    controller: _releaseNotesController,
                    focusNode: _releaseNotesFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Rilis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (final v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  gapH16,
                  TextFormField(
                    controller: _youtubeTutorialController,
                    focusNode: _youtubeTutorialFocusNode,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'URL Tutorial YouTube',
                      prefixIcon: Icon(
                        TIcons.youtube,
                        color: Colors.red,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (final _) => _saveForm(),
                  ),
                  SwitchListTile(
                    title: const Text('Wajib Update'),
                    value: _perluUpdate,
                    onChanged: (final bool value) {
                      Log.info('Switch Wajib Update diubah ke: $value');
                      setState(() => _perluUpdate = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            ColoredBox(
              color: Colors.black.withAlpha(128),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    gapH12,
                    Text(
                      'Menyimpan...',
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: ElevatedButton(
          onPressed: _loading ? null : _saveForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: TSizes.p16),
          ),
          child: const Text('SIMPAN DATA RILIS'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(final String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.p8),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNumberField(
    final TextEditingController controller,
    final String label,
    final FocusNode focusNode,
    final FocusNode? nextFocusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.p12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onFieldSubmitted: (final _) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  Widget _buildUrlField(
    final TextEditingController controller,
    final String label,
    final FocusNode focusNode,
    final FocusNode? nextFocusNode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.p12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(TIcons.link),
        ),
        keyboardType: TextInputType.url,
        onFieldSubmitted: (final _) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }
}

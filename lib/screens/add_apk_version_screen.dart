// path: lib/screens/add_apk_version_screen.dart

import 'package:flutter/material.dart';
import 'package:wifi/services/apk_version_service.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/debug/log.dart';

class AddApkVersionScreen extends StatefulWidget {
  const AddApkVersionScreen({super.key});

  @override
  State<AddApkVersionScreen> createState() => _AddApkVersionScreenState();
}

class _AddApkVersionScreenState extends State<AddApkVersionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apkVersionService = ApkVersionService();
  bool _isLoading = false;

  // Controllers untuk field utama
  final _latestVersionController = TextEditingController();
  final _releaseNotesController = TextEditingController();
  final _youtubeTutorialController = TextEditingController();
  bool _isUpdateRequired = false;

  // Controllers untuk field arsitektur (Map)
  final Map<ApkArchitectureEnum, TextEditingController> _buildNumberControllers = {};
  final Map<ApkArchitectureEnum, TextEditingController> _downloadLinkControllers = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi controllers untuk setiap arsitektur
    for (final arch in ApkArchitectureEnum.values) {
      _buildNumberControllers[arch] = TextEditingController();
      _downloadLinkControllers[arch] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Jangan lupa dispose semua controllers
    _latestVersionController.dispose();
    _releaseNotesController.dispose();
    _youtubeTutorialController.dispose();
    _buildNumberControllers.values.forEach((controller) => controller.dispose());
    _downloadLinkControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ToastUtil.warning(context, 'Harap isi semua field yang wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Membuat Map dari controllers
      final Map<ApkArchitectureEnum, int> latestBuildNumber = {};
      final Map<ApkArchitectureEnum, String> downloadLinks = {};

      for (final arch in ApkArchitectureEnum.values) {
        final buildNumberText = _buildNumberControllers[arch]!.text;
        final downloadLinkText = _downloadLinkControllers[arch]!.text;

        if (buildNumberText.isNotEmpty && downloadLinkText.isNotEmpty) {
          latestBuildNumber[arch] = int.tryParse(buildNumberText) ?? 0;
          downloadLinks[arch] = downloadLinkText;
        }
      }

      if (latestBuildNumber.isEmpty || downloadLinks.isEmpty) {
        ToastUtil.error(context, 'Minimal harus ada satu arsitektur yang diisi lengkap (build number dan link download).');
        setState(() => _isLoading = false);
        return;
      }

      final newVersion = ApkVersionModel(
        latestVersion: _latestVersionController.text,
        releaseNotes: _releaseNotesController.text,
        youtubeTutorial: _youtubeTutorialController.text,
        isUpdateRequired: _isUpdateRequired,
        latestBuildNumber: latestBuildNumber,
        downloadLinks: downloadLinks,
      );

      await _apkVersionService.createVersion(newVersion);

      ToastUtil.success(context, 'Versi APK baru berhasil ditambahkan.');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      Log.error('Gagal menyimpan versi APK', e: e, st: st);
      ToastUtil.error(context, 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Versi APK Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Informasi Utama', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _latestVersionController,
              decoration: const InputDecoration(labelText: 'Versi Terbaru (e.g., 1.0.3)'),
              validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _releaseNotesController,
              decoration: const InputDecoration(labelText: 'Catatan Rilis'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _youtubeTutorialController,
              decoration: const InputDecoration(labelText: 'Link Tutorial YouTube'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Pembaruan Wajib?'),
              value: _isUpdateRequired,
              onChanged: (value) => setState(() => _isUpdateRequired = value),
            ),
            const Divider(height: 40),
            Text('Detail Arsitektur', style: Theme.of(context).textTheme.titleLarge),
            ...ApkArchitectureEnum.values.map((arch) => _buildArchitectureFields(arch)),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan Versi Baru'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureFields(ApkArchitectureEnum arch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(arch.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _buildNumberControllers[arch],
            decoration: const InputDecoration(labelText: 'Nomor Build'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _downloadLinkControllers[arch],
            decoration: const InputDecoration(labelText: 'Link Download APK'),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}

// path: lib/admin/halaman/form/settings_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Form untuk mengubah pengaturan aplikasi.
///
/// Form ini memungkinkan administrator untuk mengubah berbagai parameter
/// aplikasi seperti interval sinkronisasi, kebijakan penghapusan arsip,
/// dan mode pemeliharaan.
class SettingsForm extends ConsumerStatefulWidget {
  final SettingsModel settings;

  const SettingsForm({super.key, required this.settings});

  @override
  ConsumerState<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final SettingsOperation _settingsOperation;
  late TextEditingController _intervalController;
  late TextEditingController _hapusArsipController;
  late TextEditingController _infoPemeliharaanController;
  late bool _modePemeliharaan;

  @override
  void initState() {
    super.initState();
    _settingsOperation = ref.read(settingsOperationProvider);
    Log.info('Menginisialisasi SettingsForm.', {
      'interval': widget.settings.autoSyncInterval,
      'hapus_arsip': widget.settings.autoDeleteArchiveDays,
      'mode_pemeliharaan': widget.settings.maintenanceMode,
      'diperbarui': widget.settings.updatedAt,
    });
    _intervalController = TextEditingController(
      text: '${widget.settings.autoSyncInterval}',
    );
    _hapusArsipController = TextEditingController(
      text: '${widget.settings.autoDeleteArchiveDays}',
    );
    _infoPemeliharaanController =
        TextEditingController(text: widget.settings.maintenanceInfo);
    _modePemeliharaan = widget.settings.maintenanceMode;
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _hapusArsipController.dispose();
    _infoPemeliharaanController.dispose();
    Log.info('Membersihkan controller pada SettingsForm.');
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      Log.info('Memvalidasi dan menyimpan perubahan pengaturan.');
      try {
        final newSettings = SettingsModel(
          id: widget.settings.id, // ID tetap sama
          autoSyncInterval: int.tryParse(_intervalController.text) ?? 24,
          autoDeleteArchiveDays: int.tryParse(_hapusArsipController.text) ?? 30,
          maintenanceMode: _modePemeliharaan,
          maintenanceInfo: _infoPemeliharaanController.text,
        );

        await _settingsOperation.saveOrUpdateSettings(newSettings);
        Log.info('Pengaturan berhasil diperbarui di database.');

        final hasConnection = await InternetConnectionService().isInternetAvailable();
        if (hasConnection) {
          final syncCheckService = ref.read(syncCheckServiceProvider);
          syncCheckService.runSyncCheck();
          if (mounted) {
            ToastUtil.success(
                context, 'Pengaturan berhasil disimpan dan disinkronkan.');
          }
        } else {
          if (mounted) {
            ToastUtil.info(context,
                'Pengaturan disimpan lokal. Sinkronisasi akan dilakukan saat online.');
          }
        }

        if (mounted) {
          Navigator.pop(context, true); // Kembali dengan hasil true
        }
      } on Exception catch (e, st) {
        Log.error('Gagal menyimpan pengaturan.', e: e, st: st);
        if (mounted) {
          ToastUtil.error(context, 'Gagal menyimpan pengaturan: $e');
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(
                controller: _intervalController,
                label: 'Interval Sinkronisasi Otomatis (Jam)',
                icon: Icons.sync,
                keyboardType: TextInputType.number,
                validator: (final value) => (value == null || value.isEmpty)
                    ? 'Harap masukkan interval'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _hapusArsipController,
                label: 'Hapus Arsip Otomatis (Hari)',
                icon: Icons.auto_delete,
                keyboardType: TextInputType.number,
                validator: (final value) => (value == null || value.isEmpty)
                    ? 'Harap masukkan hari'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _infoPemeliharaanController,
                label: 'Info Mode Pemeliharaan',
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required final TextEditingController controller,
    required final String label,
    required final IconData icon,
    final TextInputType keyboardType = TextInputType.text,
    final String? Function(String?)? validator,
    final int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildSwitchTile() {
    return SwitchListTile(
      title: const Text('Mode Pemeliharaan'),
      value: _modePemeliharaan,
      onChanged: (final bool value) {
        setState(() {
          _modePemeliharaan = value;
          Log.info('Mode pemeliharaan diubah menjadi: $value');
        });
      },
      secondary: const Icon(Icons.construction),
    );
  }
}

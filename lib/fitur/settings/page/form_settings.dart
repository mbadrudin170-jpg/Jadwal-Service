// path: lib/fitur/settings/page/form_settings.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/provider/settings_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormSettings extends ConsumerStatefulWidget {
  final SettingsModel settings;

  const FormSettings({super.key, required this.settings});

  @override
  ConsumerState<FormSettings> createState() => _FormSettingsState();
}

class _FormSettingsState extends ConsumerState<FormSettings> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _intervalController;
  late TextEditingController _hapusArsipController;
  late TextEditingController _infoPemeliharaanController;
  late bool _modePemeliharaan;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(
      text: '${widget.settings.waktuOtomatisSinkronisasi}',
    );
    _hapusArsipController = TextEditingController(
      text: '${widget.settings.waktuOtomatisHapusDataArsip}',
    );
    _infoPemeliharaanController = TextEditingController(
      text: widget.settings.infoMaintenance,
    );
    _modePemeliharaan = widget.settings.modeMaintenance;
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _hapusArsipController.dispose();
    _infoPemeliharaanController.dispose();
    Log.info('Membersihkan controller pada SettingsForm.');
    super.dispose();
  }

  Future<void> _simpanSettings() async {
    setState(() {
      _menyimpan = true;
    });
    if (_formKey.currentState!.validate()) {
      Log.info('Memvalidasi dan menyimpan perubahan pengaturan.');
      try {
        final newSettings = SettingsModel(
          waktuOtomatisSinkronisasi:
              int.tryParse(_intervalController.text) ?? 24,
          waktuOtomatisHapusDataArsip:
              int.tryParse(_hapusArsipController.text) ?? 30,
          modeMaintenance: _modePemeliharaan,
          infoMaintenance: _infoPemeliharaanController.text,
        );
        await ref.read(settingsProvider.notifier).tambahAtauUpdate(newSettings);
        Log.info('Pengaturan berhasil diperbarui di database.');
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (mounted) {
          ToastUtil.success(
            context,
            'Pengaturan berhasil disimpan dan disinkronkan.',
          );
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } on Exception catch (e, st) {
        Log.error('Gagal menyimpan pengaturan.', e: e, s: st);
        if (mounted) {
          ToastUtil.error(context, 'Gagal menyimpan pengaturan: $e');
        }
      } finally {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengaturan')),
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
              gapH16,
              _buildTextFormField(
                controller: _hapusArsipController,
                label: 'Hapus Arsip Otomatis (Hari)',
                icon: Icons.auto_delete,
                keyboardType: TextInputType.number,
                validator: (final value) => (value == null || value.isEmpty)
                    ? 'Harap masukkan hari'
                    : null,
              ),
              gapH16,
              _buildSwitchTile(),
              gapH16,
              _buildTextFormField(
                controller: _infoPemeliharaanController,
                label: 'Info Mode Pemeliharaan',
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              gapH32,
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpanSettings,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _menyimpan
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Perubahan'),
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
      onChanged: (bool value) {
        setState(() {
          _modePemeliharaan = value;
          Log.info('Mode pemeliharaan diubah menjadi: $value');
        });
      },
      secondary: const Icon(Icons.construction),
    );
  }
}

// path: lib/admin/halaman/form/form_pengaturan.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';

/// Form untuk mengubah pengaturan aplikasi.
///
/// Form ini memungkinkan administrator untuk mengubah berbagai parameter
/// aplikasi seperti interval sinkronisasi, kebijakan penghapusan arsip,
/// dan mode pemeliharaan.
class FormPengaturan extends StatefulWidget {
  /// Pengaturan saat ini yang akan diedit.
  final PengaturanModel pengaturan;

  /// Operasi untuk berinteraksi dengan data pengaturan.
  /// Ini opsional dan akan dibuat instance-nya jika tidak disediakan.
  final PengaturanOperasi? pengaturanOperasi;

  /// Membuat instance dari [FormPengaturan].
  const FormPengaturan(
      {super.key, required this.pengaturan, this.pengaturanOperasi});

  @override
  State<FormPengaturan> createState() => _FormPengaturanState();
}

class _FormPengaturanState extends State<FormPengaturan> {
  final _formKey = GlobalKey<FormState>();
  late final PengaturanOperasi _pengaturanOperasi;

  late TextEditingController _intervalController;
  late TextEditingController _hapusArsipController;
  late TextEditingController _infoPemeliharaanController;
  late bool _modePemeliharaan;

  @override
  void initState() {
    super.initState();
    _pengaturanOperasi =
        widget.pengaturanOperasi ?? PengaturanOperasi();
    Log.info('Menginisialisasi FormPengaturan.', {
      'interval': widget.pengaturan.intervalSinkronisasiOtomatis,
      'hapus_arsip': widget.pengaturan.hapusOtomatisDataArsip,
      'mode_pemeliharaan': widget.pengaturan.modePemeliharaan,
      'diperbarui': widget.pengaturan.diperbarui,
    });
    _intervalController = TextEditingController(
      text: '${widget.pengaturan.intervalSinkronisasiOtomatis}',
    );
    _hapusArsipController = TextEditingController(
      text: '${widget.pengaturan.hapusOtomatisDataArsip}',
    );
    _infoPemeliharaanController =
        TextEditingController(text: widget.pengaturan.infoPemeliharaan);
    _modePemeliharaan = widget.pengaturan.modePemeliharaan;
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _hapusArsipController.dispose();
    _infoPemeliharaanController.dispose();
    Log.info('Membersihkan controller pada FormPengaturan.');
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      Log.info('Memvalidasi dan menyimpan perubahan pengaturan.');
      try {
        final pengaturanBaru = PengaturanModel(
          id: widget.pengaturan.id, // ID tetap sama
          intervalSinkronisasiOtomatis:
              int.tryParse(_intervalController.text) ?? 24,
          hapusOtomatisDataArsip:
              int.tryParse(_hapusArsipController.text) ?? 30,
          modePemeliharaan: _modePemeliharaan,
          infoPemeliharaan: _infoPemeliharaanController.text,
        );

        await _pengaturanOperasi.updatePengaturan(pengaturanBaru.toSqlite());
        Log.info('Pengaturan berhasil diperbarui di database.');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengaturan berhasil disimpan')),
          );
          Navigator.pop(context, true); // Kembali dengan hasil true
        }
        // diubah: Menggunakan 'on Exception' untuk menangkap error yang lebih spesifik.
      } on Exception catch (e, st) {
        Log.error('Gagal menyimpan pengaturan.', e: e, st: st);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
          );
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
                onPressed: _simpanPerubahan,
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

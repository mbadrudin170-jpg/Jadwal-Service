// path: lib/admin/halaman/form/form_pelanggan.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class FormPelanggan extends ConsumerStatefulWidget {
  final PelangganModel? pelanggan;

  const FormPelanggan({super.key, this.pelanggan});

  @override
  ConsumerState<FormPelanggan> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<FormPelanggan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _alamatFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _macAddressFocusNode = FocusNode();

  bool get _modeEdit => widget.pelanggan != null;
  bool _passwordTerlihat = false;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Membuka CustomerForm dalam mode: ${_modeEdit ? "Edit" : "Tambah"}.',
    );
    if (_modeEdit) {
      Log.info(
        'Mode Edit: Mempopulasikan form dengan data pelanggan ID: ${widget.pelanggan!.id}',
      );
      _namaController.text = widget.pelanggan!.nama;
      _teleponController.text = widget.pelanggan!.telepon;
      _alamatController.text = widget.pelanggan!.alamat;
      _passwordController.text = widget.pelanggan!.kataSandi;
      _macAddressController.text = widget.pelanggan!.macAddress;
    }
  }

  @override
  void dispose() {
    Log.info(
      'Menjalankan dispose di CustomerForm. Membersihkan semua controllers dan focus nodes.',
    );
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _macAddressController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _alamatFocusNode.dispose();
    _passwordFocusNode.dispose();
    _macAddressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanPelanggan() async {
    final pelangganOpSqlite = ref.read(pelangganOpSqliteProvider);
    Log.info('Tombol "Simpan" ditekan.');
    if (_formKey.currentState!.validate()) {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _menyimpan = true);

      final pelangganBaru = PelangganModel(
        id: _modeEdit ? widget.pelanggan!.id : const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        kataSandi: _passwordController.text, // No trim for password
        macAddress: _macAddressController.text.trim().toUpperCase(),
      );

      Log.info(
          'Model Pelanggan yang akan disimpan: ${pelangganBaru.toFirebase()}');

      try {
        if (_modeEdit) {
          Log.info(
            'Menjalankan operasi UPDATE untuk pelanggan ID: ${pelangganBaru.id}',
          );
          await pelangganOpSqlite.perbaruiPelanggan(pelangganBaru);
        } else {
          Log.info(
            'Menjalankan operasi CREATE untuk pelanggan baru: ${pelangganBaru.nama}',
          );
          await pelangganOpSqlite.tambahPelanggan(pelangganBaru);
        }

        if (!mounted) return;

        final cekKoneksi =
            await ref.read(koneksiInternetServiceProvider).cekKoneksiLokal();
        if (cekKoneksi) {
          Log.info('Ada koneksi internet, menjalankan sinkronisasi.');
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();
          if (mounted) {
            ToastUtil.success(
                context, 'Data pelanggan berhasil disimpan & disinkronkan.');
          }
        } else {
          Log.info('Tidak ada koneksi internet, sinkronisasi dilewati.');
          if (mounted) {
            ToastUtil.info(context,
                'Koneksi offline. Data disimpan lokal, akan sinkron saat online.');
          }
        }

        // Membatalkan provider setelah menampilkan toast dan sebelum pop
        ref.invalidate(daftarPelangganProvider);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e, s) {
        Log.error('Gagal menyimpan data pelanggan ke database.', e: e, s: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal menyimpan data: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _menyimpan = false);
          Log.info('Proses penyimpanan selesai. isSaving diatur ke false.');
        }
      }
    } else {
      Log.warning('Form tidak valid. Proses penyimpanan dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI CustomerForm. isSaving: $_menyimpan');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modeEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan',
        ),
        leading: BackButton(
          onPressed: () {
            Log.info('Tombol "Back" ditekan. Kembali tanpa menyimpan.');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  label: 'Nama Pelanggan',
                  icon: TIcons.personOutlined,
                  nextFocus: _teleponFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                gapH16,
                _buildTextField(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  label: 'Nomor Telepon (WhatsApp)',
                  icon: TIcons.phoneAndroid,
                  keyboard: TextInputType.phone,
                  nextFocus: _alamatFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Telepon tidak boleh kosong'
                      : null,
                ),
                gapH16,
                _buildTextField(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  label: 'Alamat Lengkap',
                  icon: TIcons.home,
                  nextFocus: _passwordFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Alamat tidak boleh kosong'
                      : null,
                ),
                gapH16,
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(TIcons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordTerlihat ? TIcons.show : TIcons.hide,
                      ),
                      onPressed: () {
                        Log.info('Visibilitas password diubah.');
                        setState(
                          () => _passwordTerlihat = !_passwordTerlihat,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: !_passwordTerlihat,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_macAddressFocusNode),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                gapH16,
                _buildTextField(
                  controller: _macAddressController,
                  focusNode: _macAddressFocusNode,
                  label: 'MAC Address',
                  icon: TIcons.router,
                  hint: 'XX:XX:XX:XX:XX:XX',
                  action: TextInputAction.done,
                  onSubmitted: (_) => _macAddressFocusNode.unfocus(),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'MAC Address tidak boleh kosong'
                      : null,
                ),
                gapH32,
                ElevatedButton(
                  onPressed: _menyimpan ? null : _simpanPelanggan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'SIMPAN',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required final TextEditingController controller,
    required final FocusNode focusNode,
    required final String label,
    required final IconData icon,
    final String? hint,
    final TextInputType keyboard = TextInputType.text,
    final TextInputAction action = TextInputAction.next,
    final FocusNode? nextFocus,
    final void Function(String)? onSubmitted,
    final String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboard,
      textInputAction: action,
      onFieldSubmitted: (final v) {
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        if (onSubmitted != null) onSubmitted(v);
      },
      validator: validator,
    );
  }
}

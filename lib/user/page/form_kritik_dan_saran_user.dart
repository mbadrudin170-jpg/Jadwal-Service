// path: lib/user/page/form_kritik_dan_saran_user.dart
// diubah: Mengintegrasikan kelas KritikSaranOperasiUser untuk memisahkan logika UI dan data.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/user/data/operasi/kritik_saran_operasi_user.dart'; // diubah: path import diperbarui

/// Halaman formulir untuk mengirim atau mengedit kritik dan saran.
///
/// Jika [kritikId] disediakan, formulir akan berada dalam mode edit.
/// Jika tidak, formulir akan membuat entri baru.
class FormKritikDanSaran extends StatefulWidget {
  /// ID pengguna yang mengirimkan masukan.
  final String userId;

  /// ID kritik yang ada (jika dalam mode edit).
  final String? kritikId;

  /// Nilai awal untuk kolom teks (jika dalam mode edit).
  final String? initialValue;

  /// Membuat instance dari [FormKritikDanSaran].
  const FormKritikDanSaran({
    super.key,
    required this.userId,
    this.kritikId,
    this.initialValue,
  });

  @override
  State<FormKritikDanSaran> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends State<FormKritikDanSaran> {
  final _formKey = GlobalKey<FormState>();
  final _kritikController = TextEditingController();
  bool _isLoading = false;

  // ditambah: Membuat instance dari kelas operasi data.
  final KritikSaranOperasiUser _operasi = KritikSaranOperasiUser(
      FirebaseFirestore.instance); // diubah: nama kelas diperbarui

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _kritikController.text = widget.initialValue!;
    }
  }

  Future<void> _kirimKritik() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.kritikId != null) {
          await _operasi.perbaruiKritikSaran(
            widget.kritikId!,
            _kritikController.text,
          );
        } else {
          final kritikBaru = FeedbackModel(
            isi: _kritikController.text,
            userId: widget.userId,
          );
          await _operasi.buatKritikSaranBaru(kritikBaru);
        }

        if (mounted) {
          SnackBarUtil.success(
              context, 'Terima kasih! Masukan Anda telah disimpan.');
          Navigator.of(context).pop();
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal mengirim kritik dan saran',
          e: e,
          st: s,
        );
        if (mounted) {
          SnackBarUtil.error(context, 'Gagal mengirim masukan: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _kritikController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kritikId != null ? 'Edit Masukan' : 'Beri Masukan'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kritikController,
                decoration: const InputDecoration(
                  labelText: 'Tulis masukan Anda di sini',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (final value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mohon jangan biarkan kolom ini kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _kirimKritik,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.kritikId != null
                            ? 'Simpan Perubahan'
                            : 'Kirim Masukan',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

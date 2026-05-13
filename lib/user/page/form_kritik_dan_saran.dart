// path: lib/user/page/form_kritik_dan_saran.dart
// diubah: Mengintegrasikan kelas KritikSaranOperasiUser untuk memisahkan logika UI dan data.
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/user/data/operasi/kritik_saran_operasi_user.dart'; // diubah: path import diperbarui

class FormKritikDanSaran extends StatefulWidget {
  final String userId;
  final String? kritikId;
  final String? initialValue;

  const FormKritikDanSaran(
      {super.key, required this.userId, this.kritikId, this.initialValue});

  @override
  State<FormKritikDanSaran> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends State<FormKritikDanSaran> {
  final _formKey = GlobalKey<FormState>();
  final _kritikController = TextEditingController();
  bool _isLoading = false;

  // ditambah: Membuat instance dari kelas operasi data.
  final KritikSaranOperasiUser _operasi = KritikSaranOperasiUser(); // diubah: nama kelas diperbarui

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
          final kritikBaru = KritikSaranModel(
            isi: _kritikController.text,
            userId: widget.userId,
          );
          await _operasi.buatKritikSaranBaru(kritikBaru);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terima kasih! Masukan Anda telah disimpan.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e, s) {
        Log.error(
          'Gagal mengirim kritik dan saran',
          e: e,
          st: s,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim masukan: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
  Widget build(BuildContext context) {
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
                validator: (value) {
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
                    : Text(widget.kritikId != null ? 'Simpan Perubahan' : 'Kirim Masukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

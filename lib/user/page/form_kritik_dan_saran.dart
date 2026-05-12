// path: lib/form_kritik_dan_saran.dart
// diubah: menghapus logika pembaruan pada koleksi pelanggan
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class FormKritikDanSaran extends StatefulWidget {
  final String userId;
  final String?
      kritikId; // ditambah: untuk menampung id kritik yang akan di-edit
  final String?
      initialValue; // ditambah: untuk menampung isi kritik yang akan di-edit

  const FormKritikDanSaran(
      {super.key, required this.userId, this.kritikId, this.initialValue});

  @override
  State<FormKritikDanSaran> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends State<FormKritikDanSaran> {
  final _formKey = GlobalKey<FormState>();
  final _kritikController = TextEditingController();
  bool _isLoading = false;

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
          // diubah: logika untuk edit kritik
          // diubah: menggunakan `di_perbarui` untuk mencatat waktu update, bukan `tanggal`
          await FirebaseFirestore.instance
              .collection('kritik_saran')
              .doc(widget.kritikId)
              .update({
            'isi': _kritikController.text,
            'di_perbarui': FieldValue.serverTimestamp(),
          });
        } else {
          // Logika untuk menambah kritik baru
          await FirebaseFirestore.instance.collection('kritik_saran').add({
            'isi': _kritikController.text,
            'tanggal': FieldValue.serverTimestamp(),
            'userId': widget.userId,
          });
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
        developer.log(
          'Gagal mengirim kritik dan saran',
          name: 'KritikDanSaranForm',
          error: e,
          stackTrace: s,
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
        title: Text(widget.kritikId != null
            ? 'Edit Masukan'
            : 'Beri Masukan'), // diubah: judul appbar dinamis
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
                  hintText: 'Contoh: Aplikasinya perlu fitur X...',
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(widget.kritikId != null
                        ? 'Simpan Perubahan'
                        : 'Kirim Masukan'), // diubah: teks tombol dinamis
              ),
            ],
          ),
        ),
      ),
    );
  }
}

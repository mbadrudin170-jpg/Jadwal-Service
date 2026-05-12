
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahDataPage extends StatefulWidget {
  const TambahDataPage({super.key});

  @override
  State<TambahDataPage> createState() => _TambahDataPageState();
}

class _TambahDataPageState extends State<TambahDataPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _simpanData() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('catatan_user').add({
        'catatan': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Kembali ke halaman sebelumnya setelah berhasil menyimpan
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan Baru'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Masukkan Catatan Anda',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _simpanData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Simpan ke Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}

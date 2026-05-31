// path: lib/admin/halaman/lainnya/manage_announcement_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk mengelola pengumuman gambar yang disimpan di Firestore.
/// Admin dapat memperbarui URL gambar (imgBB) dan status keaktifannya.
class ManageAnnouncementPage extends StatefulWidget {
  const ManageAnnouncementPage({super.key});

  @override
  State<ManageAnnouncementPage> createState() => _ManageAnnouncementPageState();
}

class _ManageAnnouncementPageState extends State<ManageAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  bool _isActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentAnnouncement();
  }

  /// Mengambil data pengumuman saat ini dari Firestore.
  Future<void> _fetchCurrentAnnouncement() async {
    setState(() => _isLoading = true);
    Log.info('Mengambil data pengumuman dari Firestore...');
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('announcement')
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _imageUrlController.text = data?['imageUrl'] ?? '';
          _isActive = data?['isActive'] ?? false;
        });
        Log.info('Data pengumuman berhasil dimuat.');
      } else {
        Log.warning('Dokumen pengumuman tidak ditemukan di Firestore.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengambil data pengumuman', e: e, st: st);
      if (mounted) ToastUtil.error(context, 'Gagal memuat data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Menyimpan perubahan URL dan status aktif ke Firestore.
  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Log.info('Menyimpan perubahan pengumuman ke Firestore...');
    try {
      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('announcement')
          .set({
        'imageUrl': _imageUrlController.text.trim(),
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Log.info('Pengumuman berhasil diperbarui.');
      if (mounted)
        ToastUtil.success(context, 'Pengumuman berhasil diperbarui!');
    } on Exception catch (e, st) {
      Log.error('Gagal menyimpan pengumuman', e: e, st: st);
      if (mounted) ToastUtil.error(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengumuman'),
      ),
      body: _isLoading && _imageUrlController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.p16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Pengaturan Papan Pengumuman',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    gapH16,
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL Gambar (Direct Link)',
                        hintText: 'https://i.ibb.co/xxxx/image.jpg',
                        prefixIcon: Icon(TIcons.link),
                        border: OutlineInputBorder(),
                      ),
                      validator: (final value) =>
                          (value == null || value.isEmpty)
                              ? 'URL wajib diisi'
                              : null,
                      onChanged: (final _) => setState(() {}),
                    ),
                    gapH16,
                    SwitchListTile(
                      title: const Text('Aktifkan Pengumuman'),
                      subtitle: const Text(
                          'Muncul di sisi user setelah splash screen.'),
                      value: _isActive,
                      onChanged: (final val) => setState(() => _isActive = val),
                    ),
                    gapH24,
                    const Text('Pratinjau:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    gapH8,
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300)),
                      child: _imageUrlController.text.isNotEmpty
                          ? Image.network(_imageUrlController.text.trim(),
                              fit: BoxFit.contain,
                              errorBuilder: (final _, final __, final ___) =>
                                  const Center(child: Text('URL Tidak Valid')))
                          : const Center(child: Text('Masukkan URL')),
                    ),
                    gapH32,
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveAnnouncement,
                      child: const Text('SIMPAN PERUBAHAN'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

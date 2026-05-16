// path: lib/user/page/kritik_dan_saran_user.dart
// diperbaiki: Mengatasi peringatan 'use_build_context_synchronously' dengan refactoring.
// diperbaiki: Mengatasi peringatan 'discarded_futures' dengan menambahkan async/await.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/user/data/operasi/kritik_saran_operasi_user.dart';
import 'package:wifi/user/page/form_kritik_dan_saran_user.dart';

/// Halaman untuk menampilkan riwayat kritik dan saran yang telah dikirim oleh pengguna.
///
/// Pengguna dapat melihat, mengedit, atau menghapus masukan mereka.
class RiwayatKritikDanSaranPage extends StatefulWidget {
  /// ID pengguna untuk memfilter riwayat kritik dan saran.
  final String userId;

  /// Membuat instance dari [RiwayatKritikDanSaranPage].
  const RiwayatKritikDanSaranPage({super.key, required this.userId});

  @override
  State<RiwayatKritikDanSaranPage> createState() =>
      _RiwayatKritikDanSaranPageState();
}

class _RiwayatKritikDanSaranPageState extends State<RiwayatKritikDanSaranPage> {
  final KritikSaranOperasiUser _operasi =
      KritikSaranOperasiUser(FirebaseFirestore.instance);

  /// Menampilkan dialog dengan pilihan untuk mengedit atau menghapus kritik.
  Future<void> _showOptionsDialog(final FeedbackModel kritik) async {
    await showDialog<void>(
      context: context, // Menggunakan context dari State
      builder: (final dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Aksi'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog pilihan
                await _showDeleteConfirmationAndExecute(
                  kritik.id,
                ); // Tampilkan dialog konfirmasi
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog pilihan
                await Navigator.push<void>(
                  context, // Gunakan context dari State untuk navigasi
                  MaterialPageRoute<void>(
                    builder: (final _) => FormKritikDanSaran(
                      userId: widget.userId,
                      kritikId: kritik.id,
                      initialValue: kritik.isi,
                    ),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  /// Menampilkan dialog konfirmasi dan mengeksekusi penghapusan jika disetujui.
  Future<void> _showDeleteConfirmationAndExecute(final String docId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context, // Menggunakan context dari State
      builder: (final dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Yakin ingin menghapus masukan ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child:
                  const Text('Ya, Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      try {
        await _operasi.hapusKritikSaran(docId);
        if (!mounted) return; // Pemeriksaan mounted sekarang valid
        SnackBarUtil.success(context, 'Masukan berhasil dihapus.');
      } on Exception catch (e) {
        if (!mounted) return;
        SnackBarUtil.error(context, 'Gagal menghapus: $e');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Masukan'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<FeedbackModel>>(
        stream: _operasi.bacaSemuaKritikSaran(widget.userId),
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Anda belum pernah mengirim masukan.'),
            );
          }

          final kritiks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: kritiks.length,
            itemBuilder: (final context, final index) {
              final kritik = kritiks[index];
              final formattedDate = kritik.tanggal != null
                  ? DateFormat.yMMMMd('id_ID').add_jm().format(kritik.tanggal!)
                  : 'Tanggal tidak tersedia';

              final formattedUpdatedDate = kritik.diperbarui != null
                  ? ' (diperbarui: ${DateFormat.yMMMMd('id_ID').add_jm().format(kritik.diperbarui!)})'
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  onTap: () => _showOptionsDialog(
                      kritik), // Panggilan yang sudah direfaktor
                  title: Text(kritik.isi),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '$formattedDate$formattedUpdatedDate',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (final context) =>
                  FormKritikDanSaran(userId: widget.userId),
            ),
          );
        },
        label: const Text('Beri Masukan'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

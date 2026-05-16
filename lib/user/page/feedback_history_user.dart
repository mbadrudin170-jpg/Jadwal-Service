// path: lib/user/page/feedback_history_user.dart
// diubah: Mengganti KritikSaranOperasiUser menjadi FeedbackOpFirebase,
//         hapusKritikSaran → deleteFeedback,
//         bacaSemuaKritikSaran → getFeedbacksByUser.
// diubah: Mengurutkan import directives.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/user/page/user_feedback_form.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Navigasi dari halaman profil atau menu user.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/feedback_model.dart (FeedbackModel)
//   - lib/shared/operasi/firebase_operasi/feedback_op_firebase.dart (FeedbackOpFirebase)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/user/page/form_kritik_dan_saran_user.dart (FormKritikDanSaran)

/// Halaman untuk menampilkan riwayat kritik dan saran yang telah dikirim
/// oleh pengguna.
class FeedbackHistoryPage extends StatefulWidget {
  /// ID pengguna untuk memfilter riwayat kritik dan saran.
  final String userId;

  /// Membuat instance dari [FeedbackHistoryPage].
  const FeedbackHistoryPage({super.key, required this.userId});

  @override
  State<FeedbackHistoryPage> createState() => _FeedbackHistoryPageState();
}

class _FeedbackHistoryPageState extends State<FeedbackHistoryPage> {
  final FeedbackOpFirebase _operation =
      FeedbackOpFirebase(FirebaseFirestore.instance);

  Future<void> _showOptionsDialog(final FeedbackModel feedback) async {
    await showDialog<void>(
      context: context,
      builder: (final dialogContext) {
        return AlertDialog(
          title: const Text('Pilih Aksi'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _showDeleteConfirmationAndExecute(feedback.id);
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (final _) => FormKritikDanSaran(
                      userId: widget.userId,
                      kritikId: feedback.id,
                      initialValue: feedback.content,
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

  Future<void> _showDeleteConfirmationAndExecute(final String docId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
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
        await _operation.deleteFeedback(docId);
        if (!mounted) return;
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
        stream: _operation.getFeedbacksByUser(widget.userId),
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

          final feedbacks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: feedbacks.length,
            itemBuilder: (final context, final index) {
              final feedback = feedbacks[index];
              final formattedDate = feedback.date != null
                  ? DateFormat.yMMMMd('id_ID').add_jm().format(feedback.date!)
                  : 'Tanggal tidak tersedia';

              final formattedUpdatedDate = feedback.updatedAt != null
                  ? ' (diperbarui: ${DateFormat.yMMMMd('id_ID').add_jm().format(feedback.updatedAt!)})'
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  onTap: () => _showOptionsDialog(feedback),
                  title: Text(feedback.content),
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

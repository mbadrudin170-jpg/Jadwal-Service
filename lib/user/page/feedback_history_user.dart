// path: lib/user/page/feedback_history_user.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/form_feedback_u.dart';
import 'package:wifi/user/providers/user_providers.dart';

// DIUBAH: Menjadi ConsumerWidget untuk integrasi Riverpod.
class FeedbackHistoryUser extends ConsumerWidget {
  const FeedbackHistoryUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengambil userId dari provider. `watch` digunakan agar UI rebuild jika user login/logout.
    final userIdAsync = ref.watch(userIdProvider);
    // Mengambil instance operasi feedback. Cukup pakai `read` karena instance-nya tidak akan pernah berubah.
    final feedbackOpFirebase = ref.read(feedbackOpFirebaseProvider);

    // --- Helper Functions (dipindahkan ke dalam build) ---

    Future<void> showDeleteConfirmationAndExecute(
        BuildContext pageContext, String docId) async {
      final bool? shouldDelete = await showDialog<bool>(
        context: pageContext,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Yakin ingin menghapus masukan ini?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              TextButton(
                child: const Text('Ya, Hapus',
                    style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          );
        },
      );

      if (shouldDelete ?? false) {
        try {
          await feedbackOpFirebase.softDeleteFeedback(docId);
          final _ = ref.refresh(userIdProvider);
          ToastUtil.success(pageContext, 'Masukan berhasil dihapus.');
        } on Exception catch (e) {
          ToastUtil.error(pageContext, 'Gagal menghapus: $e');
        }
      }
    }

    Future<void> showOptionsDialog(
        FeedbackModel feedback, String userId) async {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Pilih Aksi'),
            actions: <Widget>[
              TextButton(
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await showDeleteConfirmationAndExecute(context, feedback.id);
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
                        userId: userId, // Menggunakan userId yang sudah valid
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Masukan'),
      ),
      body: userIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Gagal memuat ID Pengguna: $err')),
        data: (userId) {
          if (userId == null) {
            return const Center(
              child: Text('Silakan login untuk melihat riwayat masukan.'),
            );
          }
          return StreamBuilder<List<FeedbackModel>>(
            stream: feedbackOpFirebase.getByUser(userId),
            builder: (context, snapshot) {
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
                itemBuilder: (context, index) {
                  final feedback = feedbacks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      onTap: () => showOptionsDialog(feedback, userId),
                      title: Text(feedback.content),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          feedback.date != null
                              ? FormatDateTime.formatDateAndTimeCompact(
                                  feedback.date!)
                              : '',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: userIdAsync.when(
        data: (userId) {
          if (userId == null) return null;
          return FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => FormKritikDanSaran(userId: userId),
                ),
              );
            },
            label: const Text('Beri Masukan'),
            icon: const Icon(TIcons.add),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

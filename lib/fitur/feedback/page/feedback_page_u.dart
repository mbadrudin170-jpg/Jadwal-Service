// // path: lib/fitur/feedback/page/feedback_page_u.dart

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wifi/fitur/feedback/model/feedback_model.dart';
// import 'package:wifi/fitur/feedback/page/form_feedback_u.dart';
// import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
// import 'package:wifi/shared/theme/app_icons.dart';
// import 'package:wifi/shared/utils/format_util.dart';
// import 'package:wifi/shared/utils/toast_util.dart';
// import 'package:wifi/user/providers/user_provider.dart';

// class FeedbackPageU extends ConsumerWidget {
//   const FeedbackPageU({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final userId = ref.watch(userIdProvider).value ?? '';
//     final feedbackAsync = ref.watch(feedbackStreamProvider(userId));
//     return Scaffold(
//       appBar: AppBar(title: const Text('Riwayat Masukan')),
//       body: feedbackAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, st) => Center(child: Text('Gagal memuat masukan: $e')),
//         data: (feedbacks) {
//           if (feedbacks.isEmpty) {
//             return const Center(
//               child: Text('Anda belum pernah mengirim masukan.'),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: feedbacks.length,
//             itemBuilder: (context, index) {
//               final feedback = feedbacks[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: ListTile(
//                   onTap: () => _showOptionsDialog(context, ref, feedback),
//                   title: Text(feedback.pesan),
//                   subtitle: Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       feedback.tanggal != null
//                           ? FormatWaktuLengkap.formatSingkat(feedback.tanggal!)
//                           : '',
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push<void>(
//           context,
//           MaterialPageRoute(builder: (context) => const FormFeedBackU()),
//         ),
//         label: const Text('Beri Masukan'),
//         icon: const Icon(TIcons.add),
//       ),
//     );
//   }

//   Future<void> _showOptionsDialog(
//     BuildContext context,
//     WidgetRef ref,
//     FeedbackModel feedback,
//   ) async {
//     await showDialog<void>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text('Pilih Aksi'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Hapus', style: TextStyle(color: Colors.red)),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 await _dialogHapus(context, ref, feedback);
//               },
//             ),
//             TextButton(
//               child: const Text('Edit'),
//               onPressed: () async {
//                 Navigator.of(dialogContext).pop();
//                 unawaited(
//                   Navigator.push<void>(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => FormFeedBackU(feedback: feedback),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Batal'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _dialogHapus(
//     BuildContext context,
//     WidgetRef ref,
//     FeedbackModel feedback,
//   ) async {
//     final bool? konfirmasi = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text('Konfirmasi Hapus'),
//           content: const Text('Yakin ingin menghapus masukan ini?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Batal'),
//               onPressed: () => Navigator.of(dialogContext).pop(false),
//             ),
//             TextButton(
//               child: const Text(
//                 'Ya, Hapus',
//                 style: TextStyle(color: Colors.red),
//               ),
//               onPressed: () => Navigator.of(dialogContext).pop(true),
//             ),
//           ],
//         );
//       },
//     );

//     if (konfirmasi ?? false) {
//       try {
//         final feedbackOpFirebase = ref.read(feedbackOpFirebaseProvider);
//         await feedbackOpFirebase.softDelete(feedback.id);
//         ref.invalidate(feedbackStreamProvider(feedback.userId));
//         if (!context.mounted) return;
//         ToastUtil.success(context, 'Masukan berhasil dihapus.');
//       } catch (e, s) {
//         if (!context.mounted) return;
//         ToastUtil.error(context, 'Gagal menghapus: $e $s');
//       }
//     }
//   }
// }

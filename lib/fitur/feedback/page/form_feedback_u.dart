// path: lib/fitur/feedback/page/form_feedback_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/providers/user_provider.dart';

/// Halaman formulir untuk mengirim atau mengedit kritik dan saran.
class FormFeedBackU extends ConsumerStatefulWidget {
  final FeedbackModel? feedback;

  const FormFeedBackU({super.key, this.feedback});

  @override
  ConsumerState<FormFeedBackU> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends ConsumerState<FormFeedBackU> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;
  bool get _modeEdit => widget.feedback != null;

  @override
  void initState() {
    super.initState();
    if (widget.feedback != null) {
      _feedbackController.text = widget.feedback!.pesan;
    }
  }

  Future<void> _simpanForm() async {
    final userId = ref.watch(userIdProvider).value ?? '';
    final feedbackOpFirebase = ref.read(feedbackOpFirebaseProvider);

    if (ref.isUser && userId.isEmpty) {
      ToastUtil.warning(context, 'Silakan login terlebih dahulu');
      return;
    }
    final isOnline = await ref
        .read(koneksiInternetServiceProvider)
        .cekInternet();
    if (ref.isUser && !isOnline) {
      if (mounted) {
        ToastUtil.error(context, 'Cek koneksi internet Anda');
      }
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_modeEdit) {
          final updateFeedback = FeedbackModel(
            id: widget.feedback?.id ?? const Uuid().v4(),
            pesan: _feedbackController.text,
            userId: userId,
          );
          await feedbackOpFirebase.perbarui(updateFeedback);
        } else {
          final tambahFeedback = FeedbackModel(
            id: const Uuid().v4(),
            pesan: _feedbackController.text,
            userId: userId,
          );
          await feedbackOpFirebase.tambah(tambahFeedback);
        }

        if (mounted) {
          ToastUtil.success(
            context,
            'Terima kasih! Masukan Anda telah disimpan.',
          );
          Navigator.of(context).pop();
        }
      } catch (e, s) {
        Log.error('Gagal mengirim kritik dan saran', e: e, s: s);
        if (mounted) {
          ToastUtil.error(context, 'Gagal mengirim masukan: \$e');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Masukan' : 'Beri Masukan'),
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
                controller: _feedbackController,
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
              gapH20,
              ElevatedButton(
                onPressed: _isLoading ? null : _simpanForm,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.feedback != null
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

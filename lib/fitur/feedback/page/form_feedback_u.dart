// path: lib/fitur/feedback/page/form_feedback_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/providers/user_providers.dart';

/// Halaman formulir untuk mengirim atau mengedit kritik dan saran.
class FormFeedBackU extends ConsumerStatefulWidget {
  final String? idFeedback;

  final String? pesan;
  const FormFeedBackU({super.key, this.idFeedback, this.pesan});

  @override
  ConsumerState<FormFeedBackU> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends ConsumerState<FormFeedBackU> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;
  bool get _modeEdit => widget.idFeedback != null;

  @override
  void initState() {
    super.initState();
    if (widget.pesan != null) {
      _feedbackController.text = widget.pesan!;
    }
  }

  Future<void> _simpanForm() async {
    final userId = ref.watch(userIdProvider).value ?? '';
    final feedbackOpFirebase = ref.read(feedbackOpFirebaseProvider);
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_modeEdit) {
          await feedbackOpFirebase.perbaruiFeedback(
            widget.idFeedback!,
            _feedbackController.text,
          );
        } else {
          final dataBaru = FeedbackModel(
            id: const Uuid().v4(),
            pesan: _feedbackController.text,
            userId: userId,
          );
          await feedbackOpFirebase.tambahFeedback(dataBaru);
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
                        widget.idFeedback != null
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

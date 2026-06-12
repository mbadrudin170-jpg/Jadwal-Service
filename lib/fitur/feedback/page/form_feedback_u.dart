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
class FormKritikDanSaran extends ConsumerStatefulWidget {
  final String? kritikId;

  final String? content;
  const FormKritikDanSaran({
    super.key,
    this.kritikId,
    this.content,
  });

  @override
  ConsumerState<FormKritikDanSaran> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends ConsumerState<FormKritikDanSaran> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;
  bool get _isModeEdit => widget.kritikId != null;

  @override
  void initState() {
    super.initState();
    if (widget.content != null) {
      _feedbackController.text = widget.content!;
    }
  }

  Future<void> _saveForm() async {
    final userId = ref.watch(userIdProvider).value ?? '';
    final feedbackOpFirebase = ref.read(feedbackOpFirebaseProvider);
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_isModeEdit) {
          await feedbackOpFirebase.update(
              widget.kritikId!, _feedbackController.text);
        } else {
          final dataBaru = FeedbackModel(
            id: const Uuid().v4(),
            content: _feedbackController.text,
            userId: userId,
          );
          await feedbackOpFirebase.create(dataBaru);
        }

        if (mounted) {
          ToastUtil.success(
              context, 'Terima kasih! Masukan Anda telah disimpan.');
          Navigator.of(context).pop();
        }
      } on Exception catch (e, s) {
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
        title: Text(_isModeEdit ? 'Edit Masukan' : 'Beri Masukan'),
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
                onPressed: _isLoading ? null : _saveForm,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.kritikId != null
                        ? 'Simpan Perubahan'
                        : 'Kirim Masukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

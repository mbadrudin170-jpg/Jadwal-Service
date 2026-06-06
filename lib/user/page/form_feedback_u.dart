// path: lib/user/page/form_feedback_u.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman formulir untuk mengirim atau mengedit kritik dan saran.
class FormKritikDanSaran extends StatefulWidget {
  final String userId;

  final String? kritikId;

  final String? initialValue;
  const FormKritikDanSaran({
    super.key,
    required this.userId,
    this.kritikId,
    this.initialValue,
  });

  @override
  State<FormKritikDanSaran> createState() => _FormKritikDanSaranState();
}

class _FormKritikDanSaranState extends State<FormKritikDanSaran> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;
  final FeedbackOpFirebase _feedbackOpFirebase =
      FeedbackOpFirebase(firestore: FirebaseFirestore.instance);

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _feedbackController.text = widget.initialValue!;
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (widget.kritikId != null) {
          await _feedbackOpFirebase.update(
              widget.kritikId!, _feedbackController.text);
        } else {
          final newFeedback = FeedbackModel(
            content: _feedbackController.text,
            userId: widget.userId,
          );
          await _feedbackOpFirebase.create(newFeedback);
        }

        if (mounted) {
          ToastUtil.success(
              context, 'Terima kasih! Masukan Anda telah disimpan.');
          Navigator.of(context).pop();
        }
      } on Exception catch (e, s) {
        Log.error('Gagal mengirim kritik dan saran', e: e, st: s);
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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kritikId != null ? 'Edit Masukan' : 'Beri Masukan'),
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
                validator: (final value) {
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

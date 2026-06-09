// path: lib/shared/widget/input/input_teks.dart

import 'package:flutter/material.dart';

class InputTeks extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool wajib;
  const InputTeks({
    super.key,
    required this.controller,
    required this.label,
    required this.wajib,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (wajib && (value == null || value.trim().isEmpty)) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }
}

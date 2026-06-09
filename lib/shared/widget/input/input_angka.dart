// path: lib/shared/widget/input/input_angka.dart

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';

class InputAngka extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool wajib;
  const InputAngka({
    super.key,
    required this.controller,
    required this.label,
    required this.wajib,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        CurrencyTextInputFormatter.currency(
          locale: 'id',
          symbol: '',
          decimalDigits: 0,
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (wajib && (value == null || value.trim().isEmpty)) {
          return '$label wajib diisi';
        }
        final angka = int.tryParse(value ?? '');
        if (angka == null) {
          return '$label harus berupa angka';
        }
        if (angka <= 0) {
          return '$label harus lebih dari 0';
        }
        return null;
      },
    );
  }
}

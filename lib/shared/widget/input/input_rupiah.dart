// path: lib/shared/widget/input/input_rupiah.dart

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';

class InputRupiah extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool wajib;
  const InputRupiah({
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
          symbol: 'Rp ',
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
        return null;
      },
    );
  }
}

// path: lib/shared/widget/input/input_angka.dart

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';

class InputAngka extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool wajib;
  final IconData? prefixIcon;
  final bool? validasi;
  final TextInputAction textInputAction;
  final bool enabled;
  final TextInputType keyboardType;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;

  const InputAngka({
    super.key,
    required this.controller,
    this.label = 'Nomor Telepon',
    this.wajib = true,
    this.prefixIcon,
    this.validasi = false,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autovalidateMode: autovalidateMode,
      textInputAction: textInputAction,
      enabled: enabled,
      focusNode: focusNode,
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
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: (value) {
        if (wajib && validasi! && (value == null || value.trim().isEmpty)) {
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

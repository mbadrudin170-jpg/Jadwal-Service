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
  final FocusNode? nextFocusNode;
  final void Function(String)? onSubmitted;

  const InputAngka({
    super.key,
    required this.controller,
    this.label = 'Jumlah',
    this.wajib = true,
    this.prefixIcon,
    this.validasi = false,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
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
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: (v) {
        if (onSubmitted != null) {
          onSubmitted!(v);
        }
        if (textInputAction == TextInputAction.done && nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else if (textInputAction == TextInputAction.done) {
          FocusScope.of(context).unfocus();
        }
      },
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
        final cleanValue = (value ?? '').replaceAll('.', '').trim();
        if (cleanValue.isEmpty) {
          if (wajib) {
            return '$label wajib diisi';
          }
          return null;
        }
        final angka = int.tryParse(cleanValue);
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

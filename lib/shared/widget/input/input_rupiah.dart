// path: lib/shared/widget/input/input_rupiah.dart

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';

class InputRupiah extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool wajib;
  final IconData? prefixIcon;
  final TextInputAction textInputAction;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final void Function(String)? onSubmitted;

  static final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      );

  /// Mengembalikan nilai numerik murni dari teks terformat.
  double get numericValue {
    final unformatted = _formatter.getUnformattedValue();
    return double.tryParse(unformatted.toString()) ?? 0.0;
  }

  static double parse(String formatted) {
    // Hapus "Rp", spasi, titik (pemisah ribuan)
    String cleaned = formatted.replaceAll(RegExp(r'[Rp.\s]'), '');
    // Ganti koma desimal (jika ada) ke titik
    cleaned = cleaned.replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  const InputRupiah({
    super.key,
    required this.controller,
    this.label = 'Jumlah',
    this.wajib = true,
    this.prefixIcon,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autovalidateMode: autovalidateMode,
      textInputAction: textInputAction,
      enabled: enabled,
      focusNode: focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: (v) {
        if (onSubmitted != null) {
          onSubmitted!(v);
        }
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
      inputFormatters: [_formatter],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
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

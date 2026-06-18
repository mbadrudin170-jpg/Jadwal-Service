// path lib/shared/widget/input/input_telepon.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTelepon extends StatelessWidget {
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

  const InputTelepon({
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
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: (value) {
        if (wajib && validasi! && (value == null || value.trim().isEmpty)) {
          return '$label wajib diisi';
        }
        if (value != null &&
            value.trim().isNotEmpty &&
            value.trim().length < 10) {
          return 'Nomor telepon minimal 10 digit';
        }
        return null;
      },
    );
  }
}

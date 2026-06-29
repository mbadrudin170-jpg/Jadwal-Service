// path: lib/shared/widget/input/input_teks.dart

import 'package:flutter/material.dart';

class InputTeks extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool wajib;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool enabled;
  final void Function(String)? onSubmitted;

  const InputTeks({
    super.key,
    required this.controller,
    required this.label,
    this.wajib = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.focusNode,
    this.nextFocusNode,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: autovalidateMode,
      textInputAction: textInputAction,
      enabled: enabled,
      focusNode: focusNode,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      onFieldSubmitted: (v) {
        if (onSubmitted != null) {
          onSubmitted!(v);
        }
        if (textInputAction == TextInputAction.next && nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else if (textInputAction == TextInputAction.done) {
          FocusScope.of(context).unfocus();
        }
      },
      validator:
          validator ??
          (value) {
            if (wajib && (value == null || value.trim().isEmpty)) {
              return '$label wajib diisi';
            }
            return null;
          },
    );
  }
}

// path: lib/shared/widget/input/input_password.dart

// lib/shared/widget/input_password.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/export/theme.dart';

class InputPassword extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final Widget prefixIcon;
  final TextInputAction textInputAction;
  final bool enabled;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final void Function(String)? onSubmitted;

  const InputPassword({
    super.key,
    required this.controller,
    this.validator,

    this.label = 'Password',
    this.enabled = true,
    this.prefixIcon = const Icon(TIcons.lock),
    this.textInputAction = TextInputAction.next,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
  });

  @override
  State<InputPassword> createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  bool passwordTersembunyi = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: passwordTersembunyi,
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (v) {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        }
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(v);
        }
      },
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      enabled: widget.enabled,
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            return null;
          },

      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon,
        suffixIcon: IconButton(
          icon: Icon(
            passwordTersembunyi ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              passwordTersembunyi = !passwordTersembunyi;
            });
          },
        ),
      ),
    );
  }
}

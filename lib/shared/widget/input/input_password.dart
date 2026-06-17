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
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final AutovalidateMode autovalidateMode;

  const InputPassword({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.enabled = true,
    this.prefixIcon = const Icon(TIcons.lock),
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
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
      obscureText: passwordTersembunyi,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
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

// path: lib/shared/widget/input/input_password.dart

// lib/shared/widget/input_password.dart

import 'package:flutter/material.dart';

class InputPassword extends StatefulWidget {
  const InputPassword({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

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
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            passwordTersembunyi ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(
              () {
                passwordTersembunyi = !passwordTersembunyi;
              },
            );
          },
        ),
      ),
    );
  }
}

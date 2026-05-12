import 'package:flutter/material.dart';

class CustomTextInputField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType; // Added this line

  const CustomTextInputField({
    super.key,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType, // Added this line
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType, // Added this line
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(50),
      ),
    );
  }
}

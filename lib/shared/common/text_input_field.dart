// path: lib/shared/common/text_input_field.dart
// Fitur: Widget
// Tujuan: Menyediakan widget input teks yang dapat digunakan kembali dengan kustomisasi.

import 'package:flutter/material.dart';

/// Sebuah widget [TextFormField] yang dikustomisasi untuk penggunaan umum dalam aplikasi.
///
/// Menyediakan styling yang konsisten dan menyederhanakan pembuatan form.
class CustomTextInputField extends StatelessWidget {
  /// Teks yang ditampilkan sebagai label di atas field.
  final String labelText;

  /// Teks petunjuk yang ditampilkan di dalam field saat kosong.
  final String? hintText;

  /// Ikon yang ditampilkan di awal field.
  final IconData? prefixIcon;

  /// Apakah teks harus disamarkan (misalnya, untuk password).
  final bool obscureText;

  /// Controller untuk mengelola teks di dalam field.
  final TextEditingController? controller;

  /// Validator untuk memvalidasi input dari pengguna.
  final FormFieldValidator<String>? validator;

  /// Callback yang dipanggil setiap kali nilai di dalam field berubah.
  final ValueChanged<String>? onChanged;

  /// Tipe keyboard yang akan ditampilkan saat field ini mendapatkan fokus.
  final TextInputType? keyboardType;

  /// Konstruktor untuk membuat instance dari [CustomTextInputField].
  const CustomTextInputField({
    super.key,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
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

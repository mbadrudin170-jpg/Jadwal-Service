// path: lib/shared/widget/input/input_mac_address.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/widget/input/formatter/mac_address_formatter.dart';

/// Widget input khusus untuk MAC Address dengan format otomatis
/// Contoh: 00:1B:44:11:3A:B7
class InputMacAddress extends StatelessWidget {
  /// Controller untuk input MAC Address
  final TextEditingController controller;

  /// Label yang ditampilkan
  final String label;

  /// Apakah field wajib diisi
  final bool wajib;

  /// Validator tambahan (opsional)
  final String? Function(String?)? validator;

  /// Mode autovalidate
  final AutovalidateMode autovalidateMode;

  /// Action keyboard
  final TextInputAction textInputAction;

  /// Apakah input enabled
  final bool enabled;

  /// FocusNode
  final FocusNode? focusNode;

  /// FocusNode berikutnya
  final FocusNode? nextFocusNode;

  /// Callback saat submit
  final void Function(String)? onSubmitted;

  const InputMacAddress({
    super.key,
    required this.controller,
    this.label = 'MAC Address',
    this.wajib = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.focusNode,
    this.nextFocusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      textInputAction: textInputAction,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        MacAddressFormatter(), // ✅ Format otomatis
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9a-fA-F:]'),
        ), // Hanya hex dan colon
      ],
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onFieldSubmitted: (value) {
        if (onSubmitted != null) {
          onSubmitted!(value);
        }
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode!);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(TIcons.router),
        hintText: '00:1B:44:11:3A:B7',
        helperText: 'Format: XX:XX:XX:XX:XX:XX',
        helperStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      validator: validator ?? _defaultValidator,
    );
  }

  /// Validator default untuk MAC Address
  String? _defaultValidator(String? value) {
    if (wajib && (value == null || value.trim().isEmpty)) {
      return 'MAC Address wajib diisi';
    }

    if (value != null && value.trim().isNotEmpty) {
      final trimmed = value.trim();
      // Format harus 17 karakter (6 pasang + 5 titik dua)
      if (trimmed.length != 17) {
        return 'MAC Address harus 6 pasang (contoh: 00:1B:44:11:3A:B7)';
      }
      // Validasi format regex
      final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
      if (!regex.hasMatch(trimmed)) {
        return 'Format MAC Address tidak valid (contoh: 00:1B:44:11:3A:B7)';
      }
    }
    return null;
  }
}

// path: lib/shared/widget/input/formatter/mac_address_formatter.dart

import 'package:flutter/services.dart';

/// TextInputFormatter untuk memformat MAC Address secara otomatis
/// Contoh: 001B44113AB7 → 00:1B:44:11:3A:B7
class MacAddressFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Hanya izinkan karakter hex (0-9, A-F, a-f)
    final regex = RegExp(r'[^0-9a-fA-F]');
    String cleaned = newValue.text.replaceAll(regex, '');
    
    // Batasi maksimal 12 karakter (6 pasang)
    if (cleaned.length > 12) {
      cleaned = cleaned.substring(0, 12);
    }
    
    // Format dengan : setiap 2 karakter
    String formatted = '';
    for (int i = 0; i < cleaned.length; i += 2) {
      if (i > 0) {
        formatted += ':';
      }
      formatted += cleaned.substring(i, i + 2 > cleaned.length ? cleaned.length : i + 2);
    }
    
    // Hitung posisi kursor
    int cursorPosition = formatted.length;
    if (newValue.selection.baseOffset < oldValue.text.length) {
      cursorPosition = newValue.selection.baseOffset;
      // Sesuaikan posisi kursor dengan format
      int charCount = 0;
      int colonCount = 0;
      for (int i = 0; i < cursorPosition && i < cleaned.length; i++) {
        charCount++;
        if (charCount % 2 == 0 && charCount < cleaned.length) {
          colonCount++;
        }
      }
      cursorPosition = charCount + colonCount;
    }
    
    return TextEditingValue(
      text: formatted.toUpperCase(),
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
// path: lib/widget/thousands_input_formatter.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatter untuk TextField agar dapat menampilkan format angka ribuan secara otomatis.
// diubah: Nama kelas diperbarui untuk mencerminkan dukungan angka negatif.
class ThousandsAndNegativeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // dihapus: Logika lama yang tidak efisien dalam menangani string kosong.
    // if (newValue.text.isEmpty) {
    //   return newValue.copyWith(text: '');
    // }

    // ditambah: Jika teks baru kosong setelah di-trim, kembalikan nilai kosong. Lebih andal.
    if (newValue.text.trim().isEmpty) {
      return newValue.copyWith(text: '');
    }

    // ditambah: Jika pengguna baru saja mengetik '-', izinkan dan tunggu input selanjutnya.
    if (newValue.text == '-') {
      return newValue;
    }

    // diubah: Logika dimodifikasi sepenuhnya untuk mendukung angka negatif.
    // Simpan status negatif.
    final bool isNegative = newValue.text.startsWith('-');

    // Ambil hanya digit dari string.
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // ditambah: Jika tidak ada digit (misalnya, setelah menghapus '-'),
    // pertahankan tanda '-' agar pengguna bisa lanjut mengetik angka.
    if (digitsOnly.isEmpty) {
      // ditambah: hanya kembalikan tanda '-' jika memang dimulai dengan itu.
      if (isNegative) {
        return const TextEditingValue(
          text: '-',
          selection: TextSelection.collapsed(offset: 1),
        );
      }
      // ditambah: jika tidak, itu adalah input yang tidak valid (bukan angka), jadi kembalikan nilai lama.
      return oldValue;
    }

    // Konversi string digit menjadi angka.
    final number = int.tryParse(digitsOnly);
    // diubah: Menggunakan nilai lama (oldValue) sebagai fallback yang lebih aman jika parsing gagal.
    if (number == null) {
      return oldValue;
    }

    // Format angka menggunakan NumberFormat dari package 'intl'.
    final formatter = NumberFormat('#,###', 'id_ID');
    final String formattedNumber = formatter.format(number);

    // Gabungkan kembali tanda negatif jika ada.
    final String newText = isNegative ? '-$formattedNumber' : formattedNumber;

    // Kembalikan nilai yang sudah diformat dengan posisi kursor di akhir.
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

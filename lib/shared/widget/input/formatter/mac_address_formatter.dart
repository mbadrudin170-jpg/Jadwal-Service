// path: lib/shared/widget/input/formatter/mac_address_formatter.dart

import 'package:flutter/services.dart';

class MacAddressFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue nilaiLama, // oldValue diubah
    TextEditingValue nilaiBaru, // newValue diubah
  ) {
    if (nilaiBaru.text.isEmpty) {
      return nilaiBaru;
    }

    final sedangMenghapus =
        nilaiBaru.text.length < nilaiLama.text.length; // isDeleting diubah

    // 1. Bersihkan teks, sisakan karakter heksadesimal saja
    var teksBersih = nilaiBaru.text.toUpperCase().replaceAll(
      // cleaned diubah
      RegExp(r'[^0-9A-F]'),
      '',
    );

    // 2. Hitung ada berapa karakter sebelum posisi kursor
    var karakterBersihSebelumKursor = nilaiBaru
        .text // cleanCharsBeforeCursor diubah
        .substring(0, nilaiBaru.selection.baseOffset)
        .replaceAll(RegExp(r'[^0-9A-Fa-f]'), '')
        .length;

    // 3. PENANGANAN BACKSPACE
    if (sedangMenghapus &&
        nilaiLama.text.endsWith(':') &&
        nilaiBaru.text.length == nilaiLama.text.length - 1) {
      if (teksBersih.isNotEmpty) {
        teksBersih = teksBersih.substring(0, teksBersih.length - 1);
        karakterBersihSebelumKursor--;
      }
    }

    // 4. Batasi input maksimal 12 karakter
    if (teksBersih.length > 12) {
      teksBersih = teksBersih.substring(0, 12);
    }

    // 5. Rangkai ulang teksnya dan tambahkan ':'
    final penampung = StringBuffer(); // buffer diubah
    for (var i = 0; i < teksBersih.length; i++) {
      penampung.write(teksBersih[i]);
      if ((i + 1) % 2 == 0 && (i + 1) < 12) {
        penampung.write(':');
      }
    }
    final teksTerformat = penampung.toString(); // formatted diubah

    // 6. Sesuaikan posisi kursor
    var posisiKursor = 0; // cursorIndex diubah
    var jumlahBersih = 0; // cleanCount diubah
    for (var i = 0; i < teksTerformat.length; i++) {
      if (jumlahBersih == karakterBersihSebelumKursor) {
        break;
      }
      if (teksTerformat[i] != ':') {
        jumlahBersih++;
      }
      posisiKursor++;
    }

    if (posisiKursor < teksTerformat.length &&
        teksTerformat[posisiKursor] == ':') {
      posisiKursor++;
    }

    return TextEditingValue(
      text: teksTerformat,
      selection: TextSelection.collapsed(offset: posisiKursor),
    );
  }
}

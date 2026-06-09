// path: lib/shared/common/text.dart

import 'package:flutter/material.dart';

// 1. KELAS DASAR (ABSTRAK)
// Kelas ini tidak bisa digunakan langsung, tapi berfungsi sebagai kerangka
// untuk semua widget teks lainnya, menangani logika yang sama seperti
// penimpaan warna, perataan, dll.

abstract class _TeksDasar extends StatelessWidget {
  /// Teks yang akan ditampilkan.
  final String data;

  /// Properti opsional untuk override gaya default.
  final Color? warna;
  final FontWeight? tebalFont;
  final TextAlign? rataTeks;
  final int? maksBaris;
  final TextOverflow? luapan;
  final bool garisBawah;
  final double? tinggiBaris;

  const _TeksDasar(
    this.data, {
    super.key,
    this.warna,
    this.tebalFont,
    this.rataTeks,
    this.maksBaris,
    this.luapan,
    this.garisBawah = false,
    this.tinggiBaris,
  });

  /// Setiap widget turunan (seperti TeksJudulBesar) harus mendefinisikan
  /// dari mana ia mengambil gaya dasarnya.
  TextStyle? dapatkanGayaDasar(BuildContext context);

  @override
  Widget build(BuildContext context) {
    // Mengambil gaya dasar dari kelas turunan.
    final gayaDasar = dapatkanGayaDasar(context);

    // Menggabungkan gaya dasar dengan properti override (jika ada).
    final gayaAkhir = (gayaDasar ?? const TextStyle()).copyWith(
      color: warna,
      fontWeight: tebalFont,
      decoration: garisBawah ? TextDecoration.underline : null,
      decorationColor: warna,
      height: tinggiBaris,
    );

    // Mengembalikan widget Text standar dengan gaya yang sudah diproses.
    return Text(
      data,
      style: gayaAkhir,
      textAlign: rataTeks,
      maxLines: maksBaris,
      overflow: luapan,
    );
  }
}

// 2. KUMPULAN WIDGET TEKS SPESIFIK
// Ini adalah widget-widget yang akan Anda gunakan di seluruh aplikasi.
// Masing-masing sudah terikat pada gaya tertentu dari Theme.

//=-=-=-=-= HEADLINE (TAJUK) =-=-=-=-=

/// Menampilkan teks dengan gaya `headlineLarge` dari tema.
class TeksTajukBesar extends _TeksDasar {
  const TeksTajukBesar(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge;
}

/// Menampilkan teks dengan gaya `headlineMedium` dari tema.
class TeksTajukSedang extends _TeksDasar {
  const TeksTajukSedang(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;
}

/// Menampilkan teks dengan gaya `headlineSmall` dari tema.
class TeksTajukKecil extends _TeksDasar {
  const TeksTajukKecil(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall;
}

//=-=-=-=-= TITLE (JUDUL) =-=-=-=-=

/// Menampilkan teks dengan gaya `titleLarge` dari tema.
class TeksJudulBesar extends _TeksDasar {
  const TeksJudulBesar(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge;
}

/// Menampilkan teks dengan gaya `titleMedium` dari tema.
class TeksJudulSedang extends _TeksDasar {
  const TeksJudulSedang(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;
}

/// Menampilkan teks dengan gaya `titleSmall` dari tema.
class TeksJudulKecil extends _TeksDasar {
  const TeksJudulKecil(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;
}

//=-=-=-=-= BODY (ISI) =-=-=-=-=

/// Menampilkan teks dengan gaya `bodyLarge` dari tema.
class TeksIsiBesar extends _TeksDasar {
  const TeksIsiBesar(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge;
}

/// Menampilkan teks dengan gaya `bodyMedium` dari tema.
class TeksIsiSedang extends _TeksDasar {
  const TeksIsiSedang(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;
}

/// Menampilkan teks dengan gaya `bodySmall` dari tema.
class TeksIsiKecil extends _TeksDasar {
  const TeksIsiKecil(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;
}

//=-=-=-=-= LABEL =-=-=-=-=

/// Menampilkan teks dengan gaya `labelLarge` dari tema (cocok untuk tombol).
class TeksLabelBesar extends _TeksDasar {
  const TeksLabelBesar(
    super.data, {
    super.key,
    super.warna,
    super.tebalFont,
    super.rataTeks,
    super.maksBaris,
    super.luapan,
    super.garisBawah,
    super.tinggiBaris,
  });

  @override
  TextStyle? dapatkanGayaDasar(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;
}

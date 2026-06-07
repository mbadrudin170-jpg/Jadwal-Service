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

/// Menampilkan teks dengan gaya `headlineLarge` dari tema.
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
      Theme.of(context).textTheme.headlineLarge;
}

/// Menampilkan teks dengan gaya `headlineMedium` dari tema.
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
      Theme.of(context).textTheme.headlineMedium;
}

/// Menampilkan teks dengan gaya `headlineSmall` dari tema.
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
      Theme.of(context).textTheme.headlineSmall;
}

/// Menampilkan teks dengan gaya `bodyLarge` dari tema.
class TeksBodyBesar extends _TeksDasar {
  const TeksBodyBesar(
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
class TeksBodySedang extends _TeksDasar {
  const TeksBodySedang(
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
class TeksBodyKecil extends _TeksDasar {
  const TeksBodyKecil(
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

/// Menampilkan teks dengan gaya `labelLarge` dari tema (cocok untuk tombol).
class TeksTombol extends _TeksDasar {
  const TeksTombol(
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

/// Menampilkan teks dengan gaya `bodySmall` (sebelumnya `caption`) dari tema.
class TeksCaption extends _TeksDasar {
  const TeksCaption(
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
      Theme.of(context).textTheme.bodySmall; // DIGANTI dari .caption
}

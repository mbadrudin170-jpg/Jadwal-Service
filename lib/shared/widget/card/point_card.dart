// path: lib/shared/widget/card/point_card.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_colors.dart';

/// Kartu yang menampilkan total poin pengguna.
///
/// Menampilkan ikon, label "Total Poin", dan jumlah poin.
/// Mendukung [onTap] opsional untuk aksi saat kartu ditekan.
class TotalPointCard extends StatelessWidget {
  /// Jumlah poin yang ditampilkan.
  final int points;

  /// Ikon yang ditampilkan di depan kartu.
  final IconData icon;

  /// Warna tema untuk ikon dan efek bayangan.
  final Color themeColor;

  /// Callback opsional saat kartu ditekan.
  final VoidCallback? onTap;
// === ANALISIS FILE DAN RELASI MENDALAM (TRACE BERANTAI) ===
//
// Saya ingin kamu menganalisis file berikut secara MENDALAM dan MENYELURUH:
//
// --- FILE UTAMA ---
// Nama file: point_card.dart
// Path: ~/myapp/lib/shared/widget/card/point_card.dart
//
// Isi file:
// ```dart
// isi file lengkap
// ```
//
// --- ATURAN PENTING (WAJIB DIPATUHI) ---
//
// ATURAN TRACE BERANTAI:
// - Jika file ini import/reference/memanggil file B, kamu WAJIB menanyakan isi file B
// - Jika file B ternyata juga import/reference/memanggil file C, kamu WAJIB menanyakan isi file C
// - Jika file C import file D, tanyakan file D, begitu seterusnya sampai AKAR
// - Jangan berhenti sebelum SEMUA rantai dependency terlacak
// - Jangan berspekulasi atau menebak isi file lain, WAJIB minta isinya padaku
// - Kalau kamu butuh isi file terkait, TANYAKAN dengan format: 'Tolong paste isi file [nama_file]'
//
// ATURAN DUA ARAH:
// - Selain file yang di-import, kamu juga WAJIB menanyakan file yang meng-import file utama ini
// - Trace dua arah: ke atas (parent/caller) dan ke bawah (child/dependency)
//
// --- TUGAS KAMU ---
//
// 1. IDENTIFIKASI SEMUA IMPORT & DEPENDENCY
//    - Sebutkan SATU PER SATU import yang ada di file ini
//    - Untuk SETIAP import, sebutkan nama file dan path-nya
//    - Jelaskan kegunaan masing-masing import
//
// 2. TRACE BERANTAI KE BAWAH (FILE YANG DI-IMPORT)
//    - Untuk SETIAP file yang di-import, WAJIB minta isinya padaku
//    - Format: 'Tolong paste isi file [nama_file] di path [path_file]'
//    - Kalau di file import itu ada import lagi, ulangi terus sampai ke akar
//    - Tampilkan dependency chain lengkap: File A → File B → File C → ... → File Akar
//
// 3. TRACE BERANTAI KE ATAS (FILE YANG MENG-IMPORT FILE INI)
//    - WAJIB tanyakan file-file yang meng-import file utama ini
//    - Format: 'Apakah ada file lain yang meng-import point_card.dart? Tolong paste isinya'
//    - Kalau ada, trace terus ke atas: File X → File Y → ... → File Utama
//
// 4. ANALISIS MASALAH DI SETIAP LEVEL RANTAI
//    - Di setiap file dalam rantai, analisis potensi error
//    - Cek apakah error di file utama disebabkan oleh file import
//    - Cek sampai ke akar penyebab, jangan cuma di permukaan
//    - Siapa yang pertama kali menyebabkan masalah di rantai ini?
//
// 5. DAMPAK PERUBAHAN SEPANJANG RANTAI
//    - Kalau file utama diubah, trace dampaknya ke SEMUA file di rantai
//    - Kalau file akar diubah, trace dampaknya ke file utama
//    - Di setiap level, sebutkan apa yang akan error/terpengaruh
//
// 6. VISUALISASI RANTAI DEPENDENCY
//    - Gambarkan diagram rantai lengkap: File A → File B → File C → File D
//    - Tandai file mana yang bermasalah
//    - Tandai arah aliran data/dependency
//
// 7. KONTEKS PROJECT
//    - Di folder mana file ini berada?
//    - Apa peran file ini dalam arsitektur project?
//    - File apa saja yang satu folder/feature?
//
// 8. POTENSI MASALAH DI SELURUH RANTAI
//    - Circular dependency?
//    - Import tidak digunakan?
//    - Best practice dilanggar?
//    - Potensi bug dari relasi?
//
// 9. REKOMENDASI PERBAIKAN
//    - Perbaikan untuk file utama
//    - Perbaikan untuk file-file di rantai (kalau perlu)
//    - Saran restruktur dependency kalau diperlukan
//
// --- FORMAT JAWABAN ---
// 1. Mulai dengan identifikasi import file utama
// 2. TANYAKAN padaku SATU PER SATU file yang dibutuhkan
// 3. Tunggu aku berikan isinya, baru lanjut analisis
// 4. JANGAN LANGSUNG menyimpulkan sebelum SEMUA file di rantai diperiksa
// 5. Tampilkan dependency chain lengkap di akhir
// Setelah melakukan perbaikan list semua file yang telah diperbaiki dari awal kita mualai hingga saat ini
// Setelah melakukan pekerjaan beritahukan ke saya sisa tokok AI yang belum terpakai agar proses kita tidak terpotong
// ubah nama class, file variabel, parameter ke dalam bahasa inggris untuk menjaga konsistensi projek tapi untuk komentar wajib indonesia
// tambahkan inofrmasi didalam file file ini digunakan oleh file apa saja dan bungkus dengan komentar
  /// Membuat kartu total poin.
  ///
  /// [points] wajib diisi. [icon], [themeColor], dan [onTap] bersifat opsional.
  const TotalPointCard({
    super.key,
    required this.points,
    this.icon = Icons.stars_rounded,
    this.themeColor = AppColors.pointColor,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          splashColor: themeColor.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Poin', // ✅ Petik satu
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      points.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

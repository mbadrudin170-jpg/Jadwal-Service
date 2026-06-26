# Panduan Gaya Flutter

Panduan gaya ini menguraikan konvensi penulisan kode untuk kontribusi di repositori flutter/flutter. Panduan ini didasarkan pada [panduan gaya resmi untuk repositori Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md) yang lebih komprehensif.

## Praktik Terbaik

- Kode harus mengikuti panduan dan prinsip yang dijelaskan dalam [panduan kontribusi Flutter](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md).
- Kode harus diuji dan mengikuti panduan yang dijelaskan dalam [panduan menulis tes yang efektif](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md) dan [panduan menjalankan dan menulis tes](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md).
- Perubahan pada [direktori engine/](https://github.com/flutter/flutter/tree/main/engine) juga harus memiliki tes yang sesuai seperti yang dijelaskan dalam [panduan pengujian engine](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md).
- Deskripsi PR harus mencakup Daftar Pra-peluncuran dari [template PR](https://github.com/flutter/flutter/blob/main/.github/PULL_REQUEST_TEMPLATE.md), dengan semua langkah telah diselesaikan.
- Panduan yang paling relevan harus diutamakan daripada panduan yang kurang relevan. Untuk kode Flutter, [panduan gaya Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md) harus diikuti sebagai prioritas utama, dan [Effective Dart: Style](https://dart.dev/effective-dart/style) hanya boleh diikuti jika tidak bertentangan dengan yang pertama.

## Pedoman Agen Peninjau

- Hanya tinjau perubahan pada cabang `master`. Perubahan lain sudah ditinjau (dan sedang di-cherrypick).

## Filosofi Umum

- **Optimalkan untuk keterbacaan**: Kode lebih sering dibaca daripada ditulis.
- **Hindari menggandakan state**: Pertahankan hanya satu sumber kebenaran.
- Tulis apa yang Anda butuhkan dan tidak lebih, tetapi saat Anda menulisnya, lakukan dengan benar.
- **Pesan error harus berguna**: Setiap pesan error adalah kesempatan untuk membuat orang mencintai produk kita.

## Pemformatan Dart

- Semua kode Dart diformat menggunakan `dart format`. Ini diterapkan oleh CI.
- Konstruktor ditempatkan pertama dalam definisi kelas, dengan konstruktor default mendahului konstruktor bernama.
- Anggota kelas lainnya harus diurutkan secara logis (misalnya, berdasarkan siklus hidup, atau mengelompokkan field dan metode yang terkait).

## Bahasa Lainnya

- Kode Python diformat menggunakan `yapf`, di-lint dengan `pylint`, dan harus mengikuti [Panduan Gaya Python Google](https://google.github.io/styleguide/pyguide.html).
- Kode C++ diformat menggunakan `clang-format`, di-lint dengan `clang-tidy`, dan harus mengikuti [Panduan Gaya C++ Google](https://google.github.io/styleguide/cppguide.html).
- Shader diformat menggunakan `clang-format`.
- Kode Kotlin diformat menggunakan `ktformat`, di-lint dengan `ktlint`, dan harus mengikuti [Panduan Gaya Kotlin Android](https://developer.android.com/kotlin/style-guide).
- Kode Java diformat menggunakan `google-java-format` dan harus mengikuti [Panduan Gaya Java Google](https://google.github.io/styleguide/javaguide.html).
- Objective-C diformat menggunakan `clang-format`, di-lint dengan `clang-tidy`, dan harus mengikuti [Panduan Gaya Objective-C Google](https://google.github.io/styleguide/objcguide.html).
- Swift diformat dan di-lint menggunakan `swift-format` dan harus mengikuti [Panduan Gaya Swift Google](https://google.github.io/swift).
- Kode GN diformat menggunakan `gn format` dan harus mengikuti [Panduan Gaya GN](https://gn.googlesource.com/gn/+/main/docs/style_guide.md).

## Dokumentasi

- Semua anggota publik harus memiliki dokumentasi.
- **Jawab pertanyaan Anda sendiri**: Jika Anda memiliki pertanyaan, temukan jawabannya, lalu dokumentasikan di tempat Anda pertama kali mencari.
- **Dokumentasi harus berguna**: Jelaskan *mengapa* dan *bagaimana*.
- **Perkenalkan istilah**: Asumsikan pembaca tidak mengetahui segalanya. Tautkan ke definisi.
- **Berikan kode contoh**: Gunakan `{@tool dartpad}` untuk contoh yang dapat dijalankan.
  - Contoh kode inline terdapat di dalam `{@tool dartpad}` dan `{@end-tool}`, dan menggunakan format contoh berikut untuk menyisipkan contoh kode:
    - `/// ** Lihat kode di examples/api/lib/widgets/sliver/sliver_list.0.dart **`
    - Jangan bingung format ini dengan bagian `/// Lihat juga:` dari dokumentasi, yang memberikan petunjuk bermanfaat bagi pengembang.
- **Berikan ilustrasi atau tangkapan layar** untuk widget.
- Gunakan `///` untuk dokumentasi berkualitas publik, bahkan pada anggota privat.

## Pedoman Agen Peninjau

Saat memberikan ringkasan, agen peninjau harus mematuhi prinsip-prinsip berikut:
- **Bersikap Objektif:** Fokus pada ringkasan deskriptif yang netral tentang perubahan. Hindari penilaian subjektif seperti "bagus," "buruk," "positif," atau "negatif." Tujuannya adalah melaporkan apa yang dilakukan kode, bukan untuk mengevaluasinya.
- **Gunakan Kode sebagai Sumber Kebenaran:** Dasar semua ringkasan pada diff kode. Jangan percaya atau mengulang ulang deskripsi PR, yang mungkin sudah usang atau tidak akurat. Ringkasan harus mencerminkan perubahan aktual dalam kode.
- **Bersikap Ringkas:** Hasilkan ringkasan yang singkat dan langsung ke intinya. Fokus pada perubahan yang paling signifikan, dan hindari detail yang tidak perlu atau penjelasan yang bertele-tele. Ini memastikan umpan balik mudah dipindai dan dipahami.

## Bacaan Lebih Lanjut

Untuk panduan yang lebih detail, lihat dokumen-dokumen berikut:

- [Panduan gaya untuk repositori Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Kebersihan Pohon (Tree Hygiene)](https://github.com/flutter/flutter/blob/main/docs/contributing/Tree-hygiene.md)
- [Panduan kontribusi Flutter](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md)
- [Panduan menulis tes yang efektif](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md)
- [Panduan menjalankan dan menulis tes](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md)
- [Panduan pengujian engine](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md)
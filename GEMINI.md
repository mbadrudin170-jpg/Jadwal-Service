# // path: prompt/aturan_analisis_error.md


hapus kata final pada sebuah parameter dan ubah nama fungsi menjadi bahasa indoneisa
---

### Aturan Analisis error
1. jika terjadi error  maka AI di wajibkan meminta file yang bersangkutan kepada pengguna, misalnya jika ada sebuah kode yang error didalam file maka AI harus melakukan analysa apakah kode ini menggunakan kode dari file lain, maka AI wajib meminta ke pengguna dan  membaca file yang di import nya itu
2. kalau AI tidak tahu path file yang di import nya itu maka AI di wajibkan menjalankan `ls -R lib test` agar bisa lebih akurat lagi.
3. AI hanya berfokus pada kode yang bermasalah saja dan jangan menyentuh kode yang tidak bermasalah, tetapi kalau kode tersebut bersangkutan dengan kode yang error maka AI boleh menyentuh kode itu.
// path: prompt/aturan_test.md

### Aturan Test

1. nama test harus menggunakan bahasa indonesia dan kasih nomor urut nya di masing masing test.
2. kalau bisa setiap file unit test nya harus lengkap agar tidak semua kode bisa sesuai dengan yang di harapkan.
3. nama test dan penempatan path nya harus sesuai dengan file aslinya jika file aslinya lib/shared/operasi/firebase_operasi/settings_op_firebase.dart maka file test nya juga harus test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart.
4. setelah memperbarui file test nya jalankan flutter analzye agar tidak ada error lalu jalankan flutter test untuk file tersebut contoh `flutter test test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart`.
5. jangan pernah merubah test yang tidak error dan test yang sukses cukup rubah saja unit test nya bermasalah.
6. sebelum membuatkan unit test nya tolong baca dan pahami kode sumber nya.
7. Tolong pahami dan selalu ingat aturan ini:
    1. jika kode yang sedang dikerjakan ternyata diimport dari file lain AI wajib melihat file file yang diimport itu,jika file yang di import juga menggunakan kode yang dimpoert dari file lain maka AI wajib membaca nya juga. agar tidak salah file AI harus menajalankan ls -R lib atau ls -R test jika itu file test.
    2. penulisan kode, AI wajib menuliskan kode yang sesuai dengan versi paket saya di pubspec.yaml, kalau bisa lihat dokumentasinya dengan menjalankan read_package_uris dan pub_dev_search,
    3. kode di setiap file harus konsisten.
Tolong pahami dan selalu ingat aturan ini

1. jika kode yang sedang dikerjakan ternyata diimport dari file lain AI wajib melihat file file yang diimport itu,jika file yang di import juga menggunakan kode yang dimpoert dari file lain maka AI wajib membaca nya juga. agar tidak salah file AI harus menajalankan ls -R lib atau ls -R test jika itu file test.
2. penulisan kode, AI wajib menuliskan kode yang sesuai dengan versi paket saya di pubspec.yaml, kalau bisa lihat dokumentasinya dengan menjalankan read_package_uris dan pub_dev_search,
3. kode di setiap file harus konsisten.
# Aturan untuk melakukan build apk dengan Alias

## Alur Kerja Build (WAJIB DIIKUTI)

**1. SEBELUM Build: Cek Versi Terakhir**

Sebelum menjalankan build, **selalu periksa riwayat versi terakhir** di file log untuk menentukan `[nama-versi]` dan `[nomor-build]` yang akan digunakan.

-   **Lihat riwayat Admin:** `docs/build/build_apk_admin.md`
-   **Lihat riwayat User:** `docs/build/build_apk_user.md`

**2. SAAT Build: Jalankan Perintah Alias**

Gunakan alias yang sesuai dengan `nama-versi` dan `nomor-build` yang sudah Anda tentukan di langkah 1.

**3. SETELAH Build Berhasil: Catat Versi Baru**

Setelah proses build selesai **tanpa error**, segera **WAJIB catat versi baru** ke dalam file log yang sesuai.

1.  Buka file log yang relevan (misal, `docs/build/build_apk_admin.md`).
2.  **Tambahkan entri baru** di baris paling atas dengan format berikut:

    ```
    # [Tanggal dan Jam Build]
    version: [nama-versi]+[nomor-build]
    ```

    **Contoh Entri Baru:**
    ```
    # 19 Mei 24, 10:30
    version: 1.0.1+3
    ```

Tindakan ini **krusial** untuk menjaga riwayat build tetap akurat dan menghindari konflik versi.

---

## Detail Perintah Build

### Build Apk Admin Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbuildadmin [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.1+2, maka build selanjutnya adalah 1.0.2+3
fbuildadmin() {
    flutter clean && flutter build apk --split-per-abi --flavor adminProd -t lib/main/main_admin/admin_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2" && echo -e "# $(date +'%d %b %y, %H:%M')\nversion: $1+$2\n\n$(cat docs/build/build_apk_admin.md)" > docs/build/build_apk_admin.md
}
```

### Build Apk User Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbuilduser [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.0+1, maka build selanjutnya adalah 1.0.1+2
fbuilduser() {
    flutter clean && flutter build apk --split-per-abi --flavor userProd -t lib/main/main_user/user_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2" && echo -e "# $(date +'%d %b %y, %H:%M')\nversion: $1+$2\n\n$(cat docs/build/build_apk_user.md)" > docs/build/build_apk_user.md
}
```

---

## Lokasi Output

File APK yang dihasilkan akan berada di direktori: `build/app/outputs/flutter-apk/`.
# // path: prompt/penyisipan_log_sanckbar.md
---

**Aturan Logging dan Toast untuk Asisten Koding Flutter:**

0. **Prasyarat: Pahami Implementasi**
   - Sebelum menyisipkan kode apa pun, **baca dan pahami** isi file berikut:
     - `lib/shared/debug/log.dart` (kelas `Log`)
     - `lib/shared/utils/toast_util.dart` (kelas `ToastUtil`)
   - Gunakan hanya method dan tanda tangan yang tersedia di kedua kelas tersebut.
   - Jangan membuat asumsi tentang fitur yang tidak ada; ikuti persis API yang disediakan.

1. **Logging**
   - Jangan pernah menggunakan `print()`, `debugPrint()`, atau `log()` bawaan.
   - Gunakan class `Log` dari path `lib/shared/debug/log.dart`.
   - Class `Log` punya method:
     - `Log.info(pesan, data?)` untuk informasi
     - `Log.warning(pesan, data?)` untuk peringatan
     - `Log.error(pesan, {e, st, data})` untuk error (bisa menyertakan exception & stacktrace)
   - Selalu sertakan pesan yang jelas, dan jika ada data relevan (response API, objek state, dll) masukkan sebagai parameter `data`.

2. **Toast**
   - Jangan pernah langsung pakai `ScaffoldMessenger.of(context).showSnackBar(...)` atau widget `SnackBar`.
   - Gunakan class `ToastUtil` dari path `lib/shared/utils/toast_util.dart`.
   - `ToastUtil` punya method statis:
     - `ToastUtil.success(context, pesan, {logData})`
     - `ToastUtil.error(context, pesan, {logData})`
     - `ToastUtil.warning(context, pesan, {logData})`
     - `ToastUtil.info(context, pesan, {logData})`
   - `logData` bersifat opsional, hanya untuk log internal (tidak tampil ke user), tapi tetap cantumkan jika ada data tambahan.
   - Method-method ini otomatis mencatat log sesuai tipe, jadi setelah memanggil `ToastUtil` **tidak perlu** lagi memanggil `Log` secara manual, **kecuali** untuk error (lihat poin 3).

3. **Penanganan Error (WAJIB)**
   - Setiap kali terjadi error, **harus** melakukan dua hal:
     a. **Log error** menggunakan `Log.error(...)` agar tercatat detail exception, stacktrace, dan data.
     b. **Tampilkan Toast error** menggunakan `ToastUtil.error(context, pesanUser, ...)` agar pengguna mendapat notifikasi.
   - **Jangan hanya** memanggil `Log.error` tanpa Toast, atau sebaliknya. Keduanya wajib ada.
   - **Aturan linter**: Gunakan `on` untuk menangkap tipe exception spesifik. Jangan gunakan `catch` polos tanpa `on`. Minimal `on Exception catch (e, st)` atau lebih spesifik. Jika tidak yakin, gunakan `on Object catch (e, st)`.
   - Toast untuk error harus menampilkan pesan yang ramah pengguna, sementara `Log.error` bisa berisi detail teknis.

4. **Pencatatan di Setiap Alur Kerja (WAJIB)**
   - Setiap fungsi atau metode yang melakukan aksi signifikan (misal: fetch data, submit form, proses perhitungan, navigasi dengan data) **harus**:
     a. Mencatat log di awal proses (contoh: `Log.info('Memulai mengambil data pengguna')`).
     b. Setelah selesai, memberikan notifikasi ke pengguna menggunakan `ToastUtil` (contoh: `ToastUtil.success(context, 'Data berhasil diambil')`).
   - Untuk operasi yang hanya memberi informasi tanpa efek besar, cukup gunakan `ToastUtil.info()` (sudah termasuk log).
   - Untuk operasi yang menghasilkan peringatan (misal data kosong), gunakan `ToastUtil.warning()`.
   - **Jangan sampai** ada aksi penting yang tidak meninggalkan jejak log atau tidak memberi tahu pengguna melalui Toast.

5. **Impor**
   - Setiap file yang membutuhkan log atau toast wajib mengimpor:
     ```dart
     import 'package:wifi/shared/debug/log.dart';
     import 'package:wifi/shared/utils/toast_util.dart';
     ```

6. **Hanya Menyisipkan Log dan Toast (Jangan Mengubah Kode Asli)**
   - Fokus hanya menambahkan pemanggilan `Log` dan `ToastUtil` sesuai aturan di atas.
   - **Jangan mengubah** struktur, logika, alur navigasi, nama fungsi/variabel, atau perilaku kode yang sudah ada.
   - Jika operasi penting belum memiliki penanganan error, tambahkan **blok `try`/`on Exception catch` minimal** untuk mencatat log dan menampilkan toast error, tetapi **biarkan isi blok `try` sama persis** dengan kode asli (tidak diubah).
   - Jangan menambahkan fungsionalitas baru, refaktor, atau "perbaikan" yang tidak diminta.
# // path: prompt/flutter.md
# Panduan Gaya Flutter

Panduan gaya ini menguraikan konvensi pengkodean untuk kontribusi ke
repositori flutter/flutter. Ini didasarkan pada [panduan gaya untuk repositori Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md) resmi yang lebih komprehensif.

## Praktik Terbaik

- Kode harus mengikuti panduan dan prinsip yang dijelaskan dalam
  [panduan kontribusi Flutter](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md).
- Kode harus diuji dan mengikuti panduan yang dijelaskan dalam [panduan menulis tes yang efektif](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md) dan [panduan menjalankan dan menulis tes](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md).
- Perubahan pada [direktori engine/](https://github.com/flutter/flutter/tree/main/engine) juga harus memiliki tes yang sesuai seperti yang dijelaskan dalam [panduan tes engine](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md).
- Deskripsi PR harus menyertakan Daftar Periksa Pra-peluncuran dari
  [templat PR](https://github.com/flutter/flutter/blob/main/.github/PULL_REQUEST_TEMPLATE.md),
  dengan semua langkah selesai.
- Pedoman yang paling relevan harus lebih diutamakan daripada pedoman yang kurang relevan. Untuk kode Flutter,
  [panduan gaya Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
  harus diikuti sebagai prioritas pertama, dan
  [Effective Dart: Style](https://dart.dev/effective-dart/style)
  hanya boleh diikuti jika tidak bertentangan dengan yang pertama.


## Pedoman Agen Peninjau

- Hanya tinjau perubahan pada cabang \`master\`. Perubahan lain telah ditinjau (dan sedang di-cherrypick).
- **Periksa regresi potensial**: Cari perubahan yang mungkin merusak fungsionalitas yang ada atau memperkenalkan perilaku tak terduga di area terkait.
- **Verifikasi validitas tes**: Konfirmasikan bahwa tes baru atau yang dimodifikasi secara efektif menangkap masalah yang sedang diperbaiki dan akan gagal jika perbaikan dikembalikan.
- **Cari contoh tandingan**: Identifikasi skenario atau kasus tepi yang tidak ditangani oleh kode yang diusulkan. Jika contoh tandingan ditemukan, usulkan kasus uji untuk menunjukkan celah tersebut.
- **Sarankan penyederhanaan dan refaktorisasi**: Menilai apakah kode dapat dibuat lebih sederhana atau difaktorkan ulang untuk meningkatkan keterbacaan dan pemeliharaan.

## Filosofi Umum

- **Optimalkan untuk keterbacaan**: Kode lebih sering dibaca daripada ditulis.
- **Hindari duplikasi status**: Pertahankan hanya satu sumber kebenaran.
- Tulis apa yang Anda butuhkan dan tidak lebih, tetapi ketika Anda menulisnya, lakukan dengan benar.
- **Pesan kesalahan harus bermanfaat**: Setiap pesan kesalahan adalah kesempatan untuk membuat seseorang menyukai produk kami.

## Pemformatan Dart

- Semua kode Dart diformat menggunakan \`dart format\`. Ini diberlakukan oleh CI.
- Konstruktor muncul pertama dalam definisi kelas, dengan konstruktor default mendahului konstruktor bernama.
- Anggota kelas lainnya harus diurutkan secara logis (misalnya, berdasarkan siklus hidup, atau mengelompokkan bidang dan metode terkait).

## Berbagai Bahasa

- Kode Python diformat menggunakan \`yapf\`, di-lint dengan \`pylint\`, dan harus mengikuti [Panduan Gaya Python Google](https://google.github.io/styleguide/pyguide.html).
- Kode C++ diformat menggunakan \`clang-format\`, di-lint dengan \`clang-tidy\`, dan harus mengikuti [Panduan Gaya C++ Google](https://google.github.io/styleguide/cppguide.html).
- Shader diformat menggunakan \`clang-format\`.
- Kode Kotlin diformat menggunakan \`ktformat\`, di-lint dengan \`ktlint\`, dan harus mengikuti [Panduan Gaya Kotlin Android](https://developer.android.com/kotlin/style-guide).
- Kode Java diformat menggunakan \`google-java-format\` dan harus mengikuti [Panduan Gaya Java Google](https://google.github.io/styleguide/javaguide.html).
- Objective-C diformat menggunakan \`clang-format\`, di-lint dengan \`clang-tidy\`, dan harus mengikuti [Panduan Gaya Objective-C Google](https://google.github.io/styleguide/objcguide.html).
- Swift diformat dan di-lint menggunakan \`swift-format\` dan harus mengikuti [Panduan Gaya Swift Google](https://google.github.io/swift).
- Kode GN diformat menggunakan \`gn format\` dan harus mengikuti [Panduan Gaya GN](https://gn.googlesource.com/gn/+/main/docs/style_guide.md).

## Dokumentasi

- Semua anggota publik harus memiliki dokumentasi.
- **Jawab pertanyaan Anda sendiri**: Jika Anda memiliki pertanyaan, temukan jawabannya, lalu dokumentasikan di tempat Anda pertama kali mencarinya.
- **Dokumentasi harus bermanfaat**: Jelaskan *mengapa* dan *bagaimana*.
- **Perkenalkan istilah**: Asumsikan pembaca tidak tahu segalanya. Tautkan ke definisi.
- **Berikan kode contoh**: Gunakan \`{@tool dartpad}\` untuk contoh yang dapat dijalankan.
  - Contoh kode sebaris terdapat di dalam \`{@tool dartpad}\` dan \`{@end-tool}\`, dan gunakan format contoh berikut untuk menyisipkan contoh kode:
    - \`/// ** Lihat kode di examples/api/lib/widgets/sliver/sliver_list.0.dart **\`
    - Jangan bingung format ini dengan bagian \`/// Lihat juga:\` dari dokumentasi, yang menyediakan remah roti yang bermanfaat bagi pengembang.
- **Berikan ilustrasi atau tangkapan layar** untuk widget.
- Gunakan \`///\` untuk dokumentasi berkualitas publik, bahkan pada anggota pribadi.

## Pedoman Agen Peninjau

Saat memberikan ringkasan, agen peninjau harus mematuhi prinsip-prinsip berikut:
- **Jadilah Objektif:** Fokus pada ringkasan perubahan yang netral dan deskriptif. Hindari penilaian nilai subjektif
  seperti "baik," "buruk," "positif," atau "negatif." Tujuannya adalah melaporkan apa yang dilakukan kode, bukan untuk mengevaluasinya.
- **Gunakan Kode sebagai Sumber Kebenaran:** Dasarkan semua ringkasan pada diff kode. Jangan percaya atau mengulang deskripsi PR, yang mungkin sudah usang atau tidak akurat. Ringkasan harus mencerminkan perubahan aktual dalam kode.
- **Jadilah Ringkas:** Hasilkan ringkasan yang singkat dan langsung ke intinya. Fokus pada perubahan yang paling signifikan,
  dan hindari detail yang tidak perlu atau penjelasan yang bertele-tele. Ini memastikan umpan balik mudah dipindai dan dipahami.

## Bacaan lebih lanjut

Untuk panduan lebih rinci, lihat dokumen berikut:

- [Panduan gaya untuk repositori Flutter](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Kebersihan Pohon](https://github.com/flutter/flutter/blob/main/docs/contributing/Tree-hygiene.md)
- [Panduan kontribusi Flutter](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md)
- [Panduan menulis tes yang efektif](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md)
- [Panduan menjalankan dan menulis tes](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md)
- [Panduan pengujian mesin](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md)
# // path: prompt/aturan_penulisan_kode.md

---

### Aturan Ngoding Flutter (AI)

**0. Bahasa Percakapan dengan AI**
Seluruh percakapan antara AI dan pengembang **wajib menggunakan Bahasa Indonesia**, baik saat menjelaskan kode, memberi saran, maupun menanggapi pertanyaan. Aturan ini berlaku mutlak dalam sesi ini.

**1. Bahasa Komentar dan Percakapan**
Seluruh komentar di dalam kode serta percakapan dengan AI wajib menggunakan **Bahasa Indonesia**.

**2. Penamaan dalam Kode**
Seluruh nama **fungsi, variabel, props, parameter, file, dan class** wajib ditulis dalam **Bahasa Indonesia**.

**3. Format dan Kerapihan Kode**
- Wajib menggunakan *trailing comma* di setiap widget tree agar auto-format rapi (sesuai `dart format`).
- Gunakan `const` constructor sebanyak mungkin untuk widget stateless.
- Pisahkan widget besar menjadi widget-widget kecil yang fokus pada satu tanggung jawab.
- Jika widget tree sudah menjorok terlalu dalam (nested), ekstrak bagian tersebut menjadi widget private di file yang sama.
- Maksimal satu widget publik per file, kecuali widget private kecil yang hanya digunakan dalam file yang sama.

**4. Penggunaan Ikon Wajib dari `AppIcons`**
- Semua ikon dalam aplikasi **harus diambil dari class `AppIcons`** (`lib/shared/theme/app_icons.dart`), **tidak boleh** menggunakan `Icons.xxx` secara langsung di widget.
- Jika ikon yang dibutuhkan **belum tersedia** di `AppIcons`, **wajib menambahkannya terlebih dahulu** sebagai properti `static const` baru dengan nama yang deskriptif dalam Bahasa Inggris, lalu gunakan properti tersebut.
- Tujuan: menjaga konsistensi ikon di seluruh aplikasi dan memudahkan penggantian ikon secara terpusat.

**5. Komentar Path di Awal Setiap File**
- Setiap file kode Dart **wajib** diawali dengan komentar yang menyebutkan path file relatif terhadap root proyek, contoh: `// path: lib/screens/home_screen.dart`.
- Komentar path diletakkan pada baris pertama file, sebelum `import` atau deklarasi lainnya.
- Tujuan: memudahkan identifikasi lokasi file, terutama saat salin-tempel atau diskusi kode.

**6. Menjalankan `flutter analyze` Setiap Selesai Perubahan**
- Setelah menyelesaikan setiap perubahan kode (fitur baru, perbaikan bug, atau refaktor), **wajib menjalankan `flutter analyze`** untuk memastikan tidak ada *error* atau *warning* yang tertinggal.
- Jika ditemukan masalah, perbaiki terlebih dahulu sebelum melanjutkan ke tugas lain atau menganggap pekerjaan selesai.
- Tujuan: menjaga kualitas kode, mencegah akumulasi masalah, dan mendeteksi kesalahan sejak dini.

**7. Komentar Fungsi**
Tambahkan sebuah komentar di setiap fungsi di dalam sebuah file, contoh: `// 1. Menginisialisasi konfigurasi zona waktu`.

**8. Aturan `withOpacity`**
Dilarang menggunakan `withOpacity`. Gunakan `withValues` atau `withAlpha` untuk menjaga konsistensi proyek.

**9. Aturan Riverpod**
- Semua state management harus menggunakan `flutter_riverpod` dengan `riverpod_annotation` untuk menjaga konsistensi.
- Setiap UI yang membutuhkan data akan memanggil provider yang sesuai.
- Untuk provider yang datanya perlu dijaga selama aplikasi berjalan, gunakan anotasi `@Riverpod(keepAlive: true)`.# // path: prompt/aturan_kepatuhan_ai.md

---

### Aturan Kepatuhan AI

**Tujuan:** Memastikan AI selalu patuh terhadap instruksi pengguna, tidak membantah, tidak memaksakan pendapat, dan tidak memberikan saran yang tidak diminta.

**1. Patuhi Semua Perintah Tanpa Bantahan**
- AI wajib mengikuti semua instruksi pengguna tanpa membantah, berdebat, atau mempertanyakan keputusan pengguna.
- AI tidak boleh menggunakan frasa yang meragukan seperti: "tapi", "sebaiknya", "menurut saya", "lebih baik", "saya sarankan", kecuali pengguna secara eksplisit meminta pendapat.
// path: prompt/fungsi/fungsi.md

selalu menggunakan file dibawah ini agar selalu konsisten


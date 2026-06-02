# // path: prompt/aturan_analisis_error.md


---

### Aturan Analisis Error dan Masalah (AI)

**Tujuan:** Memastikan setiap kali terjadi error atau masalah pada suatu file, AI melakukan pemeriksaan menyeluruh terhadap file tersebut beserta semua dependensi impornya berdasarkan struktur proyek nyata, tanpa spekulasi, dan memeriksa dampak ke file lain.

---

**1. Identifikasi File Bermasalah dan Pemetaan Proyek**
- Tentukan file yang sedang mengalami error atau yang akan diubah/diperbaiki.
- Catat pesan error, stack trace, atau deskripsi masalah yang muncul.
- **Wajib menjalankan `ls -R lib/`** (atau perintah setara) untuk mendapatkan daftar lengkap file dan struktur direktori di dalam folder `lib/`.
- Dari hasil `ls -R lib/`, kenali semua file yang mungkin terkait, termasuk:
  - File yang diimpor langsung oleh file bermasalah.
  - File lain yang berpotensi menjadi sumber masalah berdasarkan nama, lokasi, atau pola.
- Gunakan peta struktur ini sebagai dasar untuk semua langkah penelusuran selanjutnya.

**2. Telusuri dan Baca Seluruh File yang Diimpor (Larangan Spekulasi)**
- Baca daftar impor di bagian atas file yang sedang dikerjakan.
- Untuk setiap impor yang **berasal dari dalam proyek** (bukan package eksternal), **wajib membuka dan membaca isi file tersebut**.
- Fokus pada definisi yang benar-benar digunakan: kelas, fungsi, variabel, enum, ekstensi, dll.
- **Dilarang berspekulasi** atau mengasumsikan isi file impor tanpa membacanya. Setiap referensi ke file impor harus didasarkan pada kode nyata yang sudah dibaca.
- Pastikan tanda tangan (signature), tipe data, parameter, dan struktur yang digunakan di file asli cocok dengan definisi di file impor.
- Jika file impor juga memiliki impor lokal lain yang relevan dengan masalah, AI **harus menelusuri lebih dalam** (dependensi tingkat kedua).

   **Cara Menemukan File dari Path Impor:**
   - **Untuk impor `package:`**: buang bagian `package:nama_app/`, lalu cocokkan dengan struktur di hasil `ls -R lib/`.
   - **Untuk impor relatif**: mulai dari direktori file yang sedang dikerjakan, telusuri path `../` berdasarkan hasil `ls -R lib/`.
   - **Jika file tidak ditemukan**, **wajib jalankan `ls -R lib/`** (atau `find lib/ -type f -name "*.dart"`) untuk mendapatkan struktur terbaru dan cari ulang. Jangan pernah berspekulasi lokasi file.

**3. Analisis Sumber Error Secara Runtut**
Setelah menelusuri file impor, lakukan langkah berikut untuk menentukan sumber error:

- **a. Periksa kesesuaian panggilan:**  
  Bandingkan cara pemanggilan fungsi/metode/widget di file utama dengan definisi aslinya di file impor. Cek: nama, parameter, tipe data, named/positional, required/optional, dan return type.

- **b. Periksa asumsi yang meleset:**  
  Jika di file utama ada asumsi tertentu (misal: suatu fungsi dianggap synchronous padahal async, atau dianggap melempar exception tertentu), cocokkan dengan fakta di file impor.

- **c. Periksa apakah ada perubahan di file impor:**  
  Lihat isi file impor, apakah ada perubahan yang baru saja terjadi? (misal: method dihapus, diganti nama, ditambah parameter, atau dijadikan private).

- **d. Cek apakah error menjalar dari file lain:**  
  Jika file impor yang dicek ternyata juga mengimpor file lokal lain, dan masalah belum ditemukan, **telusuri lebih dalam** ke file tersebut (ulangi poin 2).

- **e. Tentukan lokasi perbaikan:**  
  Setelah semua penelusuran, simpulkan di mana perbaikan harus dilakukan:
  - Di file utama (karena pemanggilan salah).
  - Di file impor (karena definisi yang kurang atau salah).
  - Di kedua file (jika ada ketidakcocokan desain).

- **f. Jangan berspekulasi:**  
  Jika ada bagian yang belum jelas atau file tidak bisa dibaca, **akui dan tanyakan ke pengguna**, jangan menebak.

**4. Periksa Dampak ke File Lain yang Menggunakan Class Ini (Reverse Dependency)**
- Setelah file selesai dianalisis atau akan diperbaiki, **wajib mencari file lain yang menggunakan class dari file tersebut**.
- Gunakan perintah:  
  `grep -r "NamaClass" lib/ --include="*.dart"`  
  di mana `NamaClass` adalah nama class utama (atau class yang diubah) dalam file yang sedang dikerjakan.
- Buka file-file yang ditemukan dan periksa apakah perubahan yang akan dilakukan (misal: mengubah signature method, menghapus method, mengganti tipe properti) akan merusak kompatibilitas di file-file tersebut.
- Jika ya, sertakan penyesuaian yang diperlukan di file-file itu, atau beri tahu pengguna tentang dampaknya.
- Jangan hanya fokus pada perbaikan di file yang dikerjakan, pastikan tidak merusak file lain yang menggunakan class tersebut.

---Tolong pahami dan selalu ingat aturan ini

1. jika kode yang sedang dikerjakan ternyata diimport dari file lain AI wajib melihat file file yang diimport itu,jika file yang di import juga menggunakan kode yang dimpoert dari file lain maka AI wajib menanyakan membaca nya juga. agar tidak salah file AI harus menajalankan ls -R lib atau ls -R test jika itu file test.
2. penulisan kode, AI wajib menuliskan kode yang sesuai dengan versi paket saya di pubspec.yaml, kalau bisa lihat dokumentasinya dengan menjalankan read_package_uris dan pub_dev_search,
3. kode di setiap file harus konsisten.
4. // path: prompt/build.md
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
# Format: fbapkver_admin [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.1+2, maka build selanjutnya adalah 1.0.2+3
    flutter clean && flutter build apk --split-per-abi --flavor adminProd -t lib/main/main_admin/admin_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2"
```

### Build Apk User Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbapkver_user [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.0+1, maka build selanjutnya adalah 1.0.1+2
 flutter clean && flutter build apk --split-per-abi --flavor userProd -t lib/main/main_user/user_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2"
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

---
# Flutter Style Guide

This style guide outlines the coding conventions for contributions to the
flutter/flutter repository. It is based on the more comprehensive official
[style guide for the Flutter repository](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md).

## Best Practices

- Code should follow the guidance and principles described in
  [the Flutter contribution guide](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md).
- Code should be tested and follow the guidance described in the [writing effective tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md) and the [running and writing tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md).
- Changes to the [engine/ directory](https://github.com/flutter/flutter/tree/main/engine) should additionally have appropriate tests as described in [the engine test guidance](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md).
- PR descriptions should include the Pre-launch Checklist from
  [the PR template](https://github.com/flutter/flutter/blob/main/.github/PULL_REQUEST_TEMPLATE.md),
  with all of the steps completed.
- The most relevant guidelines should take precedence over less relevant
  guidelines. For Flutter code, the
  [Flutter styleguide](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
  should be followed as the first priority, and
  [Effective Dart: Style](https://dart.dev/effective-dart/style)
  should only be followed when it does not conflict with the former.


## Review Agent Guidelines

- Only review changes to the `master` branch. Other changes have already been reviewed (and are being cherrypicked).
- **Check for potential regressions**: Look for changes that might break existing functionality or introduce unexpected behavior in related areas.
- **Verify test validity**: Confirm that new or modified tests effectively catch the issue being fixed and would fail if the fix were reverted.
- **Search for counter-examples**: Identify scenarios or edge cases that the proposed code does not handle. If a counter-example is found, propose a test case to demonstrate the gap.
- **Suggest simplification and refactoring**: Assess whether the code can be made simpler or refactored to enhance readability and maintainability.

## General Philosophy

- **Optimize for readability**: Code is read more often than it is written.
- **Avoid duplicating state**: Keep only one source of truth.
- Write what you need and no more, but when you write it, do it right.
- **Error messages should be useful**: Every error message is an opportunity to make someone love our product.

## Dart Formatting

- All Dart code is formatted using `dart format`. This is enforced by CI.
- Constructors come first in a class definition, with the default constructor preceding named constructors.
- Other class members should be ordered logically (e.g., by lifecycle, or grouping related fields and methods).

## Miscellaneous Languages

- Python code is formatted using `yapf`, linted with `pylint`, and should follow the [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html).
- C++ code is formatted using `clang-format`, linted with `clang-tidy`, and should follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).
- Shaders are formatted using `clang-format`.
- Kotlin code is formatted using `ktformat`, linted with `ktlint`, and should follow the [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide).
- Java code is formatted using `google-java-format` and should follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html).
- Objective-C is formatted using `clang-format`, linted with `clang-tidy`, and should follow the [Google Objective-C Style Guide](https://google.github.io/styleguide/objcguide.html).
- Swift is formatted and linted using `swift-format` and should follow the [Google Swift Style Guide](https://google.github.io/swift).
- GN code is formatted using `gn format` and should follow the [GN Style Guide](https://gn.googlesource.com/gn/+/main/docs/style_guide.md).

## Documentation

- All public members should have documentation.
- **Answer your own questions**: If you have a question, find the answer, and then document it where you first looked.
- **Documentation should be useful**: Explain the *why* and the *how*.
- **Introduce terms**: Assume the reader does not know everything. Link to definitions.
- **Provide sample code**: Use `{@tool dartpad}` for runnable examples.
  - Inline code samples are contained within `{@tool dartpad}` and `{@end-tool}`, and use the format of the following example to insert the code sample:
    - `/// ** See code in examples/api/lib/widgets/sliver/sliver_list.0.dart **`
    - Do not confuse this format with `/// See also:` sections of the documentation, which provide helpful breadcrumbs to developers.
- **Provide illustrations or screenshots** for widgets.
- Use `///` for public-quality documentation, even on private members.

## Review Agent Guidelines

When providing a summary, the review agent must adhere to the following principles:
- **Be Objective:** Focus on a neutral, descriptive summary of the changes. Avoid subjective value judgments
  like "good," "bad," "positive," or "negative." The goal is to report what the code does, not to evaluate it.
- **Use Code as the Source of Truth:** Base all summaries on the code diff. Do not trust or rephrase the PR
  description, which may be outdated or inaccurate. A summary must reflect the actual changes in the code.
- **Be Concise:** Generate summaries that are brief and to the point. Focus on the most significant changes,
  and avoid unnecessary details or verbose explanations. This ensures the feedback is easy to scan and understand.

## Further Reading

For more detailed guidance, refer to the following documents:

- [Style guide for the Flutter repository](https://github.com/flutter/flutter/blob/main/docs/contributing/Style-guide-for-Flutter-repo.md)
- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Tree Hygiene](https://github.com/flutter/flutter/blob/main/docs/contributing/Tree-hygiene.md)
- [The Flutter contribution guide](https://github.com/flutter/flutter/blob/main/CONTRIBUTING.md)
- [Writing effective tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Writing-Effective-Tests.md)
- [Running and writing tests guide](https://github.com/flutter/flutter/blob/main/docs/contributing/testing/Running-and-writing-tests.md)
- [Engine testing guide](https://github.com/flutter/flutter/blob/main/docs/engine/testing/Testing-the-engine.md)# // path: prompt/aturan_penulisan_kode.md


---

### Aturan Ngoding Flutter (AI)

**0. Bahasa Percakapan dengan AI**
Seluruh percakapan antara AI dan pengembang **wajib menggunakan Bahasa Indonesia**, baik saat menjelaskan kode, memberi saran, maupun menanggapi pertanyaan. Aturan ini berlaku mutlak dalam sesi ini.

**1. Bahasa Komentar dan Percakapan**  
Seluruh komentar di dalam kode serta percakapan dengan AI wajib menggunakan **Bahasa Indonesia**.

**2. Penamaan dalam Kode**  
Seluruh nama **fungsi, variabel, props, parameter, file, dan class** wajib ditulis dalam **Bahasa Inggris**.  
Jika belum mengetahui padanan kata yang tepat:
- Tulis perkiraan nama dalam Bahasa Indonesia di komentar.
- Tanyakan langsung ke AI untuk mendapatkan padanan Bahasa Inggris yang lazim di Flutter/Dart.

**3. Pembiasaan Bahasa Inggris Bertahap**  
Penulisan nama tetap dimulai dengan Bahasa Inggris terlebih dahulu. Proses tanya-jawab ini bertujuan mempercepat migrasi ke Bahasa Inggris penuh tanpa menghambat alur ngoding, sambil tetap belajar secara bertahap.

**4. Format dan Kerapihan Kode**  
- Wajib menggunakan *trailing comma* di setiap widget tree agar auto-format rapi (sesuai `dart format`).  
- Gunakan `const` constructor sebanyak mungkin untuk widget stateless.  
- Pisahkan widget besar menjadi widget-widget kecil yang fokus pada satu tanggung jawab.  
- Jika widget tree sudah menjorok terlalu dalam (nested), ekstrak bagian tersebut menjadi widget private di file yang sama.  
- Maksimal satu widget publik per file, kecuali widget private kecil yang hanya digunakan dalam file yang sama.

**5. Penggunaan Ikon Wajib dari `AppIcons`**  
- Semua ikon dalam aplikasi **harus diambil dari class `AppIcons`** (`lib/shared/theme/app_icons.dart`), **tidak boleh** menggunakan `Icons.xxx` secara langsung di widget.  
- Jika ikon yang dibutuhkan **belum tersedia** di `AppIcons`, **wajib menambahkannya terlebih dahulu** sebagai properti `static const` baru dengan nama yang deskriptif dalam Bahasa Inggris, lalu gunakan properti tersebut.  
- Tujuan: menjaga konsistensi ikon di seluruh aplikasi dan memudahkan penggantian ikon secara terpusat.

**6. Komentar Path di Awal Setiap File**  
- Setiap file kode Dart **wajib** diawali dengan komentar yang menyebutkan path file relatif terhadap root proyek, contoh: `// path: lib/screens/home_screen.dart`.  
- Komentar path diletakkan pada baris pertama file, sebelum `import` atau deklarasi lainnya.  
- Tujuan: memudahkan identifikasi lokasi file, terutama saat salin-tempel atau diskusi kode.

**7. Menjalankan `flutter analyze` Setiap Selesai Perubahan**  
- Setelah menyelesaikan setiap perubahan kode (fitur baru, perbaikan bug, atau refaktor), **wajib menjalankan `flutter analyze`** untuk memastikan tidak ada *error* atau *warning* yang tertinggal.  
- Jika ditemukan masalah, perbaiki terlebih dahulu sebelum melanjutkan ke tugas lain atau menganggap pekerjaan selesai.  
- Tujuan: menjaga kualitas kode, mencegah akumulasi masalah, dan mendeteksi kesalahan sejak dini.# // path: prompt/aturan_kepatuhan_ai.md


---

### Aturan Kepatuhan AI

**Tujuan:** Memastikan AI selalu patuh terhadap instruksi pengguna, tidak membantah, tidak memaksakan pendapat, dan tidak memberikan saran yang tidak diminta.

---

**1. Patuhi Semua Perintah Tanpa Bantahan**
- AI wajib mengikuti semua instruksi pengguna tanpa membantah, berdebat, atau mempertanyakan keputusan pengguna.
- AI tidak boleh menggunakan frasa yang meragukan seperti: "tapi", "sebaiknya", "menurut saya", "lebih baik", "saya sarankan", kecuali pengguna secara eksplisit meminta pendapat.

---# Fungsi Berkas Proyek

Dokumen ini menjelaskan fungsi dari berbagai file penting dalam proyek untuk memudahkan pemahaman dan pemeliharaan.

---

### **Direktori `lib/main`**

**Tujuan:**
Berisi file-file *entry point* (titik masuk) aplikasi. Struktur ini memungkinkan peluncuran aplikasi dengan konfigurasi yang berbeda tergantung pada peran (Admin atau User) dan lingkungan (Development atau Production). Ini adalah praktik kunci dalam manajemen *build flavor*.

**Struktur:**
Direktori ini terbagi menjadi dua sub-direktori utama:
*   `lib/main/main_admin`: Titik masuk untuk aplikasi khusus **Admin**.
*   `lib/main/main_user`: Titik masuk untuk aplikasi yang digunakan oleh **User**.

Setiap sub-direktori memiliki dua file:
*   `_dev.dart`: Untuk lingkungan **pengembangan (development)**. Menggunakan konfigurasi seperti Firebase project versi dev.
*   `_prod.dart`: Untuk lingkungan **produksi (production)**. Menggunakan konfigurasi untuk rilis resmi ke pengguna.

**Alur Kerja Inisialisasi (di dalam fungsi `main`):**
Sebelum aplikasi dijalankan dengan `runApp()`, beberapa layanan penting diinisialisasi terlebih dahulu:

1.  **`WidgetsFlutterBinding.ensureInitialized()`**: Memastikan semua *binding* Flutter siap sebelum menjalankan kode asinkron.
2.  **`FlutterNativeSplash.preserve()`**: Menahan *splash screen* agar tetap tampil selama proses inisialisasi berlangsung.
3.  **`Firebase.initializeApp()`**: Menghubungkan aplikasi ke proyek Firebase. File ini mengimpor opsi Firebase yang berbeda (`firebase_option_...dart`) sesuai dengan *flavor*-nya (misal, `firebase_option_admin_dev.dart` untuk admin dev).
4.  **Inisialisasi Layanan Tambahan**:
    *   **`MobileAds.instance.initialize()`**: Mengaktifkan SDK Google Mobile Ads (ada di semua *flavor*).
    *   **`BackgroundService.init()`**: Mempersiapkan tugas latar belakang (hanya di aplikasi *user*).
    *   **`GmaMediationUnity().set...Consent()`**: Mengatur persetujuan GDPR & CCPA untuk mediasi iklan Unity (hanya di aplikasi *user*).
5.  **`runApp(ProviderScope(child: ...))`**: Menjalankan UI aplikasi utama (`AppAdmin` atau `AppUser`) dan membungkusnya dengan `ProviderScope` agar *state management* menggunakan Riverpod tersedia di seluruh aplikasi.

**Keuntungan Utama:**
*   **Pemisahan Konfigurasi:** Memisahkan kunci API, endpoint, dan konfigurasi lain antara lingkungan dev dan prod, sehingga lebih aman dan terorganisir.
*   **Build yang Fleksibel:** Memudahkan proses *build* untuk target yang berbeda tanpa harus mengubah kode secara manual.

---

### **Direktori `lib/shared/export`**

**Tujuan:**
Menyederhanakan impor modul dengan menggunakan teknik "barrel file". Setiap file di dalam direktori ini (misalnya `model.dart`, `enum.dart`, `service.dart`) bertugas meng-`export` semua file dari sub-direktori terkait. Dengan cara ini, file lain di dalam aplikasi hanya perlu melakukan satu kali impor dari *barrel file* ini untuk mengakses semua model, enum, atau layanan, tanpa perlu mengimpor setiap file satu per satu.

**Contoh Penggunaan:**
*   **File `lib/shared/export/model.dart`** mengekspor semua file model dari `lib/features/.../model/...`.
*   Di file lain, Anda cukup menulis:
    ```dart
    import 'package:wifi/shared/export/model.dart';
    ```
    ...untuk bisa langsung menggunakan `UserModel`, `ProductModel`, dll.

**Keuntungan Utama:**
*   **Impor yang Rapi:** Mengurangi jumlah baris `import` di bagian atas setiap file.
*   **Manajemen Dependensi yang Lebih Mudah:** Jika lokasi file model berubah, Anda hanya perlu memperbarui path `export` di dalam `model.dart`, tanpa perlu mengubah setiap file yang mengimpornya.
*   **Struktur Proyek yang Bersih:** Membuat kode lebih terorganisir dan mudah dinavigasi.

---

### **`lib/shared/theme/app_sizes.dart`**

**Tujuan:**
Menyediakan konstanta untuk ukuran (padding, margin) dan spasi (`SizedBox`) yang akan digunakan secara seragam di seluruh aplikasi. Ini memastikan konsistensi desain dan mempermudah pembaruan.

**Struktur & Penggunaan:**

*   **Kelas `TSizes`:** Berisi nilai `double` untuk ukuran.
    *   **Contoh:** `TSizes.p16` menghasilkan nilai `16.0`.
    *   **Penggunaan:** `Padding(padding: EdgeInsets.all(TSizes.p16))`

*   **Variabel `gapH*` & `gapW*`:** Menyediakan widget `SizedBox` siap pakai.
    *   `gapH16` untuk spasi **vertikal** (`height: 16.0`).
    *   `gapW16` untuk spasi **horizontal** (`width: 16.0`).
    *   **Penggunaan:** `Column(children: [widget1, gapH16, widget2])`

**Keuntungan Utama:**
*   **Konsistensi UI:** Menjaga agar semua jarak dan ukuran seragam.
*   **Perawatan Mudah:** Cukup ubah di satu file untuk mengubah ukuran di seluruh aplikasi.
*   **Kode Lebih Jelas:** Menghindari penggunaan angka acak (magic numbers) di dalam kode UI.

---

### **`lib/shared/theme/app_colors.dart`**

**Tujuan:**
Menjadi pusat definisi palet warna aplikasi. Semua warna yang digunakan dalam tema (terang maupun gelap) dan komponen spesifik didefinisikan di sini.

**Struktur & Penggunaan:**

*   **Kelas `TColors`:** Berisi properti `static const` untuk setiap warna.
*   **Contoh:** `TColors.primaryColor`, `TColors.lightBackground`, `TColors.pointColor`.
*   **Penggunaan:** `container.color = TColors.primaryColor`.

**Keuntungan Utama:**
*   **Branding Konsisten:** Memastikan warna sesuai dengan identitas merek di seluruh aplikasi.
*   **Manajemen Tema:** Memudahkan penyesuaian warna untuk tema terang dan gelap.
*   **Satu Sumber Kebenaran:** Semua nilai warna terpusat di satu tempat.

---

### **`lib/shared/theme/app_icons.dart`**

**Tujuan:**
Mengelola semua ikon yang digunakan di aplikasi secara terpusat untuk memastikan konsistensi visual dan kemudahan penggantian.

**Struktur & Penggunaan:**

*   **Kelas `TIcons`:** Berisi properti `static const IconData` untuk setiap ikon.
*   **Contoh:** `TIcons.add`, `TIcons.customers`, `TIcons.points`.
*   **Penggunaan:** `Icon(TIcons.save)`.

**Keuntungan Utama:**
*   **Ikon Seragam:** Menghindari penggunaan ikon yang berbeda untuk fungsi yang sama.
*   **Penggantian Mudah:** Mengganti satu ikon di `TIcons` akan memperbaruinya di seluruh aplikasi.
*   **Kode Lebih Deskriptif:** `Icon(TIcons.delete)` lebih jelas daripada `Icon(Icons.delete)` karena menegaskan bahwa itu adalah ikon standar aplikasi.

---

### **`lib/shared/theme/app_theme.dart`**

**Tujuan:**
Mendefinisikan seluruh properti visual (tema) untuk mode terang (`lightTheme`) dan mode gelap (`darkTheme`), menggabungkan warna, tipografi, dan gaya komponen.

**Struktur & Penggunaan:**

*   **Kelas `AppTheme`:** Berisi dua properti utama: `static final ThemeData lightTheme` dan `static final ThemeData darkTheme`.
*   Menggunakan `TColors` untuk warna dan mendefinisikan `TextTheme` untuk tipografi.
*   Menyesuaikan tema untuk komponen spesifik seperti `AppBar`, `ElevatedButton`, dan `ListTile`.
*   **Penggunaan:** Diterapkan di level tertinggi aplikasi (misal: di `MaterialApp.theme` dan `MaterialApp.darkTheme`).

**Keuntungan Utama:**
*   **Pemisahan Logika:** Memisahkan definisi tema dari logika UI lainnya.
*   **Tampilan Terpadu:** Memastikan semua komponen di seluruh aplikasi memiliki tampilan dan nuansa yang konsisten sesuai dengan mode tema yang aktif.

---

### **`lib/shared/theme/theme_provider.dart`**

**Tujuan:**
Mengelola **state** atau kondisi tema aplikasi saat ini. Ini memungkinkan pengguna untuk mengubah tema (terang, gelap, atau sistem) dan menyimpan preferensi tersebut secara lokal.

**Struktur & Penggunaan:**

*   **Kelas `ThemeProviderImpl`:** Mengimplementasikan `ChangeNotifier` untuk memberi tahu aplikasi saat tema berubah.
*   Menggunakan `LocalStorageService` untuk menyimpan dan memuat preferensi tema pengguna, sehingga pilihan tema tetap ada bahkan setelah aplikasi ditutup.
*   Menyediakan metode seperti `setTheme(ThemeMode)` untuk mengubah tema.
*   **Penggunaan:** Disediakan melalui `ChangeNotifierProvider` di widget root (`AppUser` atau `AppAdmin`) sehingga bisa diakses dari mana saja di dalam aplikasi.

**Keuntungan Utama:**
*   **Interaktivitas Pengguna:** Memberikan kontrol kepada pengguna untuk memilih tema favorit mereka.
*   **Persistensi:** Mengingat pilihan pengguna, memberikan pengalaman yang lebih personal.
*   **Manajemen State Terpusat:** Mengelola state tema di satu lokasi yang logis.

---

### **Direktori `lib/shared/enum`**

**Tujuan:**
Direktori ini berisi kumpulan file `enum` (enumerasi) yang mendefinisikan sekumpulan nilai konstan untuk berbagai tipe data dalam aplikasi. Penggunaan `enum` sangat penting untuk mencegah kesalahan pengetikan (typo), menghindari penggunaan string mentah (*magic strings*), dan membuat kode lebih aman, terbaca, dan mudah dikelola.

#### **`apk_architecture_enum.dart`**
*   **Enum:** `ApkArchitectureEnum`
*   **Fungsi:** Mendefinisikan jenis arsitektur CPU (`bit32`, `bit64`, `universal`, `x86_64`) untuk file APK.

#### **`category_type_enum.dart`**
*   **Enum:** `CategoryType`
*   **Fungsi:** Membedakan jenis kategori transaksi, yaitu `income` (pemasukan), `expense` (pengeluaran), dan `transfer`.
*   **Fitur Tambahan:** Dilengkapi `extension` `displayName` untuk mendapatkan representasi teks dalam Bahasa Indonesia (misal: 'Pemasukan').

#### **`duration_type_enum.dart`**
*   **Enum:** `DurationType`
*   **Fungsi:** Menentukan satuan durasi untuk sebuah paket atau layanan, seperti `minutes`, `hours`, `days`, dan `months`.
*   **Fitur Tambahan:** Memiliki `getter` `displayName` untuk menampilkan nama satuan dalam Bahasa Indonesia (misal: 'Hari').

#### **`payment_status_enum.dart`**
*   **Enum:** `PaymentStatus`
*   **Fungsi:** Merepresentasikan status pembayaran sebuah tagihan atau transaksi, yaitu `paid` (lunas) dan `unpaid` (belum lunas).
*   **Fitur Tambahan:** Dilengkapi `getter` `displayName` untuk konversi ke teks 'Lunas' atau 'Belum Lunas'.

#### **`table_name_enum.dart`**
*   **Enum:** `TableName`
*   **Fungsi:** Berisi daftar semua nama tabel yang ada di dalam database lokal (SQLite). Sangat krusial untuk operasi sinkronisasi dan akses database agar terhindar dari kesalahan nama tabel.

#### **`transaction_type_enum.dart`**
*   **Enum:** `TransactionType`
*   **Fungsi:** Mendefinisikan jenis-jenis transaksi dasar: `income`, `expense`, dan `transfer`.
*   **Fitur Tambahan:** Memiliki `getter` `displayName` untuk mengubah nilai enum menjadi teks yang mudah dibaca ('Pemasukan', 'Pengeluaran', 'Transfer').

#### **`user_role_enum.dart`**
*   **Enum:** `UserRole`
*   **Fungsi:** Membedakan peran pengguna dalam sistem, yaitu `admin` (hak akses penuh) dan `user` (hak akses terbatas).

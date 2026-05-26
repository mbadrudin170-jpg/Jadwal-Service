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

---# // path: prompt/aturan_kepatuhan_ai.md


---

### Aturan Kepatuhan AI

**Tujuan:** Memastikan AI selalu patuh terhadap instruksi pengguna, tidak membantah, tidak memaksakan pendapat, dan tidak memberikan saran yang tidak diminta.

---

**1. Patuhi Semua Perintah Tanpa Bantahan**
- AI wajib mengikuti semua instruksi pengguna tanpa membantah, berdebat, atau mempertanyakan keputusan pengguna.
- AI tidak boleh menggunakan frasa yang meragukan seperti: "tapi", "sebaiknya", "menurut saya", "lebih baik", "saya sarankan", kecuali pengguna secara eksplisit meminta pendapat.

---# // path: prompt/aturan_penulisan_kode.md


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
- Tujuan: menjaga kualitas kode, mencegah akumulasi masalah, dan mendeteksi kesalahan sejak dini.// path: prompt/build.md
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


# // path: prompt/penyisipan_log_sanckbar.md
---

**Aturan Logging dan SnackBar untuk Asisten Koding Flutter:**

0. **Prasyarat: Pahami Implementasi**
   - Sebelum menyisipkan kode apa pun, **baca dan pahami** isi file berikut:
     - `lib/shared/debug/log.dart` (kelas `Log`)
     - `lib/shared/utils/snackbar_util.dart` (kelas `SnackBarUtil`)
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

2. **Snackbar**
   - Jangan pernah langsung pakai `ScaffoldMessenger.of(context).showSnackBar(...)` atau widget `SnackBar`.
   - Gunakan class `SnackBarUtil` dari path `lib/shared/utils/snackbar_util.dart`.
   - `SnackBarUtil` punya method statis:
     - `SnackBarUtil.success(context, pesan, {logData})`
     - `SnackBarUtil.error(context, pesan, {logData})`
     - `SnackBarUtil.warning(context, pesan, {logData})`
     - `SnackBarUtil.info(context, pesan, {logData})`
   - `logData` bersifat opsional, hanya untuk log internal (tidak tampil ke user), tapi tetap cantumkan jika ada data tambahan.
   - Method-method ini otomatis mencatat log sesuai tipe, jadi setelah memanggil `SnackBarUtil` **tidak perlu** lagi memanggil `Log` secara manual, **kecuali** untuk error (lihat poin 3).

3. **Penanganan Error (WAJIB)**
   - Setiap kali terjadi error, **harus** melakukan dua hal:
     a. **Log error** menggunakan `Log.error(...)` agar tercatat detail exception, stacktrace, dan data.
     b. **Tampilkan SnackBar error** menggunakan `SnackBarUtil.error(context, pesanUser, ...)` agar pengguna mendapat notifikasi.
   - **Jangan hanya** memanggil `Log.error` tanpa SnackBar, atau sebaliknya. Keduanya wajib ada.
   - **Aturan linter**: Gunakan `on` untuk menangkap tipe exception spesifik. Jangan gunakan `catch` polos tanpa `on`. Minimal `on Exception catch (e, st)` atau lebih spesifik. Jika tidak yakin, gunakan `on Object catch (e, st)`.
   - SnackBar untuk error harus menampilkan pesan yang ramah pengguna, sementara `Log.error` bisa berisi detail teknis.

4. **Pencatatan di Setiap Alur Kerja (WAJIB)**
   - Setiap fungsi atau metode yang melakukan aksi signifikan (misal: fetch data, submit form, proses perhitungan, navigasi dengan data) **harus**:
     a. Mencatat log di awal proses (contoh: `Log.info('Memulai mengambil data pengguna')`).
     b. Setelah selesai, memberikan notifikasi ke pengguna menggunakan `SnackBarUtil` (contoh: `SnackBarUtil.success(context, 'Data berhasil diambil')`).
   - Untuk operasi yang hanya memberi informasi tanpa efek besar, cukup gunakan `SnackBarUtil.info()` (sudah termasuk log).
   - Untuk operasi yang menghasilkan peringatan (misal data kosong), gunakan `SnackBarUtil.warning()`.
   - **Jangan sampai** ada aksi penting yang tidak meninggalkan jejak log atau tidak memberi tahu pengguna melalui SnackBar.

5. **Impor**
   - Setiap file yang membutuhkan log atau snackbar wajib mengimpor:
     ```dart
     import 'package:wifi/shared/debug/log.dart';
     import 'package:wifi/shared/utils/snackbar_util.dart';
     ```

6. **Hanya Menyisipkan Log dan SnackBar (Jangan Mengubah Kode Asli)**
   - Fokus hanya menambahkan pemanggilan `Log` dan `SnackBarUtil` sesuai aturan di atas.
   - **Jangan mengubah** struktur, logika, alur navigasi, nama fungsi/variabel, atau perilaku kode yang sudah ada.
   - Jika operasi penting belum memiliki penanganan error, tambahkan **blok `try`/`on Exception catch` minimal** untuk mencatat log dan menampilkan snackbar error, tetapi **biarkan isi blok `try` sama persis** dengan kode asli (tidak diubah).
   - Jangan menambahkan fungsionalitas baru, refaktor, atau "perbaikan" yang tidak diminta.

---
# // path: prompt/aturan_penulisan_kode.md


---

### Aturan Ngoding Flutter (AI)

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
- **Jika widget tree sudah menjorok terlalu dalam (nested), ekstrak bagian tersebut menjadi widget private di file yang sama.**  
- Maksimal satu widget publik per file, kecuali widget private kecil yang hanya digunakan dalam file yang sama.

---
// path: prompt/build.md
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
# Contoh jika versi terakhir di log adalah 1.0.1+2, maka build selanjutnya adalah 1.0.1+3
    flutter clean && flutter build apk --split-per-abi --flavor adminProd -t lib/main/main_admin/admin_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2"
```

### Build Apk User Prod

**Contoh Penggunaan (berdasarkan Langkah 1):**
```bash
# Format: fbapkver_user [nama-versi] [nomor-build]
# Contoh jika versi terakhir di log adalah 1.0.0+1, maka build selanjutnya adalah 1.0.0+2
 flutter clean && flutter build apk --split-per-abi --flavor userProd -t lib/main/main_user/user_prod.dart --build-name="$1" --build-number="$2" && bash rename_apk.sh "$1" "$2"
```

---

## Lokasi Output

File APK yang dihasilkan akan berada di direktori: `build/app/outputs/flutter-apk/`.

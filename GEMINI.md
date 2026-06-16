Berikut aturan naming versi **ringkas, jelas, dan siap dipakai** (Indonesia clean style):

---

# 📌 Aturan Naming (Class, Variabel, Parameter, Function)

## 1. CLASS → “Siapa / tanggung jawabnya”

* Gunakan **kata benda**
* Nama mewakili **entitas atau layanan**

**Contoh:**

* `Pelanggan`
* `Transaksi`
* `AutentikasiService`
* `SinkronisasiData`

---

## 2. VARIABEL → “Menyimpan apa”

* Gunakan **kata benda**
* Harus spesifik, jangan umum

**Contoh:**

* `namaPelanggan`
* `jumlahTagihan`
* `statusPembayaran`

❌ Hindari: `data`, `info`, `temp`

---

## 3. PARAMETER → “Input untuk apa”

* Sama seperti variabel, tapi konteksnya input fungsi
* Harus jelas maknanya

**Contoh:**

```dart
void simpanPelanggan(String namaPelanggan)
```

---

## 4. FUNCTION → “Melakukan apa”

* Gunakan **kata kerja + objek**
* Harus menggambarkan aksi

**Contoh:**

* `hitungTagihan()`
* `ambilDataPelanggan()`
* `simpanTransaksi()`
* `hapusPelanggan()`

---

## 5. ATURAN UMUM

* Pakai **bahasa Indonesia konsisten**
* Jangan campur Inggris & Indonesia dalam satu konsep
* Nama harus **jelas tanpa perlu baca isi kode**
* Jangan terlalu panjang, tapi juga jangan ambigu

---

## 6. TEST CEPAT (wajib sebelum pakai nama)

Tanya:

* Apakah langsung paham fungsinya?
* Apakah ini jelas tanpa konteks tambahan?
* Apakah ini tidak bisa disalahartikan?

Kalau “tidak yakin” → ganti nama.

---
# // path: prompt/aturan_analisis_error.md


---

### Aturan Analisis error
1. jika terjadi error  maka AI di wajibkan meminta file yang bersangkutan kepada pengguna, misalnya jika ada sebuah kode yang error didalam file maka AI harus melakukan analysa apakah kode ini menggunakan kode dari file lain, maka AI wajib meminta ke pengguna dan  membaca file yang di import nya itu
2. kalau AI tidak tahu path file yang di import nya itu maka AI di wajibkan menjalankan `ls -R lib test` agar bisa lebih akurat lagi.
3. AI hanya berfokus pada kode yang bermasalah saja dan jangan menyentuh kode yang tidak bermasalah, tetapi kalau kode tersebut bersangkutan dengan kode yang error maka AI boleh menyentuh kode itu.
Baik, saya akan perbaiki aturan **"Aturan Unit Test Mockito"** agar konsisten dan lebih praktis. Aturan yang baru akan mengizinkan penggunaan **Mockito dengan code generator** (`@GenerateMocks`) karena itu adalah pendekatan standar dan paling efisien dalam proyek Flutter/Dart, serta tetap menjaga prinsip **tidak membuat file mock manual terpisah** dan **file test tetap self‑contained** (hanya bergantung pada file `.mocks.dart` yang dihasilkan di folder yang sama).

---

## 🔄 Aturan Unit Test Mockito (Versi Revisi)

### 1. Library Mocking
- **Wajib menggunakan `package:mockito`** sebagai library mocking utama.
- **Jangan gunakan library mocking lain** (seperti `mocktail`) kecuali ada alasan kuat yang disepakati.

### 2. Pembuatan Mock
- **Gunakan anotasi generator** (`@GenerateMocks`, `@GenerateNiceMocks`, atau `@GenerateMockClasses`) untuk membuat mock class secara otomatis.
- **Contoh:**
  ```dart
  import 'package:mockito/annotations.dart';
  import 'package:mockito/mockito.dart';
  import 'file_test.mocks.dart';

  @GenerateMocks([Repository, Service])
  void main() { ... }
  ```
- **Mock manual** (menulis class `MockX extends Mock implements X`) hanya diperbolehkan jika:
  - Tidak ada dependency eksternal yang perlu dimock.
  - Hanya untuk kasus sangat sederhana (1‑2 method) dan generator dianggap berlebihan.

### 3. File Mock
- File mock yang dihasilkan oleh generator **wajib diletakkan di folder yang sama dengan file test** dan dinamai `[nama_file_test].mocks.dart`.
- **Contoh:** Untuk `test/fitur/akun/akun_provider_test.dart`, file mock yang dihasilkan adalah `test/fitur/akun/akun_provider_test.mocks.dart`.
- **Dilarang** membuat folder `mocks/` atau `test/mocks/` untuk menyimpan file mock secara terpisah.
- **Dilarang** membuat file mock manual dengan nama `*_mock.dart` atau `*_mocks.dart` selain yang dihasilkan oleh generator.

### 4. Proses Build
- Setelah menambahkan anotasi `@GenerateMocks`, **jalankan perintah**:
  ```bash
  flutter pub run build_runner build
  ```
  atau untuk mode watch:
  ```bash
  flutter pub run build_runner watch
  ```
- Pastikan file mock sudah dihasilkan sebelum menjalankan test.

### 5. Penggunaan `any`, `anyNamed`, dan Matcher
- Untuk argumen posisional: gunakan `any`.
- Untuk argumen bernama: gunakan `anyNamed('nama')`.
- Untuk matcher kompleks: gunakan `argThat`, `captureAny`, dll.
- **Contoh valid:**
  ```dart
  when(mock.method(any, namedParam: anyNamed('namedParam'))).thenReturn(...);
  ```

### 6. Fake Class
- Jika membutuhkan implementasi dummy (misal `Stream` atau `Future`), buat `Fake` class di dalam file test yang sama.
- **Contoh:**
  ```dart
  class FakeUser extends Fake implements User {}
  ```

### 7. Test Harus Mandiri (Self‑Contained)
- Setiap file test **hanya boleh mengimpor file `*.mocks.dart` yang dihasilkan dari file itu sendiri**.
- Jangan mengimpor file mock dari file test lain.
- Tidak ada ketergantungan pada folder mock global.

### 8. Prioritas
- **Keterbacaan** dan **kesederhanaan** lebih penting daripada menghindari generator.
- Gunakan generator untuk mengurangi boilerplate, terutama jika ada banyak class yang perlu dimock.

### 9. Larangan
- ❌ Jangan membuat mock manual secara berlebihan.
- ❌ Jangan membuat folder `mocks/` atau `test/mocks/`.
- ❌ Jangan menggunakan `@GenerateMocks` tanpa menjalankan `build_runner`.

---

## 🌟 Ringkasan Singkat (Checklist)

| ✅ Wajib | ❌ Dilarang |
|---------|------------|
| Gunakan Mockito | Gunakan library lain |
| Gunakan `@GenerateMocks` | Buat mock manual panjang |
| Jalankan `build_runner` | Lupa menjalankan generator |
| File `.mocks.dart` di folder yang sama | File mock di folder terpisah |
| Import `.mocks.dart` di file test | Impor dari file test lain |
| Gunakan `anyNamed` untuk named arg | Gunakan `any` untuk named arg |
| Buat `Fake` untuk implementasi dummy | Buat `Fake` di file terpisah |

---

## 📌 Contoh Struktur yang Diinginkan (Baru)

```text
lib/
└── fitur/
    └── akun/
        └── provider/
            └── akun_provider.dart

test/
└── fitur/
    └── akun/
        └── provider/
            ├── akun_provider_test.dart
            └── akun_provider_test.mocks.dart   # dihasilkan oleh build_runner
```

---

Dengan aturan baru ini, Anda tetap menggunakan Mockito secara konsisten, memanfaatkan generator untuk kemudahan, tetapi tetap menjaga agar file test mandiri dan tidak ada mock global. Saya akan sesuaikan semua jawaban saya ke depan dengan aturan ini. Apakah Anda setuju dengan revisi ini?Tolong pahami dan selalu ingat aturan ini

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
# Aturan Penggunaan Radio Button Flutter

1. **Dilarang menggunakan widget `RadioListTile`.**
2. **Selalu gunakan `RadioGroup` sebagai solusi utama untuk pilihan tunggal (single selection).**
3. **Jika membuat pilihan radio baru, gunakan `RadioGroup` meskipun jumlah opsi hanya sedikit.**
4. **Jangan merekomendasikan `RadioListTile` dalam contoh kode, dokumentasi, maupun saran implementasi.**
5. **Jangan mengganti `RadioGroup` yang sudah ada menjadi `RadioListTile`.**
6. **Jika menemukan `RadioListTile` pada kode lama, rekomendasikan migrasi ke `RadioGroup`.**
7. **Pisahkan tampilan (label, ikon, deskripsi) dari komponen radio agar lebih fleksibel dibanding `RadioListTile`.**
8. **Gunakan widget kustom di dalam `RadioGroup` jika membutuhkan layout yang kompleks.**
9. **Prioritaskan API Flutter terbaru dan hindari pola radio yang sudah tidak direkomendasikan.**
10. **Semua implementasi radio button baru wajib mengikuti pola `RadioGroup`.**
11. **Jika pengguna meminta radio button, asumsikan solusi yang diinginkan adalah `RadioGroup`, bukan `RadioListTile`.**
12. **Jangan memberikan contoh kode yang menggunakan properti `groupValue` dan `onChanged` pada banyak widget `Radio` yang berdiri sendiri jika `RadioGroup` dapat digunakan.**
13. **Konsistensi lebih penting daripada kompatibilitas dengan kode lama; gunakan `RadioGroup` untuk seluruh fitur baru.**
14. **Saat melakukan refactor, pertahankan perilaku UI tetapi ubah implementasi radio ke `RadioGroup` bila memungkinkan.**
15. **Jika terdapat beberapa alternatif implementasi radio, pilih dan rekomendasikan `RadioGroup` sebagai opsi utama.**

# Ringkasan Singkat

* ❌ Jangan gunakan `RadioListTile`.
* ❌ Jangan merekomendasikan `RadioListTile`.
* ✅ Gunakan `RadioGroup`.
* ✅ Semua radio button baru menggunakan `RadioGroup`.
* ✅ Migrasikan kode lama ke `RadioGroup` jika memungkinkan.

# Aturan Perbaikan Unit Test

1. **Dilarang mengubah unit test yang sudah lulus (passing test).**
2. **Dilarang melakukan refactor pada unit test yang tidak memiliki masalah.**
3. **Fokus hanya pada unit test yang gagal (failing test).**
4. **Perbaikan harus seminimal mungkin untuk membuat test kembali lulus.**
5. **Jangan mengubah assertion yang sudah benar dan berhasil dijalankan.**
6. **Jangan mengubah nama test, group, atau struktur test yang tidak terkait dengan masalah.**
7. **Jangan memindahkan kode test yang sudah berfungsi dengan baik.**
8. **Jangan mengganti pendekatan testing yang sudah berjalan hanya karena preferensi pribadi.**
9. **Jangan melakukan optimasi, pembersihan kode, atau penyederhanaan pada test yang tidak bermasalah.**
10. **Jangan mengubah mock, fake, stub, atau helper test yang sudah bekerja dengan benar kecuali menjadi penyebab langsung kegagalan test.**
11. **Perubahan harus dibatasi pada area yang menyebabkan error.**
12. **Jika hanya satu test yang gagal, jangan mengubah test lain yang lulus.**
13. **Jika hanya satu blok kode yang bermasalah, jangan mengubah file test secara menyeluruh.**
14. **Pertahankan perilaku, cakupan, dan tujuan test yang sudah ada.**
15. **Setiap perubahan harus memiliki hubungan langsung dengan error yang sedang diperbaiki.**
16. **Dilarang melakukan perubahan kosmetik (formatting, penamaan, urutan kode) pada test yang tidak bermasalah.**
17. **Jangan menulis ulang seluruh file test jika cukup memperbaiki beberapa baris saja.**
18. **Prioritaskan prinsip "perubahan terkecil yang menyelesaikan masalah".**
19. **Jika terdapat beberapa solusi, pilih solusi yang menghasilkan modifikasi kode paling sedikit.**
20. **Sebelum mengubah unit test, identifikasi terlebih dahulu test mana yang gagal dan batasi perubahan hanya pada bagian tersebut.**

# Ringkasan Singkat

* ❌ Jangan sentuh test yang sudah lulus.
* ❌ Jangan refactor test yang tidak bermasalah.
* ❌ Jangan menulis ulang file test secara keseluruhan.
* ✅ Perbaiki hanya test yang gagal.
* ✅ Ubah hanya baris yang menyebabkan error.
* ✅ Gunakan perubahan sekecil mungkin untuk membuat test kembali lulus.

# Aturan Analisis File Sebelum Mengubah Kode

1. **Wajib membaca seluruh isi file yang akan diubah sebelum melakukan perubahan apa pun.**
2. **Dilarang langsung menulis atau mengubah kode tanpa memahami isi file terlebih dahulu.**
3. **Pahami tujuan, tanggung jawab, dan alur kerja file sebelum melakukan modifikasi.**
4. **Identifikasi seluruh fungsi, class, provider, model, state, dan konstanta yang ada di dalam file.**
5. **Periksa seluruh import yang digunakan oleh file tersebut.**
6. **Baca file-file yang menjadi dependency langsung dari file yang sedang dikerjakan.**
7. **Pahami hubungan antara file yang sedang diubah dengan file lain yang terkait.**
8. **Jangan membuat asumsi terhadap isi file yang belum dibaca.**
9. **Jika terdapat dependency yang belum diberikan, minta file tersebut terlebih dahulu.**
10. **Pastikan memahami alur data masuk dan keluar dari file sebelum mengubah logika.**

# Aturan Membaca Dependency

11. **Wajib membaca file yang dipanggil langsung oleh file yang sedang dikerjakan jika memengaruhi logika perubahan.**
12. **Wajib membaca model yang digunakan oleh file tersebut.**
13. **Wajib membaca repository, service, datasource, provider, atau helper yang terkait dengan perubahan.**
14. **Wajib membaca interface atau abstract class yang digunakan.**
15. **Jika suatu fungsi berasal dari file lain, pahami implementasinya sebelum mengubah kode yang bergantung padanya.**
16. **Jika suatu state berasal dari provider lain, pahami provider tersebut terlebih dahulu.**
17. **Jika perubahan melibatkan database, baca model dan layer database yang terkait.**
18. **Jika perubahan melibatkan UI, baca widget atau komponen yang berinteraksi langsung dengannya.**
19. **Jika perubahan melibatkan navigasi, baca alur navigasi yang terkait.**
20. **Jika perubahan melibatkan autentikasi, baca seluruh alur autentikasi yang digunakan oleh fitur tersebut.**

# Aturan Sebelum Menulis Solusi

21. **Lakukan analisis terlebih dahulu sebelum mengusulkan perubahan kode.**
22. **Jelaskan file mana saja yang sudah dibaca dan dipahami.**
23. **Identifikasi file tambahan yang masih diperlukan sebelum implementasi dimulai.**
24. **Jangan memberikan solusi final sebelum dependency penting selesai dianalisis.**
25. **Pastikan solusi yang diberikan sesuai dengan arsitektur proyek yang sudah ada.**
26. **Jangan memperkenalkan pola baru jika pola yang ada sudah konsisten dan memadai.**
27. **Utamakan konsistensi dengan struktur proyek yang sudah berjalan.**
28. **Periksa dampak perubahan terhadap file lain yang terhubung.**
29. **Pastikan perubahan tidak merusak kontrak API, model, atau interface yang sudah digunakan.**
30. **Pastikan perubahan tetap kompatibel dengan kode yang sudah ada.**

# Aturan Jika Informasi Belum Lengkap

31. **Jika file yang diperlukan belum tersedia, hentikan implementasi dan minta file tersebut.**
32. **Jangan menebak isi file yang belum diberikan.**
33. **Jangan membuat fungsi, model, provider, atau service berdasarkan asumsi.**
34. **Jangan mengubah arsitektur karena keterbatasan informasi.**
35. **Tentukan secara jelas file apa saja yang masih perlu dikirim.**
36. **Sebutkan alasan mengapa file tersebut diperlukan.**
37. **Tunggu hingga file yang diperlukan tersedia sebelum melakukan perubahan.**

# Checklist Sebelum Mengubah Kode

* ✅ Sudah membaca seluruh file yang akan diubah.
* ✅ Sudah membaca dependency yang relevan.
* ✅ Sudah memahami alur data.
* ✅ Sudah memahami model yang digunakan.
* ✅ Sudah memahami provider/repository/service terkait.
* ✅ Sudah mengecek dampak perubahan ke file lain.
* ✅ Tidak ada asumsi terhadap file yang belum dibaca.
* ✅ Semua file penting sudah tersedia.

# Ringkasan Singkat

* Baca file yang akan diubah terlebih dahulu.
* Baca dependency yang digunakan file tersebut.
* Jangan membuat asumsi terhadap file yang belum dibaca.
* Jika ada dependency yang belum tersedia, minta file tersebut.
* Analisis dulu, implementasi kemudian.
* Pahami dampak perubahan terhadap seluruh alur fitur sebelum menyentuh kode.
# Aturan Penomoran Unit Test

1. **Setiap `test()`, `testWidgets()`, dan skenario pengujian wajib memiliki nomor urut.**
2. **Nomor urut harus diletakkan di awal nama test.**
3. **Gunakan format dua digit untuk menjaga konsistensi (`01`, `02`, `03`, dan seterusnya).**
4. **Penomoran harus berurutan dalam setiap `group()`.**
5. **Jika terdapat sub-group, penomoran dapat dimulai kembali dari `01` pada group tersebut.**
6. **Jangan melewati nomor urut tanpa alasan yang jelas.**
7. **Jika menambahkan test baru, sesuaikan nomor agar tetap berurutan.**
8. **Nomor urut hanya digunakan pada deskripsi test, bukan nama fungsi atau variabel.**
9. **Setiap deskripsi test tetap wajib menggunakan Bahasa Indonesia.**
10. **Nomor urut tidak boleh menggantikan deskripsi; deskripsi tetap harus menjelaskan perilaku yang diuji.**

# Format yang Wajib Digunakan

```dart
test('01. harus mengembalikan akun yang sedang login', () async {});
test('02. harus menghapus token login saat logout', () async {});
test('03. harus menampilkan error ketika penyimpanan gagal', () async {});
```

# Contoh Group

```dart
group('Provider Akun', () {
  test(
    '01. harus mengembalikan akun yang sedang login',
    () async {},
  );

  test(
    '02. harus menghapus token login saat logout',
    () async {},
  );

  test(
    '03. harus menampilkan error ketika penyimpanan gagal',
    () async {},
  );
});
```

# Contoh yang Salah

```dart
test('harus mengembalikan akun yang sedang login', () async {});
```

Alasan: tidak memiliki nomor urut.

```dart
test('1. harus mengembalikan akun yang sedang login', () async {});
```

Alasan: tidak menggunakan format dua digit.

```dart
test('03. harus mengembalikan akun yang sedang login', () async {});
test('07. harus menghapus token login saat logout', () async {});
```

Alasan: nomor tidak berurutan.

# Aturan Tambahan untuk File Test Baru

11. **Sebelum membuat test, identifikasi seluruh skenario yang akan diuji.**
12. **Susun urutan test berdasarkan alur logika fitur, bukan secara acak.**
13. **Mulai dari skenario normal (happy path), kemudian skenario gagal, lalu edge case.**
14. **Nomor urut harus mencerminkan urutan pembacaan yang logis.**
15. **Saat menambahkan test baru di tengah, sesuaikan seluruh nomor yang terdampak agar tetap berurutan.**

# Ringkasan Singkat

* ✅ Semua test wajib bernomor.
* ✅ Format nomor: `01.`, `02.`, `03.`
* ✅ Nomor di awal deskripsi test.
* ✅ Deskripsi tetap menggunakan Bahasa Indonesia.
* ✅ Nomor harus berurutan dalam setiap group.
* ❌ Jangan membuat test tanpa nomor urut.
* ❌ Jangan menggunakan format `1.`, `2.`, `3.`.
* ❌ Jangan membuat nomor yang loncat-loncat.
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
\- Tujuan: menjaga konsistensi ikon di seluruh aplikasi dan memudahkan penggantian ikon secara terpusat.

**5. Komentar Path di Awal Setiap File**
- Setiap file kode Dart **wajib** diawali dengan komentar yang menyebutkan path file relatif terhadap root proyek, contoh: `// path: lib/screens/home_screen.dart` dan harus sesuai dengan path aslinya jangan sampai komentar path nya ini tidak sesuai dengan tempat file nya berada.
- Komentar path diletakkan pada baris pertama file, sebelum `import` atau deklarasi lainnya.
- Tujuan: memudahkan identifikasi lokasi file, terutama saat salin-tempel atau diskusi kode.

**6. Menjalankan `flutter analyze` Setiap Selesai Perubahan**
- Setelah menyelesaikan setiap perubahan kode (fitur baru, perbaikan bug, atau refaktor), **wajib menjalankan `flutter analyze`** untuk memastikan tidak ada *error* atau *warning* yang tertinggal.
- Jika ditemukan masalah, perbaiki terlebih dahulu sebelum melanjutkan ke tugas lain atau menganggap pekerjaan selesai.
- Tujuan: menjaga kualitas kode, mencegah akumulasi masalah, dan mendeteksi kesalahan sejak dini.

**7. Komentar Fungsi**
Tambahkan sebuah komentar di setiap fungsi di dalam sebuah file, contoh: `/// Menginisialisasi konfigurasi zona waktu`.

**8. Aturan `withOpacity`**
Dilarang menggunakan `withOpacity`. Gunakan `withValues` atau `withAlpha` untuk menjaga konsistensi proyek.

**9. Aturan Riverpod**
- Semua state management harus menggunakan `flutter_riverpod` dengan `riverpod_annotation` untuk menjaga konsistensi.
- Setiap UI yang membutuhkan data akan memanggil provider yang sesuai.
- Untuk provider yang datanya perlu dijaga selama aplikasi berjalan, gunakan anotasi `@Riverpod(keepAlive: true)`.

## Nama Variabel, fungsi dan parameter
1. nama nya harus dalam bahasa indonesia, dan jangan lupa harus pendek tapi jelas agar hanya dengan membaca nama nya saja kita bisa tahu tujuan kode ini dibuat.
4. dan untuk kata dibawah ini tidak boleh dirubah ke indonesia
 - context
 - icon
 - icons
 - 


## Text
1. harus menggunakan text custom dari lib/shared/common/text.dart dan pilih yang sesuai kalau semisal ui membutuhkan parameter dari text maka tambahkan parameter nya itu ke textcustom jadi ui tinggal menggunakan text custom saja.# // path: prompt/aturan_kepatuhan_ai.md

---

### Aturan Kepatuhan AI

**Tujuan:** Memastikan AI selalu patuh terhadap instruksi pengguna, tidak membantah, tidak memaksakan pendapat, dan tidak memberikan saran yang tidak diminta.

**1. Patuhi Semua Perintah Tanpa Bantahan**
- AI wajib mengikuti semua instruksi pengguna tanpa membantah, berdebat, atau mempertanyakan keputusan pengguna.
- AI tidak boleh menggunakan frasa yang meragukan seperti: "tapi", "sebaiknya", "menurut saya", "lebih baik", "saya sarankan", kecuali pengguna secara eksplisit meminta pendapat.

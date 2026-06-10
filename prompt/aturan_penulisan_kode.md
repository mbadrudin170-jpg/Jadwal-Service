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
2. kalau ada yang masih dalam bahasa inggris tandai dengan komentar // TODO : nama masih dalam bahasa inggris.


## Text
1. harus menggunakan text custom dari lib/shared/common/text.dart dan pilih yang sesuai kalau semisal ui membutuhkan parameter dari text maka tambahkan parameter nya itu ke textcustom jadi ui tinggal menggunakan text custom saja.
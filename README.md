# Rangkuman Proyek WiFi

Selamat datang di dokumentasi proyek WiFi. Dokumen ini memberikan ringkasan tentang pekerjaan yang telah dilakukan, tantangan yang dihadapi, dan solusi yang diimplementasikan.

---

## 30 Juli 2024 - Pembaruan UI Form Versi APK

- **Konteks**: Form untuk menambah atau mengedit versi APK memiliki tombol "SIMPAN DATA RILIS" yang ikut tergulir (scroll) bersama dengan konten form lainnya.
- **Masalah**: Pengalaman pengguna kurang optimal karena tombol aksi utama tidak selalu terlihat, terutama pada layar kecil.
- **Solusi**:
    - **File**: `lib/admin/halaman/form/apk_version_form.dart`
    - **Tindakan**: Tombol `ElevatedButton` dipindahkan dari dalam `SingleChildScrollView` ke properti `bottomNavigationBar` dari `Scaffold`.
    - **Manfaat**: Tombol "SIMPAN DATA RILIS" sekarang tetap berada di bagian bawah layar (fixed/sticky), memastikan tombol tersebut selalu dapat diakses oleh pengguna tanpa perlu menggulir ke bagian paling bawah form.

---

## 29 Juli 2024 - Perbaikan Stabilitas & Refaktorisasi Arsitektur

Sesi kerja ini mencakup dua perbaikan utama: mengatasi crash saat sinkronisasi data dan memisahkan tanggung jawab pada form input.

### 1. Perbaikan Sinkronisasi Data: Inkonsistensi Nama Tabel

- **Konteks**: Aplikasi mengalami crash (`DatabaseException: no such table: kategori`) setelah menyimpan data baru. Proses sinkronisasi ke Firestore gagal karena mencoba mengakses tabel dengan nama yang salah.
- **Akar Masalah**: Terdapat inkonsistensi penamaan antara kode penyimpanan lokal (menggunakan `'category'`) dan kode sinkronisasi (menggunakan `'kategori'`).
- **Solusi**:
    - **Refaktorisasi `upload_data.dart`**: Semua nama tabel dan kolom yang ditulis manual (*hardcoded strings*) diganti dengan konstanta terpusat dari `TableNameValue` dan `ColumnNames`.
    - **Standardisasi Enum UI**: `CategoryType` diubah untuk menampilkan teks terjemahan di UI tanpa mengubah nilai enum di level kode.
- **Manfaat**: Menghilangkan error, memastikan konsistensi data, dan meningkatkan keterbacaan kode.

### 2. Refaktorisasi Form: Pemisahan Tanggung Jawab

- **Konteks**: Form penyimpanan data (contoh: `category_form.dart`) sebelumnya juga bertanggung jawab untuk memicu sinkronisasi data secara langsung setelah penyimpanan lokal.
- **Masalah**: Hal ini mencampuradukkan tanggung jawab UI dengan proses latar belakang, membuat form menjadi kurang responsif, dan sulit untuk mengelola proses sinkronisasi secara terpusat.
- **Solusi**:
    - **Menghapus Logika Sinkronisasi**: Kode yang berhubungan dengan `UploadDataService` dan pengecekan koneksi internet dihapus sepenuhnya dari `lib/admin/halaman/form/category_form.dart`.
    - **Fokus pada Penyimpanan Lokal**: Tanggung jawab form kini hanya sebatas validasi input dan penyimpanan data ke database lokal (SQLite).
- **Manfaat**:
    - **Pemisahan yang Jelas (*Separation of Concerns*)**: UI (form) tidak lagi dibebani dengan logika sinkronisasi.
    - **Pengalaman Pengguna Lebih Baik**: Proses penyimpanan di form terasa lebih instan karena tidak lagi menunggu proses sinkronisasi.
    - **Arsitektur Lebih Kuat**: Proses sinkronisasi data sekarang dapat dikelola oleh mekanisme terpusat yang berjalan di latar belakang, terpisah dari interaksi pengguna langsung.

---

## 28 Juli 2024 - Refaktorisasi Notifikasi dan Penghapusan TODO

- **Konteks**: Peningkatan kualitas kode dengan mengganti implementasi `SnackBar` manual menjadi `SnackBarUtil` yang terpusat.
- **File**: `lib/admin/halaman/form/package_form.dart`
- **Tindakan**: Mengganti `ScaffoldMessenger` dengan `SnackBarUtil`, menghapus komentar TODO yang sudah selesai, dan memperbarui dokumentasi file.
- **Manfaat**: Konsistensi UI, kode lebih bersih, dan pemeliharaan terpusat.

---

## 17 Mei 2026 - Perbaikan Linter & Stabilitas Kode

Sesi kerja ini berfokus pada perbaikan semua error dan warning yang dilaporkan oleh `flutter analyze` berdasarkan aturan linter yang ketat di `analysis_options.yaml`.

### Masalah Utama yang Diatasi:

1.  **`use_build_context_synchronously`**: Menambahkan pemeriksaan `if (!mounted) return;` setelah operasi `async` untuk mencegah crash.
2.  **`deprecated_member_use`**: Mengganti penggunaan `RadioListTile` yang usang dengan `RadioGroup`.

---

*Dokumen ini akan terus diperbarui seiring dengan kemajuan proyek.* 

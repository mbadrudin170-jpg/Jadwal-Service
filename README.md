# Proyek WiFi - Aplikasi Manajemen Layanan & Pelanggan

Selamat datang di dokumentasi proyek WiFi. Proyek ini merupakan sebuah ekosistem aplikasi Flutter yang dirancang untuk mengelola layanan berbasis langganan, dengan pemisahan peran yang jelas antara administrator dan pengguna akhir.

---

## Ringkasan Proyek

Proyek ini terdiri dari dua aplikasi utama yang berada dalam satu basis kode (monorepo):

1.  **Aplikasi Admin:** Sebuah *control panel* lengkap yang berfungsi sebagai pusat manajemen bisnis. Admin dapat mengelola data master (pelanggan, paket layanan, kategori), memproses transaksi, melihat riwayat, dan memantau statistik bisnis.

2.  **Aplikasi User:** Aplikasi yang dihadapi oleh pelanggan. Pengguna dapat melihat detail langganan mereka, memeriksa riwayat transaksi, memberikan masukan (*feedback*), dan mendapatkan informasi terbaru mengenai layanan. Aplikasi ini juga terintegrasi dengan iklan (Google AdMob) sebagai salah satu model bisnis.

Arsitektur ini memungkinkan pengembangan fitur yang terfokus untuk setiap peran sambil tetap berbagi logika bisnis, model data, dan utilitas umum.

---

## Fitur Utama

### Aplikasi Admin
- **Manajemen Data Offline-First:** Menggunakan database SQLite lokal sebagai *cache* utama untuk kecepatan dan operasi offline. 
- **Sinkronisasi Data Dua Arah:** Kemampuan untuk mengunduh data dari Cloud Firestore ke database lokal dan mengunggah perubahan lokal kembali ke cloud.
- **CRUD Komprehensif:** Manajemen penuh untuk Pelanggan, Paket, Kategori, Transaksi, dan Dompet.
- **Dashboard & Statistik:** Halaman khusus untuk memvisualisasikan data penting bisnis (misal: paket terlaris, ringkasan keuangan).
- **Manajemen Versi APK:** Fitur untuk mengelola dan mendistribusikan versi aplikasi kepada pengguna.
- **Pembersihan Data Otomatis:** Mekanisme untuk membersihkan data arsip yang sudah kadaluarsa secara periodik.

### Aplikasi User
- **Autentikasi & Profil:** Pengguna dapat masuk dan mengelola informasi profil dasar.
- **Tampilan Informasi Pelanggan:** Menampilkan status langganan aktif, riwayat pembelian, dan detail akun.
- **Sistem Poin & Reward:** Pengguna dapat mengumpulkan poin dari aktivitas tertentu.
- **Pemberian Feedback:** Pengguna dapat mengirimkan masukan atau keluhan kepada admin.
- **Notifikasi Lokal:** Pengingat dan pemberitahuan penting yang dijadwalkan di perangkat.
- **Integrasi Iklan:** Menampilkan iklan sebagai bagian dari model monetisasi aplikasi.

---

## Arsitektur & Teknologi

Proyek ini dibangun dengan tumpukan teknologi modern untuk aplikasi Flutter.

- **Bahasa:** Dart
- **Framework:** Flutter

- **Arsitektur Aplikasi:**
  - **Flavors:** Menggunakan *flavors* (misal: `adminProd`, `userProd`) untuk memisahkan konfigurasi dan titik masuk (entry point) antara aplikasi admin dan user.
  - **State Management:** `provider` untuk *dependency injection* dan manajemen state.
  - **Pemisahan Logika:** Lapisan abstraksi data (`/shared/operasi`) memisahkan logika bisnis dari implementasi sumber data (baik itu Firebase maupun SQLite).

- **Penyimpanan Data:**
  - **Cloud Database:** `cloud_firestore` sebagai sumber data utama dan untuk sinkronisasi antar perangkat.
  - **Local Database:** `sqflite` digunakan secara ekstensif di aplikasi admin untuk operasi offline-first yang cepat.
  - **Key-Value Store:** `shared_preferences` untuk menyimpan pengaturan sederhana seperti tema aplikasi.

- **Lainnya:**
  - **Tugas Latar Belakang:** `workmanager` untuk menjalankan tugas periodik.
  - **Navigasi:** `go_router` dan navigator kustom berbasis `NavigatorKey`.
  - **Notifikasi:** `flutter_local_notifications`.
  - **Monetisasi:** `google_mobile_ads` dengan mediasi pihak ketiga.

---

## Alur Kerja Pengembangan

Proyek ini mengikuti serangkaian aturan dan alur kerja yang terdokumentasi untuk menjaga kualitas dan konsistensi kode.

### 1. Aturan Koding
- **Penamaan:** Variabel, fungsi, dan kelas dalam Bahasa Inggris. Komentar dan dokumentasi dalam Bahasa Indonesia.
- **Kualitas Kode:** Wajib menjalankan `flutter analyze` setelah melakukan perubahan untuk mendeteksi error dan warning.
- **Ketergantungan Ikon:** Semua ikon harus direferensikan melalui kelas `AppIcons` untuk konsistensi.

### 2. Analisis Error
- Mengikuti prosedur terstruktur untuk menelusuri error, dimulai dari identifikasi file, membaca semua dependensi impor, dan menganalisis dampak perubahan ke file lain.

### 3. Proses Build
- Proses build APK untuk Admin dan User menggunakan alias shell script yang telah ditentukan (`fbapkver_admin` dan `fbapkver_user`).
- Setiap build yang berhasil **wajib** dicatat versinya di dalam direktori `docs/build/` untuk menjaga riwayat rilis.

### 4. Logging & Notifikasi Pengguna
- Penggunaan `Log` kustom untuk debugging terstruktur.
- Penggunaan `ToastUtil` untuk menampilkan notifikasi *in-app* (snackbar) yang konsisten.

Untuk detail lebih lanjut, silakan merujuk ke dokumen-dokumen di folder `prompt/`.

---

## Cara Memulai

1.  **Pastikan Flutter terinstal** pada versi yang sesuai (lihat `environment` di `pubspec.yaml`).
2.  **Konfigurasi Firebase:** Pastikan Anda memiliki file `firebase_options.dart` yang sesuai untuk setiap *flavor* (admin dan user) dan untuk setiap lingkungan (dev dan prod).
3.  **Jalankan `flutter pub get`** untuk menginstal semua dependensi.
4.  **Jalankan Aplikasi:** Gunakan perintah `flutter run` dengan *flavor* yang diinginkan.

    *   **Untuk Menjalankan Aplikasi User (Produksi):**
        ```bash
        flutter run --flavor userProd -t lib/main/main_user/user_prod.dart
        ```

    *   **Untuk Menjalankan Aplikasi Admin (Produksi):**
        ```bash
        flutter run --flavor adminProd -t lib/main/main_admin/admin_prod.dart
        ```

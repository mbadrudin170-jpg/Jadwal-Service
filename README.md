
# Dokumentasi Proyek WiFi Management

Selamat datang di dokumentasi proyek aplikasi Manajemen WiFi. Proyek ini dibangun menggunakan Flutter dan dirancang untuk membantu pengelola usaha WiFi dalam mengelola pelanggan, transaksi, dan layanan, serta memberikan aplikasi pendamping bagi pelanggan untuk memeriksa status langganan mereka.

## 🌟 Ringkasan Proyek

Aplikasi ini dibagi menjadi dua *flavor* atau varian utama:

1.  **Aplikasi Admin**: Sebuah alat manajemen komprehensif untuk pemilik usaha.
2.  **Aplikasi User**: Aplikasi yang digunakan oleh pelanggan untuk berinteraksi dengan layanan.

Pemisahan ini memungkinkan pengembangan fitur yang terfokus untuk setiap jenis pengguna dan memastikan basis kode yang lebih bersih dan terkelola.

---

## 👨‍💼 Aplikasi Admin

Aplikasi Admin adalah pusat kendali untuk seluruh operasi bisnis WiFi. Tujuannya adalah untuk mempermudah pencatatan, pengelolaan, dan analisis data bisnis.

### Fitur Utama:

*   **Dashboard & Statistik (`statistik_page_a.dart`)**: Menampilkan ringkasan visual dari data bisnis, seperti pendapatan, pelanggan baru, dan paket terlaris.
*   **Manajemen Pelanggan (`customer.dart`, `active_customer_tab.dart`)**:
    *   Mencatat dan mengelola seluruh daftar pelanggan.
    *   Melihat daftar pelanggan yang sedang aktif berlangganan.
    *   Melihat detail riwayat setiap pelanggan.
*   **Manajemen Transaksi (`transaction_page_a.dart`)**:
    *   Mencatat semua transaksi pembayaran dari pelanggan.
    *   Memfilter dan mencari transaksi berdasarkan tanggal atau status.
*   **Manajemen Dompet (`wallet_page.dart`)**: Mengelola saldo atau deposit yang dapat digunakan untuk transaksi, berfungsi sebagai kas internal.
*   **Manajemen Paket Layanan (`package.dart`)**: Membuat, mengubah, atau menghapus paket langganan internet yang ditawarkan (misal: Bulanan, Mingguan).
*   **Manajemen Versi APK (`apk_version_page.dart`)**:
    *   Mengunggah dan mengelola versi aplikasi user.
    *   Memberikan notifikasi pembaruan kepada pengguna.
*   **Umpan Balik Pelanggan (`feedback.dart`)**: Melihat dan merespons umpan balik atau keluhan yang dikirim oleh pengguna melalui aplikasi mereka.
*   **Pengaturan Global (`settings_page_a.dart`)**: Mengatur konfigurasi umum yang berlaku di seluruh sistem.

---

## 📱 Aplikasi User

Aplikasi User dirancang untuk memberikan kemudahan dan transparansi bagi pelanggan.

### Fitur Utama:

*   **Pemeriksaan Status Langganan (`main_page.dart`, `subscription_history_user.dart`)**:
    *   Fitur utama yang memungkinkan pengguna melihat status aktif paket langganan mereka.
    *   Melihat sisa waktu paket dan riwayat langganan sebelumnya.
*   **Poin & Hadiah (`points_page.dart`)**:
    *   Pengguna mendapatkan poin dari aktivitas tertentu (misal: pembayaran tepat waktu).
    *   Poin dapat ditukarkan dengan hadiah atau diskon yang tersedia.
*   **Profil Pengguna (`profile_page.dart`, `edit_profile_page.dart`)**:
    *   Melihat dan mengubah informasi data diri.
*   **Kirim Umpan Balik (`user_feedback_form.dart`)**: Memberikan sarana bagi pengguna untuk mengirim keluhan, saran, atau laporan masalah.
*   **Riwayat Transaksi (`transaction_detail_u.dart`)**: Melihat detail riwayat pembayaran yang telah dilakukan.
*   **Integrasi Iklan**: Aplikasi ini didukung oleh iklan (Banner, Interstitial, App Open) melalui Google Mobile Ads dengan mediasi Unity untuk memberikan potensi monetisasi.

---

## 🏗️ Arsitektur & Teknologi

*   **Framework**: Flutter
*   **State Management**: `flutter_riverpod`
*   **Struktur Proyek**:
    *   `lib/admin`: Kode spesifik untuk aplikasi Admin.
    *   `lib/user`: Kode spesifik untuk aplikasi User.
    *   `lib/shared`: Kode yang dapat digunakan kembali oleh kedua aplikasi (model data, logika bisnis, servis, tema, widget).
*   **Database**:
    *   **Lokal**: SQLite (`sqlite.dart`) digunakan di sisi admin untuk penyimpanan data offline.
    *   **Backend**: Firebase (Cloud Firestore) digunakan sebagai backend utama untuk sinkronisasi data antara admin dan user (`firebase_operasi`).
*   **Layanan Latar Belakang**: `background_service.dart` untuk tugas-tugas terjadwal seperti pengecekan langganan yang kedaluwarsa.
*   **Proses Build**: Menggunakan *flavors* untuk memisahkan build `dev` dan `prod` untuk admin dan user. Riwayat build dicatat dalam direktori `docs/build/`.

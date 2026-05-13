# Dokumentasi APK User

## **Refactoring & Perbaikan Fitur Kritik dan Saran (26 Juli 2024)**

Melakukan refactoring signifikan pada fitur "Kritik dan Saran" untuk meningkatkan kualitas kode, memisahkan logika dari tampilan, dan memperbaiki serangkaian error dan peringatan yang terdeteksi oleh `flutter analyze`.

### **Perubahan Utama**

1.  **Pemisahan Logika Bisnis (Clean Architecture)**
    *   **File Baru Dibuat**: `lib/user/data/operasi/kritik_saran_operasi_user.dart`
    *   **Tujuan**: Semua logika bisnis untuk operasi Create, Read, Update, Delete (CRUD) pada data kritik dan saran pengguna dipindahkan ke dalam kelas `KritikSaranOperasiUser` di file ini. Hal ini memisahkan logika pengelolaan data dari kode UI, membuatnya lebih mudah diuji dan dipelihara.

2.  **Refactoring Kode UI**
    *   **File yang Diubah**:
        *   `lib/user/page/kritik_dan_saran_user.dart` (Halaman Riwayat)
        *   `lib/user/page/form_kritik_dan_saran.dart` (Halaman Form)
    *   **Perubahan**: Kedua file ini sekarang mengimpor dan menggunakan instance dari `KritikSaranOperasiUser` untuk semua interaksi data. Kode UI tidak lagi berinteraksi langsung dengan Firebase, melainkan melalui kelas operasi yang telah dibuat.

3.  **Perbaikan Error Kritis di Halaman Admin**
    *   **File yang Diperbaiki**:
        *   `lib/admin/halaman/detail/detail_kritik_saran.dart`
        *   `lib/admin/halaman/lainnya/kritik_saran.dart`
    *   **Masalah**: Terjadi error `argument_type_not_assignable` karena properti `tanggal` pada model `KritikSaranModel` diubah menjadi nullable (`DateTime?`), tetapi kode UI di halaman admin masih menganggapnya non-nullable.
    *   **Solusi**: Menambahkan *null check* pada properti `tanggal`. Jika data tanggal ada, maka akan diformat. Jika `null`, maka akan ditampilkan teks "Tanggal tidak tersedia" sebagai *fallback*.

4.  **Perbaikan Peringatan Linter (`use_build_context_synchronously`)**
    *   **File yang Diperbaiki**: `lib/user/page/kritik_dan_saran_user.dart`
    *   **Masalah**: Linter memberikan peringatan karena `BuildContext` digunakan setelah operasi *asynchronous* (setelah `await`), yang berisiko menyebabkan error jika widget sudah tidak ada lagi di *widget tree*.
    *   **Solusi**: Kode di-refactor dengan menyimpan referensi `Navigator` dan `ScaffoldMessenger` ke dalam variabel lokal *sebelum* menjalankan operasi `await`. Variabel lokal inilah yang kemudian digunakan, memastikan keamanan dalam penggunaan `BuildContext`.

### **Manfaat & Hasil**

*   **Kode Lebih Bersih & Terstruktur**: Arsitektur aplikasi menjadi lebih baik dengan pemisahan yang jelas antara lapisan data dan lapisan presentasi.
*   **Stabilitas Ditingkatkan**: Semua error kritis dan peringatan linter telah diatasi, membuat aplikasi lebih stabil dan andal.
*   **Kemudahan Perawatan**: Dengan logika bisnis yang terpusat, pembaruan atau perbaikan di masa depan akan lebih mudah dilakukan tanpa harus menyentuh kode UI secara ekstensif.
*   **Kesiapan untuk Pengujian**: Logika bisnis yang terisolasi sekarang siap untuk diuji menggunakan *unit test*.

---

## Refaktor Pengambilan Data Paket (25 Juli 2024)

Melakukan refaktor besar pada alur pengambilan dan penampilan nama paket di aplikasi pengguna untuk memperbaiki bug "Paket tidak ditemukan" yang sering muncul di log.

### Perubahan Utama

1.  **`lib/user/services/firestore_service.dart`**
    - **Tujuan**: Memusatkan semua interaksi dengan Firestore untuk aplikasi pengguna.
    - **Fungsi Baru Ditambahkan**:
        - `Future<PaketModel?> ambilPaketModelById(String paketId)`: Fungsi krusial ini ditambahkan untuk mengambil satu dokumen paket dari koleksi `paket` di Firestore berdasarkan ID-nya. Ini memungkinkan UI untuk mendapatkan detail lengkap sebuah paket secara asinkron.

2.  **`lib/user/page/riwayat_langganan_user.dart`**
    - **Tujuan**: Menampilkan riwayat transaksi langganan pengguna.
    - **Perubahan Logika**:
        - **Pengambilan Data Cerdas**: Di dalam `ListView.builder`, untuk setiap item transaksi, kode sekarang memanggil `_firestoreService.ambilPaketModelById()` untuk mendapatkan `Future<PaketModel?>`. `Future` ini kemudian diteruskan ke `NamaPaketWidget` yang sudah di-refactor.
        - **Navigasi yang Efisien**: Saat pengguna mengetuk sebuah item riwayat untuk melihat detailnya, logika `onTap` kini bersifat `async`. Ia akan `await` hasil dari `Future` paket. Setelah objek `PaketModel` lengkap didapatkan, objek tersebut diteruskan langsung ke konstruktor `DetailTransaksiPage`. Ini menghilangkan kebutuhan halaman detail untuk melakukan query datanya sendiri.

3.  **`lib/user/page/detail_transaksi_user.dart`**
    - **Tujuan**: Menampilkan rincian dari satu transaksi.
    - **Perubahan Logika**:
        - **Konstruktor Baru**: Konstruktornya diubah untuk menerima objek `PaketModel?` yang bisa null, selain `TransaksiModel`.
        - **Penampilan Data Langsung**: Halaman ini tidak lagi bergantung pada `NamaPaketWidget` atau melakukan query sendiri. Ia kini langsung menampilkan nama paket dari objek `paket` yang diterima melalui konstruktor, membuat widget ini lebih sederhana dan efisien.

### Manfaat & Hasil

- **Bug Teratasi**: Peringatan `Paket tidak ditemukan` di log pengguna telah hilang karena aplikasi sekarang mencari data paket di Firestore, bukan di database SQLite lokal.
- **Arsitektur Lebih Baik**: Dengan memisahkan UI (`NamaPaketWidget`) dari logika pengambilan data, kode menjadi lebih bersih, modular, dan mudah dipelihara.
- **Alur Data Jelas**: Alur data menjadi logis dan efisien. Halaman daftar (`riwayat_langganan_user.dart`) bertanggung jawab mengambil data, dan halaman detail (`detail_transaksi_user.dart`) hanya bertanggung jawab menampilkannya.

---

## Perbaikan Error Pemformatan Tanggal (23 Juli 2024)

Melakukan perbaikan pada beberapa file di dalam direktori `lib/user/page` yang mengalami error akibat kesalahan impor dan pemanggilan fungsi untuk pemformatan tanggal dan waktu.

### Perubahan

1.  **Mengganti Impor:**
    *   Kesalahan impor `package:wifi/user/core/utils/format_tanggal.dart` telah diperbaiki.
    *   Sekarang semua file menggunakan sumber tunggal untuk utilitas pemformatan dari `package:wifi/shared/utils/format_util.dart`.

2.  **Memperbaiki Pemanggilan Fungsi:**
    *   Pemanggilan fungsi yang salah seperti `formatDate` dan `formatDateTimeWithMonthName` telah diganti dengan metode yang benar dari kelas `FormatTanggal` dan `FormatUang`, contohnya `FormatTanggal.formatTanggalDanJam()` dan `FormatUang.formatMataUang()`.

3.  **Menambahkan Logging:**
    *   Logging ditambahkan di setiap file yang diubah untuk membantu proses debugging dan melacak alur kerja aplikasi.

### File yang Diperbaiki

*   `lib/user/page/detail_transaksi_user.dart`
*   `lib/user/page/home_page.dart`
*   `lib/user/page/profil_page.dart`

Perbaikan ini memastikan konsistensi dalam pemformatan data di seluruh aplikasi dan menghilangkan error yang terjadi saat runtime.

# Dokumentasi APK User

## Peningkatan Stabilitas Kode Melalui Perbaikan Pengujian

- **Konteks**: Meskipun tidak terlihat langsung oleh pengguna, lingkungan pengujian di belakang layar mengalami masalah yang menghambat verifikasi kualitas kode. Proses `build_runner`, yang penting untuk membuat *mock* dalam pengujian, gagal berjalan.
- **Tindakan**: Dilakukan perbaikan menyeluruh pada infrastruktur pengujian. Berkas-berkas pengujian yang rusak dan menyebabkan kegagalan `build_runner` telah diidentifikasi dan diperbaiki.
- **Manfaat untuk Pengguna**: Dengan lingkungan pengujian yang sekarang stabil, setiap perubahan atau penambahan fitur baru dapat diverifikasi secara otomatis untuk mencegah regresi (munculnya kembali bug lama) dan memastikan kualitas kode tetap terjaga. Ini secara tidak langsung berkontribusi pada aplikasi yang lebih stabil dan andal bagi pengguna akhir.

---

## Refaktorisasi Halaman Edit Profil dan Modernisasi Akses Data (Terbaru)

Sebagai bagian dari pembersihan arsitektur, halaman `edit_profil_page.dart` telah dirombak total untuk meninggalkan pola akses data yang usang dan mengadopsi praktik terbaik yang lebih modern dan konsisten dengan bagian lain dari aplikasi.

### Masalah yang Diidentifikasi

Analisis kode menunjukkan bahwa `edit_profil_page.dart` memiliki beberapa masalah serius:

1.  **Dependensi Usang**: Halaman ini masih bergantung pada file `firestore_service.dart` yang generik dan telah dijadwalkan untuk dihapus.
2.  **Inkonsistensi Notifikasi**: Menggunakan `ScaffoldMessenger.showSnackBar` secara langsung, alih-alih menggunakan utilitas terpusat `SnackBarUtil` yang menyediakan gaya dan logging yang seragam.
3.  **Logika Pembaruan yang Berisiko**: Saat mencoba memperbarui data pengguna, kode membuat instance `PelangganModel` baru dengan cara yang tidak aman, yang menyebabkan error `undefined_named_parameter` karena konstruktor tidak cocok.

### Perubahan yang Dilakukan

1.  **Migrasi ke `PelangganOpFirebase`**: Semua panggilan ke `firestore_service.dart` telah diganti dengan panggilan ke `PelangganOpFirebase.perbaruiPelanggan()`. Ini menyelaraskan halaman dengan arsitektur baru di mana setiap model memiliki kelas operasi Firestore-nya sendiri.
2.  **Implementasi `SnackBarUtil`**: Semua notifikasi (baik untuk keberhasilan maupun kegagalan) sekarang ditampilkan menggunakan `SnackBarUtil.showSuccess()` dan `SnackBarUtil.showError()`. Ini memastikan pengalaman pengguna yang konsisten dan logging otomatis untuk setiap notifikasi.
3.  **Penggunaan `copyWith` yang Aman**: Logika pembaruan data telah diperbaiki secara fundamental. Alih-alih membuat objek baru dari awal, kode sekarang menggunakan metode `widget.pelanggan.copyWith(...)`. Ini adalah cara yang aman dan direkomendasikan untuk membuat salinan model dengan beberapa perubahan, secara efektif menghilangkan risiko error terkait konstruktor.

### Manfaat Perubahan

- **Kode yang Bersih dan Terpusat**: Halaman ini sekarang mengikuti arsitektur yang sama dengan bagian lain dari aplikasi, membuatnya lebih mudah dipahami dan dipelihara.
- **Stabilitas yang Ditingkatkan**: Dengan menggunakan `copyWith` dan menghilangkan dependensi lama, potensi bug runtime telah berkurang secara signifikan.
- **Pengalaman Pengguna yang Konsisten**: Penggunaan `SnackBarUtil` memastikan semua pesan yang dilihat pengguna memiliki tampilan dan nuansa yang sama di seluruh aplikasi.

---

## **Peningkatan Sistem Logging & Perbaikan Error (27 Juli 2024)**

Melakukan pembaruan signifikan pada sistem logging di seluruh aplikasi pengguna dan memperbaiki serangkaian error sintaks yang muncul selama proses tersebut. Pekerjaan ini sangat penting untuk meningkatkan visibilitas alur kerja aplikasi dan mempermudah proses debugging di masa depan, sejalan dengan aturan ketat yang ditetapkan dalam `GEMINI.md`.

### **Perubahan Utama**

1.  **Penambahan Log Rinci pada Alur Startup**
    *   **File yang Diperkaya**: `lib/user/app_user.dart`
    *   **Detail**: Log yang sangat terperinci ditambahkan pada setiap langkah krusial saat aplikasi dimulai:
        *   Proses `initState` dan pemanggilan `Future` untuk mengambil data pengaturan.
        *   Setiap status koneksi dari `FutureBuilder` (`waiting`, `error`, `hasData`).
        *   Analisis data pengaturan dari Firestore, termasuk pengecekan mode pemeliharaan.
        *   Pembangunan UI utama aplikasi, termasuk inisialisasi `Provider`.
    *   **Tujuan**: Memberikan jejak (trace) yang jelas jika terjadi kegagalan saat aplikasi pertama kali dibuka.

2.  **Penambahan Log pada Interaksi Pengguna**
    *   **File yang Diperkaya**: `lib/user/maintenance_page.dart`
    *   **Detail**: Log ditambahkan untuk mencatat kapan halaman pemeliharaan ditampilkan dan ketika pengguna berinteraksi dengan tombol "Coba Lagi" atau "Keluar".
    *   **Tujuan**: Memahami tindakan pengguna ketika mereka menghadapi halaman pemeliharaan.

3.  **Perbaikan Error Sintaks pada Pemanggilan Log**
    *   **File yang Diperbaiki**: `lib/user/app_user.dart`
    *   **Masalah**: Terdeteksi error `undefined_named_parameter` karena pemanggilan `Log.warning` yang salah. Parameter `e:` untuk error coba dilewatkan, padahal `Log.warning` tidak mendukungnya.
    *   **Solusi**: Memperbaiki pemanggilan dengan memasukkan detail error langsung ke dalam pesan string utama dari `Log.warning`, sesuai dengan definisi fungsinya.

### **Manfaat & Hasil**

*   **Debugging Lebih Mudah**: Dengan log yang detail di setiap titik kritis, melacak sumber masalah menjadi jauh lebih cepat dan efisien.
*   **Kepatuhan Aturan**: Pembaruan ini memastikan aplikasi mematuhi aturan logging yang ketat seperti yang diamanatkan dalam dokumen `GEMINI.md`.
*   **Stabilitas Kode**: Perbaikan pada sintaks pemanggilan `Log` menghilangkan error analisis dan menjadikan kode lebih stabil.

---

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

---

## Standarisasi Notifikasi dengan `SnackBarUtil`

- **Konteks**: Untuk meningkatkan konsistensi UI/UX di seluruh aplikasi pengguna, semua notifikasi *snackbar* telah distandarisasi.
- **Tindakan**: Semua pemanggilan `ScaffoldMessenger.of(context).showSnackBar()` telah diganti dengan utilitas terpusat, `SnackBarUtil`. Perubahan ini diterapkan pada file-file seperti:
  - `lib/user/page/kritik_dan_saran_user.dart`
  - `lib/user/page/login_page.dart`
  - `lib/user/page/poin_page_user.dart`
- **Hasil**: Notifikasi di seluruh aplikasi pengguna sekarang memiliki tampilan dan perilaku yang seragam, dikelola dari satu sumber kebenaran (`SnackBarUtil`), yang membuat kode lebih bersih dan lebih mudah dipelihara.

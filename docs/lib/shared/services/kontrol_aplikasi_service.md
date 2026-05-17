
# Dokumentasi: KontrolAplikasiService

## Lokasi File
`lib/shared/services/kontrol_aplikasi_service.dart`

## Ringkasan
`KontrolAplikasiService` adalah sebuah layanan backend-as-a-service yang krusial untuk manajemen aplikasi dari jarak jauh. Fungsinya adalah untuk membaca dan menulis konfigurasi status aplikasi yang disimpan di **Cloud Firestore**. Tujuan utamanya adalah untuk mengaktifkan atau menonaktifkan "mode maintenance" di seluruh aplikasi pengguna secara dinamis tanpa perlu merilis pembaruan aplikasi.

Layanan ini berinteraksi langsung dengan dokumen spesifik di Firestore, yaitu `pengaturan/status_aplikasi`.

## Arsitektur dan Ketergantungan
-   **cloud_firestore**: Ketergantungan utama. Layanan ini secara langsung menggunakan `FirebaseFirestore.instance` untuk berkomunikasi dengan database.
-   **Hardcoded Path**: Jalur ke dokumen (`pengaturan/status_aplikasi`) ditulis secara langsung di dalam kelas. Ini menyederhanakan implementasi tetapi berarti layanan ini terikat erat dengan struktur database yang telah ditentukan.
-   **Testability**: Tidak seperti layanan lain yang menggunakan *dependency injection*, kelas ini membuat instans `CollectionReference` sendiri. Hal ini membuatnya lebih sulit untuk diuji dalam isolasi (*unit test*) karena pengujian akan selalu mencoba terhubung ke Firestore sungguhan. Pengujian untuk kelas ini lebih cocok dilakukan dengan *integration test*.

## Struktur Data di Firestore
Layanan ini bergantung pada struktur berikut di dalam Cloud Firestore:
-   **Koleksi**: `pengaturan`
-   **Dokumen**: `status_aplikasi`
-   **Field di dalam dokumen**:
    -   `sedang_maintenance` (tipe: `Boolean`): Nilai `true` berarti mode maintenance aktif.
    -   `diperbarui` (tipe: `Timestamp`): Waktu kapan status terakhir kali diubah.

## Metode Utama

### `Future<bool> dapatkanStatusMaintenance()`
Metode ini digunakan oleh aplikasi klien (pengguna) setiap kali aplikasi dimulai.
1.  **Tujuan**: Untuk mengetahui apakah aplikasi harus masuk ke mode maintenance.
2.  **Proses**:
    a.  Mencoba mengambil dokumen `pengaturan/status_aplikasi` dari Firestore.
    b.  Jika dokumen ada dan berisi field `sedang_maintenance`, metode akan mengembalikan nilai boolean dari field tersebut.
    c.  **Fail-Safe**: Jika dokumen tidak ada, field tidak ada, atau terjadi error koneksi, metode ini akan selalu mengembalikan `false`. Ini adalah perilaku aman yang memastikan aplikasi tetap dapat diakses jika konfigurasi di server salah atau tidak dapat dijangkau.
3.  **Output**: `true` jika maintenance, `false` jika tidak.

### `Future<void> aturStatusMaintenance(bool status)`
Metode ini ditujukan untuk digunakan di aplikasi admin.
1.  **Tujuan**: Untuk mengubah status maintenance aplikasi bagi semua pengguna.
2.  **Proses**:
    a.  Mengambil nilai `bool` baru sebagai parameter (`status`).
    b.  Menggunakan `set` dengan `SetOptions(merge: true)` pada dokumen `pengaturan/status_aplikasi`.
        -   `merge: true` penting agar tidak menimpa field lain yang mungkin ada di dokumen tersebut.
    c.  Menyimpan dua field: `sedang_maintenance` dengan nilai `status` baru, dan `diperbarui` dengan `FieldValue.serverTimestamp()` untuk mencatat waktu perubahan.
3.  **Penanganan Error**: Jika terjadi error (misalnya, karena aturan keamanan Firestore atau masalah jaringan), metode ini akan melempar kembali error tersebut (`rethrow`). Ini memungkinkan UI di aplikasi admin untuk menangkap kegagalan dan memberikan umpan balik (misalnya, "Gagal mengubah status, coba lagi.").

## Contoh Alur Penggunaan

1.  **Admin Mengaktifkan Maintenance**:
    -   Admin di aplikasi admin menekan tombol "Aktifkan Maintenance".
    -   UI memanggil `await KontrolAplikasiService().aturStatusMaintenance(true);`.
    -   Firestore diperbarui: `pengaturan/status_aplikasi` -> `{ sedang_maintenance: true, ... }`.

2.  **Pengguna Membuka Aplikasi**:
    -   Aplikasi pengguna baru saja dibuka.
    -   Di layar splash atau halaman utama, kode memanggil `bool isMaintenance = await KontrolAplikasiService().dapatkanStatusMaintenance();`.
    -   Hasilnya adalah `true`.
    -   Aplikasi kemudian menampilkan halaman penuh yang bertuliskan "Aplikasi sedang dalam perbaikan. Silakan coba lagi nanti." dan menghentikan semua fungsionalitas lainnya.

3.  **Admin Menonaktifkan Maintenance**:
    -   Admin menekan tombol "Nonaktifkan Maintenance".
    -   UI memanggil `await KontrolAplikasiService().aturStatusMaintenance(false);`.
    -   Firestore diperbarui: `pengaturan/status_aplikasi` -> `{ sedang_maintenance: false, ... }`.
    -   Saat pengguna membuka aplikasi lagi, `dapatkanStatusMaintenance()` akan mengembalikan `false`, dan aplikasi akan berjalan normal.

Dokumentasi ini menggarisbawahi peran `KontrolAplikasiService` sebagai alat administratif yang kuat dan sederhana untuk mengelola keadaan aplikasi secara global dan real-time.

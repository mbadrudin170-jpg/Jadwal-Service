
# Dokumentasi: ExpiredSubscriptionCheckService

## Lokasi File
`lib/shared/services/expired_subscription_check_service.dart`

## Ringkasan
`ExpiredSubscriptionCheckService` adalah kelas layanan (*service*) yang memiliki satu tugas penting: memeriksa dan menangani pelanggan yang masa langganannya telah habis (kedaluwarsa).

Layanan ini tidak berjalan secara terus-menerus, melainkan dipanggil secara periodik (misalnya, setiap kali aplikasi dibuka atau sekali sehari) untuk membersihkan data pelanggan aktif. Tugas utamanya adalah mendelegasikan proses pengarsipan ke `ActiveCustomerOperation`.

## Arsitektur dan Ketergantungan
-   **ActiveCustomerOperation**: Layanan ini sangat bergantung pada `ActiveCustomerOperation`. Ia tidak melakukan logika database sendiri, melainkan memanggil metode `archiveExpiredCustomers()` dari `ActiveCustomerOperation` untuk melakukan pekerjaan beratnya.
-   **Pemisahan Tanggung Jawab**: Desain ini mencerminkan prinsip pemisahan tanggung jawab yang baik. `ExpiredSubscriptionCheckService` bertindak sebagai **pemicu** atau **koordinator**, sementara `ActiveCustomerOperation` bertanggung jawab atas **eksekusi** logika bisnis dan interaksi database.

## Metode Utama

### `Future<void> processExpiredSubscriptions()`
Ini adalah satu-satunya metode publik dalam layanan ini. Ketika dipanggil, metode ini akan:
1.  Mencatat (log) bahwa proses pengecekan dimulai.
2.  Memanggil metode `_activeCustomerOperation.archiveExpiredCustomers()`.
3.  Menunggu hasil dari operasi tersebut, yang mengembalikan jumlah pelanggan yang berhasil diarsipkan.
4.  Mencatat hasilnya, baik itu jumlah data yang diarsipkan maupun informasi jika tidak ada data yang kedaluwarsa.
5.  Menangani dan mencatat jika terjadi kesalahan selama proses berlangsung.

## Cara Kerja
1.  **Inisialisasi**: Sebuah instance dari `ExpiredSubscriptionCheckService` dibuat di suatu tempat di aplikasi (misalnya, di level atas atau melalui *dependency injection*).
2.  **Pemicu**: Logika di aplikasi (misalnya, di `main.dart` atau `home_page.dart`) akan memanggil `processExpiredSubscriptions()` pada waktu yang ditentukan (contoh: saat aplikasi pertama kali dimuat setelah beberapa jam tidak aktif).
3.  **Delegasi**: `processExpiredSubscriptions()` segera mendelegasikan tugas ke `ActiveCustomerOperation.archiveExpiredCustomers()`.
4.  **Eksekusi di `ActiveCustomerOperation`**: Metode `archiveExpiredCustomers()` akan:
    a.  Mengambil semua data dari tabel `active_customers`.
    b.  Memfilter data tersebut untuk menemukan pelanggan yang `endDate` nya sudah lewat dari `DateTime.now()`.
    c.  Memindahkan data yang sudah kedaluwarsa dari tabel `active_customers` ke tabel `archived_customers` (atau hanya mengubah statusnya).
    d.  Mengembalikan jumlah data yang berhasil dipindahkan.
5.  **Logging**: `ExpiredSubscriptionCheckService` menerima kembali jumlah tersebut dan mencatatnya sebagai bukti bahwa proses telah selesai.

## Tujuan Desain
-   **Terpusat**: Semua logika untuk *memicu* pengecekan langganan kedaluwarsa berada di satu tempat.
-   **Dapat Diuji (Testable)**: Dengan adanya *setter* `activeCustomerOperation`, kita bisa dengan mudah mengganti `ActiveCustomerOperation` asli dengan *mock* atau *fake* saat melakukan *unit testing*.
-   **Jelas dan Sederhana**: Kode di dalam service ini sangat mudah dibaca dan dipahami, karena hanya berfokus pada koordinasi dan logging, bukan pada detail implementasi database.

## Contoh Pemanggilan
```dart
// Di suatu tempat di aplikasi, misalnya saat startup

final subscriptionChecker = ExpiredSubscriptionCheckService();

// Panggil untuk memulai proses. Proses ini berjalan di latar belakang (asynchronous).
unawaited(subscriptionChecker.processExpiredSubscriptions());

// UI bisa terus berjalan tanpa harus menunggu proses ini selesai.
```

Dokumentasi ini menjelaskan peran `ExpiredSubscriptionCheckService` sebagai pengelola siklus hidup langganan pelanggan, memastikan data pelanggan aktif selalu akurat dan relevan.

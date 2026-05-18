# Dokumentasi: `lib/shared/services/expired_subscription_check_service.dart`

`ExpiredSubscriptionCheckService` adalah kelas di lapisan servis (*service layer*) yang bertanggung jawab untuk mengotomatiskan tugas pemeliharaan data penting: menemukan dan mengarsipkan langganan pelanggan yang sudah kedaluwarsa.

---

## Tujuan dan Konsep

Seiring waktu, tabel `active_customers` (pelanggan aktif) akan berisi data langganan yang sudah lewat tanggal berlakunya. Membiarkan data ini menumpuk dapat menyebabkan beberapa masalah:

1.  **Penurunan Performa**: Kueri pada tabel `active_customers` menjadi lebih lambat karena harus memindai data yang tidak lagi relevan.
2.  **Ketidakakuratan Data**: Daftar pelanggan aktif yang dilihat admin menjadi "kotor" karena tercampur dengan langganan yang sudah tidak valid.

Layanan ini bertindak sebagai "petugas kebersihan" otomatis yang secara proaktif menjalankan proses pengarsipan.

---

## Desain dan Arsitektur

Arsitektur kelas ini menunjukkan beberapa praktik terbaik:

-   **Pola Delegasi (Delegation Pattern)**: Ini adalah aspek desain yang paling penting. `ExpiredSubscriptionCheckService` **tidak** melakukan logika database sendiri. Sebaliknya, ia mendelegasikan seluruh pekerjaan berat ke `ActiveCustomerOperation.archiveExpiredCustomers()`. 

-   **Pemisahan Tanggung Jawab (Separation of Concerns)**:
    -   **Service (`ExpiredSubscriptionCheckService`)**: Bertanggung jawab atas "kapan" dan "apa" tugas yang harus dijalankan. Ia bertindak sebagai koordinator tingkat tinggi, mengelola alur proses, dan melakukan logging untuk keseluruhan tugas.
    -   **Operation (`ActiveCustomerOperation`)**: Bertanggung jawab atas "bagaimana" tugas itu dieksekusi. Ia berisi logika SQL yang sebenarnya untuk memilih pelanggan kedaluwarsa, menyalinnya ke tabel arsip, dan menghapusnya dari tabel aktif.

-   **Dependency Injection untuk Pengujian**: Kelas ini memiliki *setter* `set activeCustomerOperation` yang ditandai dengan `@visibleForTesting`. Ini adalah pola *Dependency Injection* manual yang memungkinkan kita dalam pengujian unit untuk mengganti `ActiveCustomerOperation` yang sebenarnya dengan versi *mock* (palsu). Dengan demikian, kita dapat menguji logika `ExpiredSubscriptionCheckService` (misalnya, apakah ia memanggil metode yang benar dan melakukan logging dengan tepat) tanpa perlu bergantung pada database sungguhan.

---

## Metode Utama: `processExpiredSubscriptions()`

Ini adalah satu-satunya metode publik dan merupakan titik masuk untuk layanan ini. Alur kerjanya sederhana dan kuat:

1.  **Mulai & Log**: Mencatat log bahwa proses pengecekan dimulai. Ini penting untuk melacak kapan tugas ini berjalan.
2.  **Panggil & Tunggu**: Memanggil `_activeCustomerOperation.archiveExpiredCustomers()` dan menunggu hasilnya. Hasilnya adalah jumlah (`int`) pelanggan yang berhasil diarsipkan.
3.  **Log Hasil**: 
    -   Jika `archivedCount > 0`, ia mencatat pesan sukses yang informatif, memberitahukan berapa banyak data yang dipindahkan.
    -   Jika `archivedCount == 0`, ia mencatat bahwa tidak ada pekerjaan yang perlu dilakukan. Ini juga merupakan informasi yang berguna.
4.  **Tangani Error**: Seluruh proses dibungkus dalam `try-catch`. Jika terjadi kesalahan apa pun di dalam `ActiveCustomerOperation` (misalnya, error database), `catch` akan menangkapnya dan mencatatnya sebagai `Log.error()`. Ini mencegah aplikasi dari *crash* dan memastikan bahwa setiap kegagalan dalam tugas latar belakang ini akan tercatat.

---

## Integrasi dan Penggunaan

Kelas layanan seperti ini biasanya tidak dipanggil langsung oleh interaksi pengguna di UI. Sebaliknya, ia dirancang untuk dijalankan secara otomatis pada waktu-waktu tertentu, seperti:

-   **Saat Aplikasi Dimulai**: Memanggil `processExpiredSubscriptions()` saat aplikasi (khususnya aplikasi Admin) pertama kali dibuka.
-   **Secara Berkala**: Menggunakan `Timer.periodic` untuk menjalankan layanan ini setiap beberapa jam sekali saat aplikasi sedang berjalan.
-   **Melalui Tugas Latar Belakang (Background Task)**: Pada platform yang mendukung, ini dapat dijadwalkan untuk berjalan bahkan saat aplikasi tidak aktif.

Dengan cara ini, pemeliharaan data terjadi secara otomatis tanpa memerlukan intervensi manual dari admin.

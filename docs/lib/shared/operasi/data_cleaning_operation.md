# Dokumentasi: `lib/shared/operasi/data_cleaning_operation.dart`

`DataCleaningOperation` adalah kelas utilitas dengan satu tujuan spesifik dan penting: **membersihkan data lama dari database lokal secara permanen.**

---

## Konsep dan Tujuan

Seiring waktu, database aplikasi akan terus membengkak karena data-data yang diarsipkan (di-*soft delete*). Data arsip ini termasuk pelanggan yang sudah tidak aktif, transaksi lama, kategori yang tidak digunakan lagi, dan sebagainya. Meskipun data ini tidak lagi ditampilkan di UI utama, keberadaannya tetap memakan ruang penyimpanan dan dapat memperlambat query database secara keseluruhan.

`DataCleaningOperation` bertugas untuk menjalankan proses pembersihan ini secara teratur untuk menjaga agar database tetap ramping dan performanya optimal.

---

## Metode Utama

### `deleteAllExpiredArchivedData({required int retentionDays})`

Ini adalah satu-satunya metode publik di dalam kelas ini, dan ia melakukan semua tugas berat.

-   **Parameter**: Menerima `retentionDays`, yaitu jumlah hari retensi. Data arsip yang lebih tua dari jumlah hari ini akan dihapus.

-   **Proses**: Metode ini bekerja dengan cara berikut:
    1.  **Menentukan Daftar Tabel**: Sebuah daftar tabel yang relevan untuk pembersihan telah ditentukan secara *hardcoded*. Ini mencakup hampir semua tabel yang memiliki kolom `archivedAt`.
    2.  **Menghitung Batas Waktu**: Menghitung tanggal dan waktu batas (`timeLimit`) berdasarkan `retentionDays`. Misalnya, jika `retentionDays` adalah 90, maka semua data yang diarsipkan lebih dari 90 hari yang lalu akan menjadi target penghapusan.
    3.  **Menggunakan Operasi Batch**: Untuk efisiensi maksimum, proses penghapusan dilakukan dalam satu **operasi batch** atomik. Ini berarti semua perintah `DELETE` untuk semua tabel dikumpulkan dan dijalankan sekaligus dalam satu transaksi tunggal. Keuntungannya adalah:
        -   **Kecepatan**: Jauh lebih cepat daripada menjalankan banyak perintah `DELETE` satu per satu.
        -   **Atomisitas**: Jika terjadi error di tengah-tengah proses, seluruh operasi batch akan dibatalkan (*rollback*), sehingga database tidak akan berada dalam kondisi setengah terhapus.
    4.  **Eksekusi Query**: Untuk setiap tabel dalam daftar, ia menjalankan query SQL `DELETE FROM [tabel] WHERE archivedAt IS NOT NULL AND archivedAt <= ?`.
    5.  **Melaporkan Hasil**: Metode ini mengembalikan jumlah total baris yang berhasil dihapus dari semua tabel, memberikan feedback yang berguna tentang berapa banyak data yang telah dibersihkan.

---

## Penggunaan

Kelas `DataCleaningOperation` ini tidak dipanggil secara langsung dari UI. Sebaliknya, ia digunakan oleh `DataCleaningService`, sebuah layanan latar belakang (*background service*) yang berjalan secara periodik (misalnya, setiap beberapa hari sekali) untuk secara otomatis melakukan pembersihan tanpa intervensi pengguna.

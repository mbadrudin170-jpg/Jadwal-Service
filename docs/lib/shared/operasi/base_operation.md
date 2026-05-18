# Dokumentasi: `lib/shared/operasi/base_operation.dart`

`BaseOperation` adalah kelas dasar yang berfungsi sebagai pusat kontrol untuk **semua operasi tulis** (Create, Update, Delete) ke database lokal SQLite. Perannya adalah untuk memastikan integritas data melalui transaksi dan mengelola status sinkronisasi unggah secara terpusat.

Setiap kelas operasi lain (seperti `CustomerOperation`, `TransactionOperation`, dll.) akan mewarisi atau menggunakan kelas ini untuk berinteraksi dengan database, sehingga semua logika penting (transaksi dan penandaan unggah) tidak perlu ditulis berulang kali.

---

## Konsep Inti

### 1. Pembungkus Transaksi (`_runInTransaction`)

Semua operasi tulis (insert, update, delete) wajib dijalankan di dalam sebuah **transaksi database**. Ini adalah mekanisme pengaman yang krusial.

-   **Atomisitas**: Transaksi memastikan bahwa serangkaian aksi database bersifat "semua atau tidak sama sekali". Jika salah satu aksi di dalam transaksi gagal, semua aksi yang sudah terjadi akan dibatalkan (*rollback*). Ini mencegah kondisi di mana data hanya diperbarui sebagian, yang bisa menyebabkan inkonsistensi.
-   **Contoh**: Jika proses pembaruan pelanggan melibatkan update di dua tabel berbeda, transaksi memastikan kedua tabel berhasil di-update. Jika update kedua gagal, update pertama akan dibatalkan.

### 2. Penandaan Sinkronisasi Unggah (`fromServer`)

Fitur paling penting dari `BaseOperation` adalah kemampuannya untuk secara otomatis menandai bahwa ada data yang perlu diunggah ke server.

-   **Operasi Lokal**: Secara default, setiap operasi tulis dianggap berasal dari input pengguna lokal. Oleh karena itu, `BaseOperation` akan secara otomatis memanggil `UploadStatusOperation.setNeedUpload(true)`. Ini memberitahu sistem bahwa ada perubahan di database lokal yang harus segera diunggah ke Firestore saat koneksi tersedia.

-   **Operasi dari Server (`fromServer: true`)**: Ketika aplikasi mengunduh data dari Firestore (misalnya, saat sinkronisasi awal), data tersebut juga ditulis ke database lokal SQLite. Dalam kasus ini, kita tidak ingin memicu unggahan kembali. Parameter `fromServer: true` digunakan untuk memberitahu `BaseOperation` agar **melewatkan** proses penandaan `needUpload`. Ini memutus siklus sinkronisasi yang tidak perlu (unduh -> simpan lokal -> tandai untuk unggah -> unggah data yang sama).

---

## Metode Utama

-   `_runInTransaction<T>(action, {fromServer})`: Metode inti privat yang membungkus semua logika. Ia memulai transaksi, memanggil penanda `needUpload` jika perlu, dan kemudian mengeksekusi aksi (`action`) yang diberikan.

-   `insert(table, data, {fromServer})`: Menyisipkan satu baris `data` ke dalam `table`. Menggunakan `ConflictAlgorithm.replace` untuk menimpa data jika ID sudah ada (berfungsi sebagai *upsert*).

-   `update(table, data, id, {fromServer})`: Memperbarui baris data di `table` di mana `id` cocok.

-   `delete(table, id, {fromServer})`: Menghapus baris data dari `table` di mana `id` cocok.

-   `insertOrUpdateBatch(table, dataList, {fromServer})`: Untuk efisiensi, metode ini menyisipkan atau memperbarui daftar `dataList` dalam satu operasi *batch*. Ini jauh lebih cepat daripada melakukan banyak `insert` satu per satu.

-   `runComplexOperation<T>(customAction, {fromServer})`: Sebuah "pintu darurat" untuk operasi yang lebih kompleks. Metode ini memungkinkan kelas lain untuk menjalankan blok kode kustom (`customAction`) di dalam sebuah transaksi yang dikelola oleh `BaseOperation`, sehingga tetap mendapatkan jaminan atomisitas dan penandaan unggah.

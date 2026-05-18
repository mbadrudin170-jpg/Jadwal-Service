# Dokumentasi: `lib/shared/operasi/customer_operation.dart`

`CustomerOperation` adalah kelas yang mengelola semua operasi CRUD (Create, Read, Update, Delete) untuk entitas `CustomerModel` di database lokal SQLite. Kelas ini menjadi tulang punggung untuk semua interaksi yang berkaitan dengan data master pelanggan.

---

## Peran dan Tanggung Jawab

-   **Manajemen Data Master Pelanggan**: Menyediakan fungsi untuk menambah, membaca, memperbarui, dan menghapus data pelanggan.
-   **Sinkronisasi**: Memastikan setiap perubahan data pelanggan yang dilakukan secara lokal dapat diunggah ke server Firestore.
-   **Manajemen Status**: Mengelola status pelanggan, seperti apakah pelanggan tersebut aktif, dihapus (*soft delete*), atau diarsipkan.

---

## Metode Utama

### Operasi Tulis (Write)

-   `createCustomer(customer, {fromServer})`: Menyimpan pelanggan baru ke database lokal. Setiap pelanggan baru akan diberi `updatedAt` saat ini.

-   `updateCustomer(customer, {fromServer})`: Memperbarui data pelanggan yang sudah ada di database.

-   `archiveCustomer(id, {fromServer})`: Melakukan *soft delete* dengan mengatur flag `isDeleted = true` dan mengisi `archivedAt`. Pelanggan yang diarsipkan tidak akan muncul di daftar pelanggan aktif.

-   `deleteCustomer(id, {softDelete, fromServer})`: Menghapus data pelanggan. Memiliki dua mode:
    -   `softDelete = true` (default): Hanya akan memperbarui status `isDeleted` menjadi 1 (true). Data tetap ada di database tetapi tidak ditampilkan.
    -   `softDelete = false`: Melakukan **hard delete**, yaitu menghapus data pelanggan secara permanen dari database lokal.

-   `insertOrUpdateBatch(items, {fromServer})`: Metode yang sangat penting untuk sinkronisasi. Metode ini dapat menyisipkan atau memperbarui daftar pelanggan dalam jumlah besar secara efisien dalam satu operasi *batch*.

### Operasi Baca (Read)

-   `getCustomers()`: Mengambil daftar semua pelanggan yang **aktif**. Artinya, pelanggan yang tidak diarsipkan (`archivedAt IS NULL`) dan tidak dihapus (`isDeleted = false`). Ini adalah metode yang paling sering digunakan untuk menampilkan daftar pelanggan kepada pengguna.

-   `getAllCustomers()`: Mengambil **semua** data pelanggan dari database, termasuk yang sudah diarsipkan atau dihapus. Biasanya digunakan untuk keperluan audit atau proses sinkronisasi.

-   `getCustomerById(id)`: Mengambil satu data pelanggan spesifik berdasarkan ID-nya.

-   `getCustomersByIds(ids)`: Mengambil beberapa pelanggan sekaligus berdasarkan daftar ID yang diberikan. Ini lebih efisien daripada memanggil `getCustomerById` berulang kali dalam sebuah loop.

-   `getChangesSince(since)`: Digunakan oleh mekanisme sinkronisasi untuk mendapatkan daftar pelanggan yang telah dibuat atau diubah sejak terakhir kali sinkronisasi berhasil dilakukan. Ini mengurangi jumlah data yang perlu diunggah.

---

## Interaksi dengan `BaseOperation`

`CustomerOperation` sangat bergantung pada `BaseOperation`. Setiap kali ada operasi tulis (`create`, `update`, `archive`, `delete`), `CustomerOperation` akan memanggil metode yang sesuai di `BaseOperation`. Dengan cara ini, semua perubahan secara otomatis dibungkus dalam transaksi database dan ditandai (`needUpload = true`) untuk sinkronisasi ke server, kecuali jika operasi tersebut berasal dari server itu sendiri (`fromServer = true`).

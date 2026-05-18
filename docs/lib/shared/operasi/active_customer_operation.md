# Dokumentasi: `lib/shared/operasi/active_customer_operation.dart`

`ActiveCustomerOperation` adalah kelas yang bertanggung jawab untuk semua operasi CRUD (Create, Read, Update, Delete) yang terkait dengan `ActiveCustomerModel` di database lokal SQLite. Kelas ini secara khusus mengelola data pelanggan yang memiliki langganan paket internet yang sedang berjalan.

---

## Peran dan Tanggung Jawab Utama

1.  **Mengelola Siklus Hidup Pelanggan Aktif**: Dari mulai membuat data pelanggan aktif baru, memperbaruinya, hingga mengarsipkannya saat masa aktif berakhir.

2.  **Menjadwalkan Notifikasi**: Salah satu tanggung jawab utamanya adalah menjadwalkan notifikasi pengingat kepada pengguna (admin) sebelum masa aktif paket pelanggan berakhir. Ini membantu admin untuk proaktif menindaklanjuti pelanggan.

3.  **Manajemen Arsip**: Kelas ini memiliki logika untuk mengarsipkan pelanggan secara otomatis ketika paket mereka telah kedaluwarsa dan juga menghapus data arsip yang sudah terlalu lama untuk menjaga kebersihan database.

---

## Metode Penting

### `createActiveCustomer(model, {fromServer})`
-   Menyimpan `ActiveCustomerModel` baru ke database.
-   Menggunakan `BaseOperation` untuk memastikan operasi ini berjalan dalam transaksi dan menandai status `needUpload`.
-   Setelah berhasil menyimpan, metode ini memanggil `_scheduleNotification` untuk menjadwalkan notifikasi pengingat masa berakhir paket.

### `updateActiveCustomer(model, {fromServer})`
-   Memperbarui data `ActiveCustomerModel` yang sudah ada.
-   Sama seperti `create`, ini juga memanggil `_scheduleNotification` untuk menjadwal ulang notifikasi (jika misalnya tanggal berakhirnya diubah).

### `_scheduleNotification(activeCustomer)`
-   Metode internal yang sangat penting.
-   Pertama, ia **membatalkan semua notifikasi lama** yang mungkin sudah ada untuk pelanggan tersebut untuk mencegah notifikasi duplikat atau salah.
-   Kemudian, ia **menjadwalkan notifikasi baru** pada:
    -   H-3 (3 hari sebelum berakhir)
    -   H-1 (1 hari sebelum berakhir)
    -   Tepat pada saat masa aktif berakhir.
-   Ini memastikan admin mendapatkan pengingat yang cukup untuk menghubungi pelanggan.

### `archiveActiveCustomer(id, {fromServer})`
-   Melakukan *soft delete* dengan mengatur flag `isDeleted` menjadi `true` dan mencatat `archivedAt`.
-   Saat pelanggan diarsipkan, semua notifikasi terjadwal untuknya akan **dibatalkan** untuk mencegah pengingat yang tidak relevan.

### `archiveExpiredCustomers()`
-   Metode pemeliharaan otomatis.
-   Mencari semua pelanggan aktif yang `endDate`-nya sudah lewat dari waktu sekarang.
-   Memanggil `archiveActiveCustomer` untuk setiap pelanggan yang ditemukan.
-   Biasanya dijalankan secara berkala oleh sebuah *background service*.

### `permanentlyDeleteArchivedCustomers()`
-   Metode pemeliharaan otomatis lainnya.
-   Mencari data pelanggan yang sudah diarsipkan (`archivedAt`) lebih dari 30 hari.
-   **Menghapus permanen** data tersebut dari database untuk menghemat ruang dan menjaga performa.

### Operasi Baca
-   `getAllActiveCustomers()`: Mengambil semua pelanggan yang masih aktif (belum diarsipkan).
-   `getActiveCustomerById(id)`: Mengambil satu pelanggan aktif berdasarkan ID-nya.
-   `getActiveCustomersByIds(ids)`: Mengambil beberapa pelanggan aktif berdasarkan daftar ID.

---

## Interaksi dengan `BaseOperation`

Semua metode yang melakukan perubahan data (`create`, `update`, `archive`, dll.) mendelegasikan eksekusinya ke `BaseOperation`. Ini memastikan bahwa setiap perubahan data secara otomatis ditandai untuk diunggah ke server, menjaga konsistensi data antara lokal dan Firestore.

# Dokumentasi: `lib/shared/operasi/order_operation.dart`

`OrderOperation` adalah kelas yang bertanggung jawab untuk mengelola data `OrderModel` di database lokal. `OrderModel` merepresentasikan pesanan atau permintaan yang dibuat oleh pelanggan, yang bisa berupa permintaan pemasangan baru, perbaikan, atau layanan lainnya.

---

## Konsep dan Alur Kerja

1.  **Pembuatan Pesanan**: Pelanggan (atau admin atas nama pelanggan) membuat pesanan baru. Pesanan ini berisi informasi tentang pelanggan, jenis layanan yang diminta, dan detail lainnya.

2.  **Penyimpanan Awal**: Pesanan disimpan di database lokal di perangkat yang membuatnya (bisa perangkat admin atau klien) dan juga dikirim ke Firestore.

3.  **Sinkronisasi**: Perangkat admin lain akan menerima data pesanan baru ini melalui proses sinkronisasi dan menyimpannya ke database lokal mereka menggunakan `OrderOperation`.

4.  **Manajemen Status**: Admin menggunakan aplikasi mereka untuk melacak dan memperbarui status pesanan, misalnya dari "Baru" menjadi "Dalam Proses", lalu "Selesai" atau "Dibatalkan". Setiap pembaruan status juga akan disinkronkan ke semua perangkat.

---

## Metode Utama

### Operasi Tulis (Write)

-   `saveOrder(order, {fromServer})`: Menyimpan pesanan baru ke dalam database lokal. Ini adalah alias dari `create`.

-   `updateOrderStatus(id, status, {fromServer})`: **Metode yang sangat penting**. Metode ini tidak hanya memperbarui kolom status, tetapi juga mengambil model pesanan yang ada terlebih dahulu, lalu membuat salinan (`copyWith`) dengan status baru dan `updatedAt` yang diperbarui. Ini memastikan bahwa `updatedAt` selalu mencerminkan waktu perubahan terakhir, yang krusial untuk proses sinkronisasi.

-   `deleteOrder(id, {fromServer})`: Melakukan **hard delete** pada pesanan. Biasanya digunakan untuk menghapus pesanan yang salah dibuat atau dibatalkan secara permanen.

-   `insertOrUpdateBatch(items, {fromServer})`: Metode efisien untuk menyisipkan atau memperbarui banyak data pesanan sekaligus. Ini adalah tulang punggung dari proses sinkronisasi data pesanan dari server.

### Operasi Baca (Read)

-   `getAllOrders()`: Mengambil semua pesanan dari database, diurutkan dari yang paling baru, tanpa memandang statusnya.

-   `getOrdersByStatus(status)`: Mengambil dan menampilkan daftar pesanan berdasarkan status spesifik mereka (misalnya, tampilkan semua pesanan yang masih "Baru"). Ini membantu admin untuk fokus pada pekerjaan yang perlu ditindaklanjuti.

-   `getOrdersByIds(ids)`: Mengambil beberapa data pesanan secara efisien berdasarkan daftar ID.

---

## Interaksi dengan `BaseOperation`

Setiap operasi yang mengubah data (`saveOrder`, `updateOrderStatus`, `deleteOrder`, `insertOrUpdateBatch`) didelegasikan ke `BaseOperation`. Ini memastikan bahwa setiap perubahan yang dilakukan oleh admin (misalnya, mengubah status pesanan menjadi "Selesai") akan ditandai untuk diunggah ke Firestore. Dengan demikian, semua admin lain akan melihat status pesanan yang terbaru, memastikan tidak ada pekerjaan ganda atau informasi yang ketinggalan.

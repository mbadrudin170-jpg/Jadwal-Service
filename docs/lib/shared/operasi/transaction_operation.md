# Dokumentasi: `lib/shared/operasi/transaction_operation.dart`

`TransactionOperation` adalah kelas paling vital dan kompleks dalam aplikasi ini. Ia bertanggung jawab penuh atas pengelolaan `TransactionModel`, yang merupakan representasi dari setiap pergerakan finansial dan operasional yang terjadi, seperti pembayaran tagihan, pengeluaran operasional, transfer antar dompet, dan aktivasi paket.

---

## Konsep Inti: Integritas Data dan Keterhubungan

-   **Menghitung Ulang Saldo Dompet (`_recalculateAndUpdateWalletBalance`)**: Ini adalah metode *private* yang menjadi jantung dari kelas ini. Setiap kali sebuah transaksi dibuat, diubah, atau dihapus, metode ini dipanggil untuk menghitung ulang total saldo dari dompet yang terpengaruh. Ia melakukannya dengan menjalankan `SUM` pada semua transaksi terkait (termasuk pemasukan, pengeluaran, dan transfer) dan kemudian memperbarui nilai `balance` di tabel `wallet`. Ini memastikan bahwa saldo dompet **selalu akurat dan konsisten** dengan riwayat transaksinya.

-   **Operasi Atomik (`runComplexOperation`)**: Hampir semua metode tulis (seperti `addTransaction`, `updateTransaction`, `archiveTransaction`, `insertOrUpdateBatch`) dibungkus dalam `_baseOperation.runComplexOperation`. Ini menjalankan serangkaian perintah database di dalam satu transaksi atomik. Artinya, jika ada satu bagian dari proses yang gagal (misalnya, gagal memperbarui saldo dompet setelah transaksi dibuat), seluruh operasi akan dibatalkan (*rollback*). Ini mencegah kondisi data yang tidak konsisten (misalnya, transaksi tercatat tapi saldo tidak berubah).

-   **Keterhubungan Model**: Sebuah `TransactionModel` dapat terhubung dengan berbagai model lain:
    -   `WalletModel`: Setiap transaksi (kecuali transfer masuk) memiliki `walletId`.
    -   `CustomerModel`: Transaksi pembayaran tagihan memiliki `customerId`.
    -   `PackageModel`: Transaksi pembelian paket memiliki `packageId`.
    -   `CategoryModel` dan `SubCategoryModel`: Transaksi pengeluaran memiliki `categoryId` dan `subCategoryId`.

---

## Metode Utama

### Operasi Tulis (Write)

-   `addTransaction(transaction, {fromServer})`: Menambahkan transaksi baru. Prosesnya: 1) Menyisipkan data transaksi. 2) Memanggil `_recalculateAndUpdateWalletBalance` untuk dompet sumber (dan dompet tujuan jika ini adalah transfer).

-   `updateTransaction(id, newTransaction, {fromServer})`: Memperbarui transaksi. Prosesnya lebih kompleks: 1) Mengambil data transaksi lama dan baru. 2) Mengidentifikasi semua dompet yang terpengaruh (dompet lama, dompet baru, dompet tujuan lama, dompet tujuan baru). 3) Menjalankan `_recalculateAndUpdateWalletBalance` untuk **setiap** dompet yang terpengaruh untuk memastikan semua saldo benar.

-   `archiveTransaction(id, {fromServer})`: Melakukan *soft delete*. Prosesnya: 1) Menandai `isDeleted = 1`. 2) Memanggil `_recalculateAndUpdateWalletBalance` agar saldo dompet disesuaikan kembali seolah-olah transaksi tersebut tidak pernah terjadi.

-   `archiveAllTransactions({fromServer})`: Melakukan *soft delete* pada **semua** transaksi dan kemudian mengatur ulang saldo **semua** dompet menjadi 0. Operasi yang sangat destruktif.

-   `insertOrUpdateBatch(items, {fromServer})`: Metode sinkronisasi utama. Prosesnya: 1) Menyisipkan/memperbarui semua transaksi dalam satu *batch*. 2) Mengumpulkan `Set` unik dari semua `walletId` yang terpengaruh. 3) Melakukan iterasi pada `Set` tersebut dan memanggil `_recalculateAndUpdateWalletBalance` untuk setiap dompet.

### Operasi Baca (Read)

-   `getAllTransactions()`: Mengambil semua transaksi aktif.

-   `getTransactionById(id)`: Mengambil satu transaksi.

-   `getLatestPaidTransactionByUserId(customerId)`: Metode penting untuk mengecek status langganan pelanggan. Ia mencari transaksi pembayaran **terbaru** dari seorang pelanggan yang sudah lunas (`status_pembayaran = 'lunas'`) dan diurutkan berdasarkan tanggal kedaluwarsa (`tanggal_akhir DESC`). Hasil dari metode ini digunakan untuk menentukan apakah langganan pelanggan tersebut masih aktif.

-   `getTransactionsByCustomerId(customerId)`: Mengambil riwayat transaksi seorang pelanggan.

-   `getTransactionsByWalletId(walletId)`: Mengambil riwayat transaksi sebuah dompet.

### Metode Agregasi

-   `getTotalIncome()`, `getTotalExpense()`, `getNetTotal()`: Menghitung total pemasukan, pengeluaran, dan pendapatan bersih dari semua transaksi.

-   `getEarnedPoints()`, `getUsedPoints()`, `getTotalPoints(customerId)`: Menghitung total akumulasi, penggunaan, dan sisa poin untuk seorang pelanggan.

---

## Kesimpulan

`TransactionOperation` adalah pilar dari logika bisnis aplikasi. Melalui penggunaan transaksi database yang ketat dan mekanisme penghitungan ulang saldo yang andal, kelas ini menjamin integritas dan akurasi data finansial di seluruh sistem.

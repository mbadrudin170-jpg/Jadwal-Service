# Dokumentasi: `lib/shared/operasi/wallet_operation.dart`

`WalletOperation` adalah kelas yang didedikasikan untuk mengelola `WalletModel` di database lokal. Dalam ekosistem aplikasi ini, dompet (`WalletModel`) adalah entitas fundamental yang merepresentasikan tempat penyimpanan uang, baik itu kas fisik, rekening bank, atau dompet digital.

---

## Peran dan Konsep Kunci

-   **Pusat Arus Kas**: Setiap transaksi finansial, baik itu pemasukan (pembayaran dari pelanggan) maupun pengeluaran (biaya operasional), selalu terhubung ke sebuah dompet. Dompet inilah yang mencatat perubahan saldo akibat transaksi-transaksi tersebut.

-   **Saldo yang Dihitung, Bukan Disimpan Langsung**: Perlu dicatat bahwa `WalletOperation` sendiri **tidak** menghitung atau mengubah saldo dompet. Metode seperti `createWallet` atau `updateWallet` hanya menyimpan atau mengubah data atribut dompet (seperti nama, ikon, atau status arsip). Perhitungan saldo yang sebenarnya terjadi di dalam `TransactionOperation`, yang kemudian akan memperbarui field `balance` di tabel `wallet`. `WalletOperation` hanya menyediakan metode untuk **membaca** total saldo tersebut (`getTotalBalance`, `getPositiveBalance`, `getNegativeBalance`).

-   **Soft Delete (Pengarsipan)**: Dompet tidak bisa dihapus begitu saja, terutama jika sudah memiliki riwayat transaksi. Oleh karena itu, kelas ini menerapkan mekanisme *soft delete* (`archiveOneWallet`, `archiveAllWallets`). Dompet yang diarsipkan (`isDeleted = 1` dan `archivedAt` diisi) akan disembunyikan dari tampilan utama tetapi datanya tetap ada di database untuk menjaga integritas historis.

---

## Metode Utama

### Operasi Tulis (Write)

-   `createWallet(wallet, {fromServer})`: Membuat dompet baru.

-   `updateWallet(wallet, {fromServer})`: Memperbarui atribut sebuah dompet, seperti nama, deskripsi, atau ikonnya.

-   `archiveOneWallet(id, {fromServer})`: Melakukan *soft delete* pada satu dompet. Ini adalah cara yang aman untuk "menonaktifkan" dompet.

-   `deleteAllWallets({fromServer})`: Melakukan **hard delete** pada **semua** dompet. Operasi ini sangat destruktif dan hanya boleh digunakan dalam situasi yang sangat spesifik (misalnya, reset total data).

-   `archiveAllWallets({fromServer})`: Melakukan *soft delete* pada semua dompet yang aktif.

-   `insertOrUpdateBatch(items, {fromServer})`: Metode efisien untuk sinkronisasi, memungkinkan banyak data dompet dari server untuk disimpan atau diperbarui secara lokal dalam satu operasi.

### Operasi Baca (Read)

-   `getWallets({showArchived})`: Mengambil daftar dompet. Secara default, hanya dompet aktif yang ditampilkan. Opsi `showArchived = true` memungkinkan untuk melihat dompet yang sudah diarsipkan.

-   `getWalletById(id)`: Mengambil satu data dompet spesifik.

-   `getTotalBalance()`, `getPositiveBalance()`, `getNegativeBalance()`: Metode agregasi yang menggunakan `SUM` di level SQL untuk secara cepat menghitung total saldo dari semua dompet aktif, total saldo positif (uang yang dimiliki), dan total saldo negatif (utang atau kasbon).

---

## Interaksi dengan `BaseOperation` dan `TransactionOperation`

-   `BaseOperation`: Seperti kelas operasi lainnya, semua operasi tulis di `WalletOperation` didelegasikan ke `BaseOperation`. Ini untuk memastikan setiap perubahan (misalnya, mengubah nama dompet) ditandai dan dapat disinkronkan ke server.

-   `TransactionOperation`: Ada hubungan searah yang kuat dari `TransactionOperation` ke `WalletOperation`. `TransactionOperation` **memperbarui** saldo di `WalletModel`, sementara `WalletOperation` **membaca** saldo tersebut untuk ditampilkan di UI atau untuk keperluan laporan.

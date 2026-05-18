# Dokumentasi: `lib/user/page/points_page_user.dart`

`UserPointsPage` adalah halaman yang didedikasikan untuk menampilkan semua informasi terkait poin yang dimiliki oleh seorang pelanggan. Halaman ini memberikan gambaran lengkap tentang total poin, hadiah yang dapat ditukarkan, dan riwayat perolehan serta penggunaan poin.

---

## Fungsionalitas Utama

1.  **Menampilkan Total Poin**: Mengambil dan menampilkan jumlah total poin yang dimiliki pelanggan saat ini.
2.  **Daftar Penukaran Hadiah**: Menampilkan daftar paket atau item yang dapat ditukarkan dengan poin, beserta progres poin pengguna terhadap harga item tersebut.
3.  **Riwayat Poin**: Menampilkan daftar transaksi yang melibatkan perolehan (`+`) atau penggunaan (`-`) poin.
4.  **Tampilan Tersegmentasi**: Menggunakan `SegmentedButton` untuk beralih antara tampilan "Penukaran Hadiah" dan "Riwayat".

---

## Struktur dan Komponen

### `UserPointsPage` (StatefulWidget)

-   **Parameter:**
    -   `customerId` (String): ID unik dari pelanggan di Firestore, digunakan untuk mengambil data poin yang relevan.

### `_UserPointsPageState` (State)

Kelas ini mengelola state dan logika untuk `UserPointsPage`.

#### Properti State:

-   `_selectedMenu`: Mengontrol tampilan yang aktif antara `MenuPoin.penukaran` dan `MenuPoin.riwayat`.
-   `_totalPoints`: Menyimpan total poin pelanggan.
-   `_rewardList`: Menyimpan daftar `PackageModel` yang dapat ditukar dengan poin.
-   `_transactionHistory`: Menyimpan daftar transaksi yang memiliki catatan poin.
-   `_isLoading`, `_isLoadingHistory`: Mengontrol state *loading* untuk data awal dan riwayat secara terpisah.

#### Metode Utama:

-   `_loadPointsData()`: Dipanggil di `initState` untuk mengambil total poin dan daftar hadiah dari Firestore.
-   `_loadTransactionHistory()`: Dipanggil saat pengguna beralih ke tab "Riwayat" untuk pertama kalinya. Metode ini mengambil semua transaksi pelanggan dan memfilternya untuk hanya menampilkan yang terkait dengan poin.
-   `build()`: Merender UI utama menggunakan widget `PoinPageUi` yang telah dibuat sebelumnya.

#### Komponen UI (Helper Widgets):

-   `_buildRewardList()`: Membangun daftar hadiah yang tersedia untuk penukaran. Setiap item menampilkan progres poin pengguna terhadap hadiah tersebut.
-   `_buildPointsHistory()`: Membangun daftar riwayat transaksi poin. Setiap item menampilkan deskripsi, tanggal, dan jumlah poin yang bertambah atau berkurang.

## Perubahan Terbaru

-   **Sentralisasi Ikon**: Ikon untuk menambah (`+`) dan mengurangi (`-`) poin pada daftar riwayat (`_buildPointsHistory`) telah dipindahkan ke kelas `AppIcons`.
    -   `Icons.add_circle_outline` sekarang direferensikan melalui `AppIcons.pointsAdd`.
    -   `Icons.remove_circle_outline` sekarang direferensikan melalui `AppIcons.pointsRemove`.

    Perubahan ini memastikan konsistensi ikon di seluruh aplikasi dan mempermudah pengelolaan ikon di masa depan.

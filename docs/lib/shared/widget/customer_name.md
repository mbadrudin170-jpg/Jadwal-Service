# Dokumentasi: `lib/shared/widget/customer_name.dart`

`CustomerNameWidget` adalah `StatelessWidget` yang dirancang untuk melakukan satu tugas spesifik: mengambil ID pelanggan dan menampilkan nama yang sesuai. Keindahan widget ini terletak pada kemampuannya untuk merangkum (encapsulate) logika pengambilan data yang asinkron, termasuk pemilihan sumber data, status pemuatan (loading), dan penanganan kesalahan.

---

## Arsitektur dan Desain

1.  **Pola Komponen Sadar Data (Data-Aware Component Pattern)**: Ini adalah inti dari desain widget ini. Daripada memaksa widget induk untuk mengambil `CustomerModel` terlebih dahulu dan kemudian meneruskannya, widget ini hanya memerlukan ID-nya. Ia sendiri yang bertanggung jawab untuk mengambil data yang diperlukannya. Ini secara dramatis menyederhanakan kode widget induk.

2.  **Sumber Data Ganda (Dual Data Source)**: Fitur paling kuat dari widget ini adalah kemampuannya untuk beralih antara dua sumber data yang berbeda melalui *flag* boolean `useFirebase`:
    -   **`useFirebase = false` (Default)**: Ia menggunakan `CustomerOperation` (yang berinteraksi dengan SQLite) dan membungkusnya dalam `FutureBuilder`. Ini cocok untuk data yang tidak sering berubah dan cukup diambil sekali saat widget dibangun.
    -   **`useFirebase = true`**: Ia menggunakan `CustomerOpFirebase` (yang berinteraksi dengan Firebase) dan membungkusnya dalam `StreamBuilder`. Ini sangat kuat untuk data yang memerlukan pembaruan *real-time*. Jika nama pelanggan diubah di database Firebase, widget ini akan secara otomatis membangun kembali dirinya dan menampilkan nama yang diperbarui tanpa memerlukan intervensi manual.

3.  **Penggunaan `Builder` yang Tepat**: Widget ini menunjukkan penggunaan kanonis dari `FutureBuilder` dan `StreamBuilder`:
    -   `FutureBuilder` untuk operasi asinkron yang berjalan sekali dan selesai (seperti kueri database lokal).
    -   `StreamBuilder` untuk operasi asinkron yang dapat menghasilkan banyak nilai dari waktu ke waktu (seperti langganan data *real-time*).

4.  **Penanganan Status yang Kuat**: Di dalam kedua *builder*, semua kemungkinan status koneksi ditangani dengan anggun:
    -   `ConnectionState.waiting`: Menampilkan indikator pemuatan sederhana (`'...'`) untuk memberi tahu pengguna bahwa data sedang diambil.
    -   `snapshot.hasError`: Menampilkan pesan kesalahan visual jika pengambilan data gagal. Ini mencegah aplikasi mogok dan memberikan petunjuk tentang masalahnya.
    -   `snapshot.hasData`: Hanya ketika data berhasil diterima, ia akan mencoba menampilkan nama pelanggan.
    -   **Data Tidak Ditemukan**: Jika data berhasil diterima tetapi kosong atau `null`, ia menampilkan status yang jelas seperti "N/A" atau "Pelanggan tidak ditemukan", bukan hanya ruang kosong.

---

## Penggunaan dan Fleksibilitas

-   **Kesederhanaan**: Untuk menggunakannya, pengembang hanya perlu menempatkannya di pohon widget dan memberikan ID yang diperlukan:
    ```dart
    // Menampilkan nama dari SQLite
    CustomerNameWidget(customerId: 'cust-123');

    // Menampilkan nama dari Firebase secara real-time dengan gaya kustom
    CustomerNameWidget(
      customerId: 'cust-456',
      useFirebase: true,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
    ```

-   **Dapat Disesuaikan**: Parameter `style` opsional memungkinkan widget induk untuk mengontrol penampilan teks, membuatnya dapat beradaptasi dengan berbagai konteks UI tanpa mengubah logika internalnya.

---

## Kesimpulan

`CustomerNameWidget` adalah contoh utama dari komponen yang dapat digunakan kembali secara efektif dalam Flutter. Dengan merangkum logika pengambilan datanya sendiri dan menyediakan API yang sederhana, ia mematuhi prinsip DRY (Don't Repeat Yourself) dan secara signifikan mengurangi kerumitan di widget yang menggunakannya. Kemampuan untuk beralih antara sumber data *offline* dan *real-time* dengan satu *flag* boolean menjadikannya alat yang sangat fleksibel dan kuat dalam basis kode aplikasi.

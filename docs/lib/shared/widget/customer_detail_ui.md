# Dokumentasi: `lib/shared/widget/customer_detail_ui.dart`

`CustomerDetailUI` adalah `StatefulWidget` yang berfungsi sebagai komponen UI yang dapat digunakan kembali untuk menampilkan detail lengkap dari satu `CustomerModel`. Widget ini dirancang untuk menjadi "bodoh" (dumb widget) dalam arti bahwa ia hanya bertanggung jawab untuk menampilkan data yang diberikan kepadanya dan mendelegasikan semua tindakan (seperti mengedit atau menavigasi) ke *callback* yang disediakan dari atasannya. Ini adalah praktik arsitektur yang sangat baik.

---

## Arsitektur dan Desain

1.  **Pemisahan Tanggung Jawab (Stateful vs. Stateless)**: Meskipun sebagian besar adalah tentang tampilan, widget ini dijadikan `StatefulWidget`. Alasannya menjadi jelas di dalam `_CustomerDetailUIState`: adanya metode `_copyData` yang berinteraksi dengan `BuildContext`. Menjadikannya stateful memungkinkan penanganan `BuildContext` yang aman (menggunakan pemeriksaan `mounted`) dalam operasi asinkron, seperti menyalin data ke clipboard dan kemudian menampilkan `SnackBar`.

2.  **Pola Komponen "Bodoh" (Dumb Component Pattern)**: Widget ini tidak tahu *bagaimana* cara mengedit pelanggan, *ke mana* harus menavigasi saat kartu poin ditekan, atau *apa* yang harus dilakukan saat "Salin Semua Info" ditekan. Ia hanya menerima data (`customer`, `totalPoints`) dan serangkaian *callbacks* (`onEdit`, `onNavigateToPoints`, `onCopyAll`). Ketika suatu peristiwa terjadi, ia hanya memanggil *callback* yang sesuai. Ini membuatnya sangat dapat digunakan kembali. Widget yang sama dapat digunakan di halaman admin (dengan `onEdit` disediakan) dan di halaman pengguna (dengan `onEdit` dihilangkan).

3.  **Penggunaan Kembali UI Internal (`_buildDetailRow`)**: Daripada mengulang tata letak untuk setiap baris detail (Nama, Telepon, dll.), ada metode privat `_buildDetailRow`. Ini mengambil `title`, `detail`, dan `onCopy` *callback*, dan membangun baris UI yang konsisten. Ini mematuhi prinsip DRY (Don't Repeat Yourself) di tingkat widget dan membuat metode `build` utama lebih bersih dan lebih mudah dibaca.

4.  **Umpan Balik Pengguna yang Jelas**: Setelah setiap tindakan menyalin, `SnackBarUtil.success` dipanggil untuk memberi tahu pengguna bahwa tindakan tersebut berhasil. Ini adalah bagian penting dari pengalaman pengguna yang baik. Penggunaan `SnackBarUtil` yang sudah distandarisasi memastikan bahwa pesan-pesan ini konsisten dengan bagian lain dari aplikasi.

5.  **Keamanan Konteks (`!mounted`)**: Dalam metode `_copyData`, ada pemeriksaan `if (!mounted) return;` **sebelum dan sesudah** operasi `await`. Ini sangat penting. Ini mencegah error jika pengguna menavigasi keluar dari halaman saat operasi clipboard atau `SnackBar` sedang diproses.

---

## Interaktivitas dan Fitur

-   **Salin per-Item**: Setiap informasi detail memiliki ikon salin sendiri, memungkinkan pengguna untuk dengan mudah mengambil hanya data yang mereka butuhkan (misalnya, hanya nomor telepon).
-   **Salin Semua**: Tombol "Salin Semua Info" (yang hanya muncul jika `onCopyAll` *callback* disediakan) menyediakan cara cepat untuk menyalin ringkasan lengkap, yang diimplementasikan oleh widget induk.
-   **Tindakan Kondisional**: Tombol Edit di `AppBar` dan tombol "Salin Semua Info" hanya akan muncul jika *callback* yang sesuai tidak `null`. Ini memungkinkan widget induk untuk mengontrol fitur apa yang tersedia hanya dengan menyediakan (atau tidak menyediakan) fungsi *callback*.
-   **Komposisi Widget**: `CustomerDetailUI` menggunakan widget lain yang dapat digunakan kembali, seperti `TotalPointCard`, menunjukkan bagaimana komponen UI dapat dibangun dari blok-blok yang lebih kecil dan dapat dikelola.

---

## Kesimpulan

`CustomerDetailUI` adalah contoh yang sangat baik dari widget UI yang dirancang dengan baik dalam arsitektur Flutter. Ia fokus pada satu hal—menampilkan detail pelanggan—dan melakukannya dengan baik. Dengan memisahkan tampilan dari logika bisnis (melalui *callbacks*), memastikan keamanan konteks, dan memberikan umpan balik pengguna yang jelas, ia menciptakan komponen yang kuat, dapat diandalkan, dan sangat mudah untuk diintegrasikan ke dalam berbagai bagian dari aplikasi.

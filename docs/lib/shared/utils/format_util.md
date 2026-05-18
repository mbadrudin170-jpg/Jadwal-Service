# Dokumentasi: `lib/shared/utils/format_util.dart`

`format_util.dart` adalah pustaka utilitas terpusat yang bertanggung jawab untuk semua tugas pemformatan data di seluruh aplikasi. Tujuannya adalah untuk memastikan bahwa data seperti tanggal, waktu, dan mata uang disajikan kepada pengguna dalam format yang konsisten, dapat dibaca, dan dilokalkan dengan benar (dalam hal ini, untuk Indonesia).

File ini memanfaatkan kekuatan paket `intl` dari Dart.

---

## Arsitektur dan Desain

Desain file ini mengikuti beberapa praktik terbaik untuk utilitas:

1.  **Pemisahan Tanggung Jawab melalui Kelas Terpisah**: Daripada memiliki satu kelas `FormatUtil` raksasa, fungsionalitasnya dipecah menjadi beberapa kelas yang lebih kecil dan fokus:
    -   `FormatDateTime`: Untuk format gabungan tanggal dan waktu.
    -   `FormatDate`: Khusus untuk format tanggal.
    -   `TimeFormat`: Khusus untuk format waktu.
    -   `CurrencyFormat`: Khusus untuk format mata uang.
    Pendekatan ini membuat kode lebih mudah dinavigasi dan dipelihara. Jika Anda perlu mengubah format mata uang, Anda tahu persis harus ke mana.

2.  **Kelas Non-Instantiable**: Setiap kelas memiliki konstruktor privat (`._()`). Ini adalah pola desain yang penting untuk kelas utilitas. Ini mencegah pengembang lain untuk secara tidak sengaja membuat instance dari kelas-kelas ini (misalnya, `var myFormatter = CurrencyFormat();`), yang tidak masuk akal karena semua metodenya adalah statis. Ini memperkuat niat bahwa kelas-kelas ini hanyalah wadah untuk fungsi.

3.  **Metode Statis (Static Methods)**: Semua metode adalah `static`. Ini memungkinkan mereka dipanggil langsung dari kelas itu sendiri tanpa perlu membuat instance (contoh: `FormatDate.formatDateBasic(myDate)`). Ini bersih, efisien, dan cara standar untuk mengimplementasikan fungsi utilitas.

4.  **Lokalisasi Terpusat (`'id_ID'`)**: Semua pemformat tanggal dan mata uang secara eksplisit menggunakan lokal `'id_ID'`. Ini adalah praktik yang sangat baik. Ini memastikan bahwa output akan selalu benar untuk audiens Indonesia (misalnya, nama bulan seperti "Agt" bukan "Aug", dan simbol mata uang "Rp"), terlepas dari pengaturan lokal perangkat pengguna. Ini menjamin pengalaman pengguna yang konsisten.

---

## Metode Utama

-   **`FormatDate` / `FormatDateTime`**: Menyediakan berbagai format untuk tanggal. Adanya varian "Basic" dan "Compact" menunjukkan pemikiran tentang kebutuhan UI yang berbeda. Mungkin daftar yang padat memerlukan format ringkas (`E, d MMM yy`), sementara halaman detail dapat menampilkan format yang lebih lengkap (`d MMM yyyy`).

-   **`TimeFormat`**: Selain pemformatan `DateTime` ke `String`, ia juga menyertakan `formatTextToHour`. Metode ini menunjukkan desain yang tangguh: ia membungkus `DateTime.parse` dalam `try-catch`. Jika teks input tidak dalam format yang diharapkan, aplikasi tidak akan crash; sebaliknya, ia akan mengembalikan nilai *fallback* yang aman (`'--:--'`), mencegah kesalahan fatal di UI.

-   **`CurrencyFormat.formatCurrency`**: Ini adalah contoh sempurna dari pemformatan yang dikonfigurasi dengan benar untuk Rupiah. Ia secara eksplisit mendefinisikan `symbol: 'Rp '` dan, yang terpenting, `decimalDigits: 0`, karena Rupiah umumnya tidak menggunakan sen dalam transaksi sehari-hari. Ini menghasilkan format yang terlihat alami bagi pengguna Indonesia (misalnya, "Rp 50.000" bukan "Rp 50.000,00").

---

## Kesimpulan

`format_util.dart` adalah komponen fundamental untuk aplikasi yang dipoles. Dengan mematuhi prinsip DRY (Don't Repeat Yourself), ia memastikan konsistensi pemformatan di seluruh UI. Jika di masa depan ada keputusan untuk mengubah format tanggal di seluruh aplikasi, pengembang hanya perlu mengubah satu baris kode di dalam file ini, daripada mencari dan mengganti di puluhan file widget. Ini sangat meningkatkan keterpeliharaan (maintainability) dan mengurangi kemungkinan kesalahan.
